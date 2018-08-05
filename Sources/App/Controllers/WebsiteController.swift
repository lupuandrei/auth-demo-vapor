import Vapor
import Leaf
import Redis

final class WebsiteBaseController: RouteCollection {
  func boot(router: Router) throws {
    let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
    
    authSessionRoutes.get(use: homeHandler)
  }
  
  func homeHandler(_ req: Request) throws -> Future<View> {
    let userLoggedIn = try req.isAuthenticated(User.self)
    let showCookieMessage = req.http.cookies["cookies-accepted"] == nil
    let context = HomeContext(userLoggedIn: userLoggedIn, showCookieMessage: showCookieMessage)
    
    
    // Test save to session
    try req.session()["maskedUser"] = "Andrei Lupu"
    
    
    // Test save to REDIS
    let _ = RedisClient.connect(on: req) { (error) in
      print(error)
      }.map { (redis) in
        redis.set("test", to: "test value")
        
    }
    
    return try req.view().render("home", context)
  }
}


extension WebsiteBaseController {
  struct HomeContext: Encodable {
    let userLoggedIn: Bool
    let showCookieMessage: Bool
  }
}

