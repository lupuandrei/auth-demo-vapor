import Vapor
import FluentMySQL
import Leaf
import Authentication
import Redis

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  /// Register providers first
  try services.register(FluentMySQLProvider())
  try services.register(LeafProvider())
  try services.register(AuthenticationProvider())
  
  /// Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
  middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
  middlewares.use(SessionsMiddleware.self)
  
  services.register(middlewares)

  
  /// Register the configured SQLite database to the database config.
  var databases = DatabasesConfig()
  
  // MARK: - MySQL
  
  let mysqlConfig = MySQLDatabaseConfig(
    hostname: "127.0.0.1",
    port: 3306,
    username: "root",
    password: "",
    database: ""
  )
  
  services.register(mysqlConfig)
  databases.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)

  
  // MARK - Redis
  
  let redisDatabasePort = Environment.get("REDIS_PORT") ?? "6379"
  let redisHostName = Environment.get("REDIS_HOST") ?? "localhost"
  let redisUrlString = "redis://\(redisHostName):\(redisDatabasePort)/0"
  let redisUrl = URL(string: redisUrlString)!
  
  let redisConfig = RedisClientConfig(url: redisUrl)
  let redis = try RedisDatabase(config: redisConfig)
  
  databases.add(database: redis, as: .redis)
  services.register(databases)
  
  services.register(databases)
  
  
  /// Configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: User.self, database: .mysql)
  migrations.add(model: Token.self, database: .mysql)
  migrations.add(migration: UserAdmin.self, database: .mysql)
  services.register(migrations)
  
  User.Public.defaultDatabase = .mysql
  
  config.prefer(LeafRenderer.self, for: ViewRenderer.self)
  
//    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
//  config.prefer(DictionaryKeyedCache.self, for: KeyedCache.self)
//  config.prefer(DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>.self, for: KeyedCache.self)
//
  
  services.register(KeyedCache.self) {container -> DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>> in
    return try container.keyedCache(for: .redis)
  }
  
  config.prefer(DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>.self, for: KeyedCache.self)
  
  /// Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
}
