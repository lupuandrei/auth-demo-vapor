import Vapor
import FluentMySQL

extension User {
  final class Public: Codable {
    var id: Int?
    var firstname: String
    var lastname: String
    var email: String
    
    init(id: Int? = nil, firstname: String, lastname: String, email: String) {
      self.id = id
      self.firstname = firstname
      self.lastname = lastname
      self.email = email
    }
  }
}


extension User.Public: Content {}
extension User.Public: Parameter {}
extension User.Public: MySQLModel {
  static let entity = User.entity
}


extension User {
  func convertToPublic() -> User.Public {
    return User.Public(id: self.id, firstname: self.firstname, lastname: self.lastname, email: self.email)
  }
}
