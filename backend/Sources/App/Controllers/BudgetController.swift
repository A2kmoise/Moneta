import Vapor

final class BudgetController {
    private let service: BudgetServiceProtocol

    init(service: BudgetServiceProtocol = BudgetService()) {
        self.service = service
    }

    func createBudget(_ req: Request) async throws -> BudgetResponseDTO {
        try CreateBudgetDTO.validate(content: req)
        let dto = try req.content.decode(CreateBudgetDTO.self)
        let user = try req.authUser
        return try await service.createBudget(req, data: dto, user: user)
    }

    func listBudgets(_ req: Request) async throws -> [BudgetResponseDTO] {
        let user = try req.authUser
        return try await service.listBudgets(req, user: user)
    }

    func getBudget(_ req: Request) async throws -> BudgetResponseDTO {
        let user = try req.authUser
        guard let budgetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid budget ID")
        }
        return try await service.getBudget(req, id: budgetID, user: user)
    }
    
    func updateBudget(_ req: Request) async throws -> BudgetResponseDTO {
        try CreateBudgetDTO.validate(content: req)
        let dto = try req.content.decode(CreateBudgetDTO.self)
        let user = try req.authUser
        guard let budgetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid budget ID")
        }
        return try await service.updateBudget(req, id: budgetID, data: dto, user: user)
    }
    
    func deleteBudget(_ req: Request) async throws -> HTTPStatus {
        let user = try req.authUser
        guard let budgetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid budget ID")
        }
        return try await service.deleteBudget(req, id: budgetID, user: user)
    }
    
    func getBudgetSummary(_ req: Request) async throws -> BudgetSummaryDTO {
        let user = try req.authUser
        return try await service.getBudgetSummary(req, user: user)
    }
    
    func useBudget(_ req: Request) async throws -> HTTPStatus {
        let user = try req.authUser
        guard let budgetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid budget ID")
        }
        
        let dto = try req.content.decode(UseBudgetDTO.self)
        return try await service.useBudget(req, id: budgetID, amount: dto.amount, user: user)
    }

    func closeBudget(_ req: Request) async throws -> BudgetResponseDTO {
        let user = try req.authUser
        guard let budgetID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid budget ID")
        }
        return try await service.closeBudget(req, id: budgetID, user: user)
    }
}
