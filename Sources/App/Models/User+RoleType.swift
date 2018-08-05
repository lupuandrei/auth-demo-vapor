import Vapor
import FluentMySQL

extension User {
  enum RoleType: String, Codable {
    case admin
    case student
  }
}

extension User.RoleType: MySQLEnumType {
  static func reflectDecoded() throws -> (User.RoleType, User.RoleType) {
    return (.admin, .student)
  }
  
  static var allCases: [User.RoleType] {
    return [.admin, .student]
  }
}

