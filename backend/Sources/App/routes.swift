import Vapor

func routes(_ app: Application) throws {
    app.get("health") { _ in
        ["status": "ok"]
    }

    try AuthRoutes.boot(app)
    try TransactionRoutes.boot(app)
    try BudgetRoutes.boot(app)
    try AIRoutes.boot(app)
    try DashboardRoutes.boot(app)
}
