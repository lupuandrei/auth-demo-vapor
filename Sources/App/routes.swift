import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  // Basic "Hello, world!" example
  router.get("hello") { req in
    return "Hello, world!"
  }
  
  let websiteBase = WebsiteBaseController()
  try router.register(collection: websiteBase)
  
  let authController = AuthController()
  try router.register(collection: authController)
  
}
