import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var totalIncome: Double = 0.0
    @Published var totalExpenses: Double = 0.0
    @Published var spendingPercentage: Double = 0.0
    @Published var recentTransactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dashboardAPI = DashboardAPI()
    
    func loadDashboard() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                let summary = try await dashboardAPI.getDashboardSummary()
                balance = summary.balance
                totalIncome = summary.totalIncome
                totalExpenses = summary.totalExpenses
                spendingPercentage = summary.spendingPercentage
                recentTransactions = summary.recentTransactions.map { $0.toTransaction() }
            } catch {
                errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
                print("Dashboard load error: \(error)")
            }
        }
    }
    
    func refresh() {
        loadDashboard()
    }
}
