import Vapor

enum BudgetRoutes {
    static func boot(_ app: Application) throws {
        let controller = BudgetController()
        let protected = app.grouped("budgets").grouped(JWTAuthMiddleware())

        protected.post(use: controller.createBudget)
        protected.get(use: controller.listBudgets)
        protected.get(":id", use: controller.getBudget)
        protected.put(":id", use: controller.updateBudget)
        protected.delete(":id", use: controller.deleteBudget)
        protected.post(":id", "use", use: controller.useBudget)
        protected.post(":id", "close", use: controller.closeBudget)
        protected.get("summary", use: controller.getBudgetSummary)
    }
}
