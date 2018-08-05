import Vapor
import FluentMySQL
import Authentication

struct UserAdmin: Migration {
  typealias Database = MySQLDatabase
  
  static func prepare(on conn: MySQLConnection) -> Future<Void> {
    let password = try? BCrypt.hash("password")
    guard let passwordHashed = password else {
      fatalError("Failed to create admin user")
    }
    let user = User(firstname: "Admin", lastname: "Admin", email: "admin@beacon.com", password: passwordHashed, roleType: .admin)
    return user.save(on: conn).transform(to: ())
  }

  static func revert(on conn: MySQLConnection) -> Future<Void> {
    return Future.map(on: conn, {})
  }
}
