import FluentMySQL
import Vapor
import Authentication
import Crypto

final class User: MySQLModel, Codable {
  var id: Int?
  var firstname: String
  var lastname: String
  var email: String
  var password: String
  var createdAt: Date?
  var updatedAt: Date?
  var roleType: RoleType
  
  init(id: Int? = nil, firstname: String, lastname: String, email: String, password: String, roleType: RoleType = .student) {
    self.id = id
    self.firstname = firstname
    self.lastname = lastname
    self.email = email
    self.password = password
    self.roleType = roleType
  }
  
  convenience init(email: String, firstname: String, lastname: String, password: String, passwordRepeat: String? = nil) {
    let passwordHashed = try! BCrypt.hash(password)
    self.init(firstname: firstname, lastname: lastname, email: email, password: passwordHashed)
  }
  
}

extension User: Migration {
  static func prepare(on connection: MySQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      
      // Email is UNIQUE
      builder.unique(on: \.email)
    }
  }
}
extension User: Content {}
extension User: Parameter {}

extension User: BasicAuthenticatable {
  static let usernameKey: UsernameKey = \User.email
  static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
  typealias TokenType = Token
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}


extension User {
  static func register(data: User.RegisterData, on connection: DatabaseConnectable) -> Future<User> {
    do {
      try data.validate()
      
      return User(email: data.email, firstname: data.firstname, lastname: data.lastname, password: data.password).create(on: connection).catchMap { error in
        throw Abort(.badRequest, reason: "An account with that email already exists.")
      }
    } catch {
      return connection.eventLoop.newFailedFuture(error: error)
    }
  }
}


// MARK: - Register

extension User {
  struct RegisterData: Content {
    var firstname: String
    var lastname: String
    let email: String
    let password: String
    let passwordRepeat: String
  }
  
}

extension User.RegisterData: Validatable, Reflectable {
  static func validations() throws -> Validations<User.RegisterData> {
    var validations = Validations(User.RegisterData.self)
    try validations.add(\.firstname, .ascii)
    try validations.add(\.lastname, .ascii)
    try validations.add(\.email, .email)
    try validations.add(\.password, .count(8...))
    validations.add("passwords match") { model in
      guard model.password == model.passwordRepeat else {
        throw BasicValidationError("Passwords don't match")
      }
    }
    return validations
  }
}

