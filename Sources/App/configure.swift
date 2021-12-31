import Fluent
import FluentPostgresDriver
import Leaf
import Redis
import SystemPackage
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // load game plugins
    var path = FilePath(app.directory.resourcesDirectory)
    path.append("Games")
    let gameController = GameController(pluginDir: path.string)

    app.storage.set(GameControllerKey.self, to: gameController, onShutdown: { $0.shutdown() })

    // MARK: serve static files
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // MARK: database
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    // MARK: migrations
    app.migrations.add(Player.CreateMigration())
    app.migrations.add(PlayerToken.CreateMigration())

    // MARK: sessions
    app.redis.configuration = try RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "localhost",
        port: Environment.get("REDIS_PORT").flatMap(Int.init(_:)) ?? RedisConnection.Configuration.defaultPort,
        password: Environment.get("REDIS_PASSWORD"),
        database: nil,
        pool: RedisConfiguration.PoolOptions(
            maximumConnectionCount: .maximumPreservedConnections(4),
            minimumConnectionCount: 1))

    app.sessions.use(.redis)
    app.middleware.use(app.sessions.middleware)

    // MARK: template engine
    app.views.use(.leaf)

    // MARK: register routes
    try routes(app, gameController)
}
