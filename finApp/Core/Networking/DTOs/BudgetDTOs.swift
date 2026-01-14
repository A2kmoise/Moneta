import Foundation
import SwiftUI

struct CreateBudgetDTO: Codable {
    let budgetName: String
    let allocatedAmount: Double
    let relatedCategory: String
}

struct UseBudgetDTO: Codable {
    let amount: Double
}

struct BudgetResponseDTO: Codable, Identifiable {
    let id: UUID?
    let name: String
    let allocatedAmount: Double
    let category: String
    let status: String
    
    func toBudget() -> Budget {
        Budget(
            id: id,
            name: name,
            allocatedAmount: allocatedAmount,
            category: category,
            spent: 0.0,
            status: BudgetStatus(rawValue: status.lowercased()) ?? .active
        )
    }
}

struct CategorySpendingDTO: Codable {
    let allocated: Double
    let spent: Double
    let remaining: Double
}

struct BudgetSummaryDTO: Codable {
    let totalIncome: Double
    let totalExpenses: Double
    let totalAllocated: Double
    let remainingBudget: Double
    let categoryBreakdown: [String: CategorySpendingDTO]
}

enum BudgetStatus: String, Codable {
    case active
    case exceeded
    case completed
}

struct Budget: Identifiable {
    let id: UUID?
    let name: String
    let allocatedAmount: Double
    let category: String
    let spent: Double
    let status: BudgetStatus
    
    var remaining: Double {
        allocatedAmount - spent
    }
    
    var progress: Double {
        guard allocatedAmount > 0 else { return 0 }
        return min(spent / allocatedAmount, 1.0)
    }
    
    var progressColor: Color {
        if progress < 0.8 {
            return Color(red: 0.5, green: 0.8, blue: 0.2)
        } else if progress <= 1.0 {
            return Color.orange
        } else {
            return Color.red
        }
    }
}
