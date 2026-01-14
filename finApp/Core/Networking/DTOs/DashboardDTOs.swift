import Foundation

struct DashboardSummaryDTO: Codable {
    let balance: Double
    let totalIncome: Double
    let totalExpenses: Double
    let spendingPercentage: Double
    let recentTransactions: [TransactionDTO]
}

struct TransactionDTO: Codable, Identifiable {
    let id: UUID?
    let type: String
    let category: String
    let amount: Double
    let date: Date
    let createdAt: Date?
    
    var transactionType: TransactionType {
        type.lowercased() == "income" ? .income : .expense
    }
    
    var transactionCategory: TransactionCategory {
        TransactionCategory(rawValue: category.lowercased()) ?? .other
    }
    
    func toTransaction() -> Transaction {
        Transaction(
            title: transactionCategory.title,
            amount: amount,
            date: date,
            type: transactionType,
            category: transactionCategory
        )
    }
}
