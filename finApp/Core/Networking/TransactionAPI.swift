import Foundation

final class TransactionAPI {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func createIncome(category: String, amount: Double, date: Date) async throws -> CreateTransactionResponseDTO {
        let dto = CreateTransactionDTO(category: category, amount: amount, date: date)
        return try await client.request("/transactions/income", method: "POST", body: dto)
    }
    
    func createExpense(category: String, amount: Double, date: Date) async throws -> CreateTransactionResponseDTO {
        let dto = CreateTransactionDTO(category: category, amount: amount, date: date)
        return try await client.request("/transactions/expense", method: "POST", body: dto)
    }
    
    func listTransactions() async throws -> [TransactionDTO] {
        try await client.request("/transactions")
    }
}
