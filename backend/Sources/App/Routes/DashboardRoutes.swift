import Vapor

enum DashboardRoutes {
    static func boot(_ app: Application) throws {
        let controller = DashboardController()
        let protected = app.grouped("dashboard").grouped(JWTAuthMiddleware())

        protected.get("summary", use: controller.summary)
    }
}
