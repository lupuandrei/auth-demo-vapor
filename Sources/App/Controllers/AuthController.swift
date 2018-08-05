import Vapor
import Leaf
import Authentication

final class AuthController: RouteCollection {
  func boot(router: Router) throws {
    // Auth session routes
    let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
    
    authSessionRoutes.get("login", use: login)
    authSessionRoutes.post(LoginPostData.self, at: "login", use: loginPost)
    
    authSessionRoutes.get("register", use: register)
    authSessionRoutes.post(User.RegisterData.self, at: "register", use: registerPost)
    
    authSessionRoutes.post("logout", use: logoutHandler)
  }
  
  // MARK: - Login
  
  func login(_ req: Request) throws -> Future<View> {
    return try req.view().render("login")
  }
  
  func loginPost(_ req: Request, data: LoginPostData) throws -> Future<Response> {
    return User.authenticate(username: data.email, password: data.password, using: BCryptDigest(), on: req).map(to: Response.self, { (user) in
      guard let user = user else {
        return req.redirect(to: "/login")
      }
      let logger = try req.make(Logger.self)
      
      logger.info("Authenticate user")
      try req.authenticateSession(user)
      
      try req.session()["test"] = "andrei test"
      if user.roleType == .admin {
        logger.info("Redirect to admin page")
        return req.redirect(to: "/")
      }
      logger.info("Redirect to home")
      return req.redirect(to: "/")
    })
  }
  
  // MARK: - Register
  
  func register(_ req: Request) throws -> Future<View> {
    return try req.view().render("register")
  }
  
  func registerPost(_ req: Request, data: User.RegisterData) throws -> Future<Response> {
    return User.register(data: data, on: req).map(to: Response.self, { (user) in
      try req.authenticateSession(user)
      return req.redirect(to: "/")
    })
  }
  
  func logoutHandler(_ req: Request) throws -> Response {
    try req.unauthenticateSession(User.self)
    return req.redirect(to: "/")
  }
}

extension AuthController {
  struct LoginPostData: Content {
    let email: String
    let password: String
  }
}
