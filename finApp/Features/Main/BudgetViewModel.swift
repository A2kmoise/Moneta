import Foundation
import SwiftUI

@MainActor
class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var budgetSummary: BudgetSummaryDTO?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let budgetAPI = BudgetAPI()
    private let transactionAPI = TransactionAPI()
    
    func loadBudgets() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                let dtos = try await budgetAPI.listBudgets()
                let summary = try await budgetAPI.getBudgetSummary()
                
                budgets = dtos.map { dto in
                    let spent = summary.categoryBreakdown[dto.name]?.spent ?? 0.0
                    return Budget(
                        id: dto.id,
                        name: dto.name,
                        allocatedAmount: dto.allocatedAmount,
                        category: dto.category,
                        spent: spent,
                        status: BudgetStatus(rawValue: dto.status.lowercased()) ?? .active
                    )
                }
            } catch {
                errorMessage = "Failed to load budgets: \(error.localizedDescription)"
                print("Budget load error: \(error)")
            }
        }
    }
    
    func loadBudgetSummary() {
        Task {
            do {
                budgetSummary = try await budgetAPI.getBudgetSummary()
            } catch {
                print("Budget summary load error: \(error)")
            }
        }
    }
    
    func createBudget(name: String, allocatedAmount: Double, category: String) async throws {
        let dto = try await budgetAPI.createBudget(name: name, allocatedAmount: allocatedAmount, category: category)
        budgets.append(dto.toBudget())
    }
    
    func updateBudget(id: UUID, name: String, allocatedAmount: Double, category: String) async throws {
        let dto = try await budgetAPI.updateBudget(id: id, name: name, allocatedAmount: allocatedAmount, category: category)
        if let index = budgets.firstIndex(where: { $0.id == id }) {
            budgets[index] = dto.toBudget()
        }
    }
    
    func deleteBudget(id: UUID) async throws {
        try await budgetAPI.deleteBudget(id: id)
        budgets.removeAll { $0.id == id }
    }
    
    func closeBudget(id: UUID) async throws {
        _ = try await budgetAPI.closeBudget(id: id)

        // Refresh budgets to get updated status
        loadBudgets()
    }
    
    func createTransaction(amount: Double, category: String, type: TransactionType, description: String, date: Date) async throws {
        let dto: CreateTransactionResponseDTO
        
        switch type {
        case .income:
            dto = try await transactionAPI.createIncome(category: category, amount: amount, date: date)
        case .expense:
            dto = try await transactionAPI.createExpense(category: category, amount: amount, date: date)
        }
        
        // Immediately update the specific budget's spent amount
        if type == .expense {
            if let index = budgets.firstIndex(where: { $0.name == category }) {
                let currentBudget = budgets[index]
                let updatedBudget = Budget(
                    id: currentBudget.id,
                    name: currentBudget.name,
                    allocatedAmount: currentBudget.allocatedAmount,
                    category: currentBudget.category,
                    spent: currentBudget.spent + amount,
                    status: currentBudget.status
                )
                budgets[index] = updatedBudget
            }
        }
        
        // Also refresh for complete accuracy
        loadBudgets()
    }
    
    func useBudget(id: UUID, amount: Double) async throws {
        try await budgetAPI.useBudget(id: id, amount: amount)
        
        // Refresh budgets to update spent amounts
        loadBudgets()
    }
    
    func refresh() {
        loadBudgets()
        loadBudgetSummary()
    }
}
