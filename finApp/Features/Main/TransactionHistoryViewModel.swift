import Foundation
import SwiftUI

@MainActor
class TransactionHistoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let transactionAPI = TransactionAPI()
    
    func loadTransactions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                let dtos = try await transactionAPI.listTransactions()
                transactions = dtos.map { $0.toTransaction() }
            } catch {
                errorMessage = "Failed to load transactions: \(error.localizedDescription)"
                print("Transaction load error: \(error)")
            }
        }
    }
    
    func refresh() {
        loadTransactions()
    }
}
