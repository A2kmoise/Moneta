import Vapor

struct DashboardSummaryDTO: Content {
    let balance: Double
    let totalIncome: Double
    let totalExpenses: Double
    let spendingPercentage: Double
    let recentTransactions: [TransactionResponseDTO]
}
