import Vapor

enum TransactionRoutes {
    static func boot(_ app: Application) throws {
        let controller = TransactionController()
        let protected = app.grouped("transactions").grouped(JWTAuthMiddleware())

        protected.post("income", use: controller.createIncome)
        protected.post("expense", use: controller.createExpense)
        protected.get(use: controller.listTransactions)
        protected.get("date-range", use: controller.getTransactionsByDateRange)
        protected.get("category", use: controller.getTransactionsByCategory)

        protected.get(":id", use: controller.getTransaction)
        protected.put(":id", use: controller.updateTransaction)
        protected.delete(":id", use: controller.deleteTransaction)

        // Balance endpoint on its own path but still logically under transactions
        let balanceGroup = app.grouped(JWTAuthMiddleware())
        balanceGroup.get("balance", use: controller.getBalance)
    }
}
