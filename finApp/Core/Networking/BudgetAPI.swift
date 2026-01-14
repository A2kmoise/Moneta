import Foundation

final class BudgetAPI {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func createBudget(name: String, allocatedAmount: Double, category: String) async throws -> BudgetResponseDTO {
        let dto = CreateBudgetDTO(budgetName: name, allocatedAmount: allocatedAmount, relatedCategory: category)
        return try await client.request("/budgets", method: "POST", body: dto)
    }
    
    func listBudgets() async throws -> [BudgetResponseDTO] {
        try await client.request("/budgets")
    }
    
    func getBudget(id: UUID) async throws -> BudgetResponseDTO {
        try await client.request("/budgets/\(id.uuidString)")
    }
    
    func updateBudget(id: UUID, name: String, allocatedAmount: Double, category: String) async throws -> BudgetResponseDTO {
        let dto = CreateBudgetDTO(budgetName: name, allocatedAmount: allocatedAmount, relatedCategory: category)
        return try await client.request("/budgets/\(id.uuidString)", method: "PUT", body: dto)
    }
    
    func deleteBudget(id: UUID) async throws {
        let _: EmptyResponse = try await client.request("/budgets/\(id.uuidString)", method: "DELETE")
    }
    
    func getBudgetSummary() async throws -> BudgetSummaryDTO {
        try await client.request("/budgets/summary")
    }
    
    func useBudget(id: UUID, amount: Double) async throws {
        let dto = UseBudgetDTO(amount: amount)
        let _: EmptyResponse = try await client.request("/budgets/\(id.uuidString)/use", method: "POST", body: dto)
    }

    func closeBudget(id: UUID) async throws -> BudgetResponseDTO {
        try await client.request("/budgets/\(id.uuidString)/close", method: "POST")
    }
}
