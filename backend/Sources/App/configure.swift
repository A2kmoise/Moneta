import Vapor
import Fluent
import FluentPostgresDriver
import PostgresKit
import JWT

enum App {}

extension App {
    static func configure(_ app: Application) throws {
        // Server configuration
        app.http.server.configuration.port = Environment.get("PORT").flatMap(Int.init) ?? 8080
        app.http.server.configuration.hostname = Environment.get("HOSTNAME") ?? "0.0.0.0"

        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        ContentConfiguration.global.use(encoder: jsonEncoder, for: .json)

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        ContentConfiguration.global.use(decoder: jsonDecoder, for: .json)
        
        // CORS configuration for iOS app
        let corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .DELETE, .PATCH, .OPTIONS],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
        )
        let cors = CORSMiddleware(configuration: corsConfiguration)
        app.middleware.use(cors, at: .beginning)

        // Database configuration (PostgreSQL)
        // Supports both Neon (DATABASE_URL) and local PostgreSQL (individual settings)
        if let databaseURL = Environment.get("DATABASE_URL") {
            // Use full connection string (Neon, Heroku, etc.)
            // Neon requires TLS; explicitly enable it to avoid handshake errors.
            let urlString: String
            if databaseURL.localizedCaseInsensitiveContains("sslmode=") || databaseURL.localizedCaseInsensitiveContains("tlsmode=") {
                urlString = databaseURL
            } else if databaseURL.contains("?") {
                urlString = databaseURL + "&sslmode=require"
            } else {
                urlString = databaseURL + "?sslmode=require"
            }

            let config = try SQLPostgresConfiguration(url: urlString)
            app.databases.use(.postgres(configuration: config), as: .psql)
            app.logger.info("Connected to database using DATABASE_URL")
        } else {
            // Use individual components (local PostgreSQL)
            let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
            let username = Environment.get("DATABASE_USERNAME") ?? "postgres"
            let password = Environment.get("DATABASE_PASSWORD") ?? ""
            let database = Environment.get("DATABASE_NAME") ?? "budget_db"
            let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? PostgresConfiguration.ianaPortNumber

            app.databases.use(.postgres(
                hostname: hostname,
                port: port,
                username: username,
                password: password,
                database: database
            ), as: .psql)
            app.logger.info("Connected to database at \(hostname):\(port)/\(database)")
        }

        // JWT signer
        let jwtSecret = Environment.get("JWT_SECRET") ?? "CHANGE_ME_SUPER_SECRET_KEY_PLEASE_CHANGE_IN_PRODUCTION"
        app.jwt.signers.use(.hs256(key: jwtSecret))

        // Migrations
        app.migrations.add(CreateUser())
        app.migrations.add(CreateTransaction())
        app.migrations.add(CreateBudget())

        // Middleware
        app.middleware.use(ErrorMiddleware.default(environment: app.environment))

        // Routes
        try routes(app)
        
        // Log startup info
        app.logger.info("Server starting on \(app.http.server.configuration.hostname):\(app.http.server.configuration.port)")
    }
}
