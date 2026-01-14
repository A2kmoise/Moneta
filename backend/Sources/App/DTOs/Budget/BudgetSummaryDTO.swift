import Vapor

struct CategorySpending: Content {
    let allocated: Double
    let spent: Double
    let remaining: Double
}

struct UseBudgetDTO: Content {
    let amount: Double
}

struct BudgetSummaryDTO: Content {
    let totalIncome: Double
    let totalExpenses: Double
    let totalAllocated: Double
    let remainingBudget: Double
    let categoryBreakdown: [String: CategorySpending]
}
