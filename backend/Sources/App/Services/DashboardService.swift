import Vapor
import Fluent

protocol DashboardServiceProtocol {
    func getSummary(_ req: Request, user: User) async throws -> DashboardSummaryDTO
}

struct DashboardService: DashboardServiceProtocol {
    func getSummary(_ req: Request, user: User) async throws -> DashboardSummaryDTO {
        let userID = try user.requireID()

        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$createdAt, .descending)
            .all()

        let totalIncome = txs.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
        let totalExpenses = txs.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }
        let balance = totalIncome - totalExpenses
        
        let spendingPercentage: Double
        if totalIncome > 0 {
            spendingPercentage = (totalExpenses / totalIncome) * 100
        } else {
            spendingPercentage = 0
        }

        let recent = txs.prefix(5).map { $0.toDTO() }

        return DashboardSummaryDTO(
            balance: balance,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            spendingPercentage: spendingPercentage,
            recentTransactions: recent
        )
    }
}
