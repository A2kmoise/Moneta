import Foundation
import SwiftUI

// MODIFICATION: Renamed 'expense' to 'spending'
enum TransactionType: String {
    case income
    case expense // Renamed from 'expense'
}

enum TransactionCategory: String, CaseIterable {
    case shopping
    case food
    case transport
    case subscriptions
    case entertainment
    case other

    var color: Color {
        switch self {
        case .shopping: return .orange
        case .food: return .green
        case .transport: return .blue
        case .subscriptions: return .purple
        case .entertainment: return .pink
        case .other: return .gray
        }
    }

    var title: String {
        rawValue.capitalized
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let date: Date
    let type: TransactionType
    let category: TransactionCategory
}

struct BudgetSummary {
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpense: Double
    let monthlyBudget: Double
}

struct SampleData {
    static let budget = BudgetSummary(
        totalBalance: 2408.45,
        monthlyIncome: 4250,
        monthlyExpense: 1841.55,
        monthlyBudget: 2500
    )
   
    static let accounts: [Account] = [
            Account(title: "PASHABANK USD", balance: 425.35, iconName: "bank.fill"),
            Account(title: "Cash USD", balance: 600.00, iconName: "bitcoinsign.circle.fill"),
            Account(title: "LEOBANK USD", balance: 775.00, iconName: "bank.fill")
        ]

    static let transactions: [Transaction] = [
        // MODIFICATION: Updated usages from .expense to .spending
        Transaction(title: "Groceries", amount: 65.20, date: .now, type: .expense, category: .food),
        Transaction(title: "Spotify", amount: 9.99, date: .now.addingTimeInterval(-86400), type: .expense, category: .subscriptions),
        Transaction(title: "Salary", amount: 2100, date: .now.addingTimeInterval(-86400 * 2), type: .income, category: .other),
        Transaction(title: "Bus pass", amount: 45.0, date: .now.addingTimeInterval(-86400 * 3), type: .expense, category: .transport),
        Transaction(title: "Shoes", amount: 120.0, date: .now.addingTimeInterval(-86400 * 4), type: .expense, category: .shopping)
    ]
}

enum TimeRange: CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly

    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    var subtitle: String {
        switch self {
        case .daily: return "Today"
        case .weekly: return "This week"
        case .monthly: return "This month"
        case .yearly: return "This year"
        }
    }
}

struct ChartPoint: Identifiable {
    let id = UUID()
    let normalizedValue: Double
    let isHighlight: Bool
}

enum MockChartData {
    static func points(for range: TimeRange) -> [ChartPoint] {
        switch range {
        case .daily:
            return [0.2, 0.4, 0.7, 0.5, 0.9].enumerated().map { index, value in
                ChartPoint(normalizedValue: value, isHighlight: index == 4)
            }
        case .weekly:
            return [0.3, 0.6, 0.8, 0.5, 0.4, 0.9, 0.7].enumerated().map { index, value in
                ChartPoint(normalizedValue: value, isHighlight: index == 5)
            }
        case .monthly:
            return [0.2, 0.5, 0.4, 0.6, 0.9, 0.7].enumerated().map { index, value in
                ChartPoint(normalizedValue: value, isHighlight: index == 4)
            }
        case .yearly:
            return [0.4, 0.3, 0.6, 0.5, 0.7, 0.8, 0.9, 0.6].enumerated().map { index, value in
                ChartPoint(normalizedValue: value, isHighlight: index == 6)
            }
        }
    }
}

struct Account: Identifiable {
    let id = UUID()
    let title: String
    let balance: Double
    let iconName: String
}
