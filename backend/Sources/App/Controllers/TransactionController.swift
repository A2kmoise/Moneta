import Vapor

final class TransactionController {
    private let service: TransactionServiceProtocol

    init(service: TransactionServiceProtocol = TransactionService()) {
        self.service = service
    }

    func createIncome(_ req: Request) async throws -> TransactionResponseDTO {
        try CreateTransactionDTO.validate(content: req)
        let dto = try req.content.decode(CreateTransactionDTO.self)
        let user = try req.authUser
        return try await service.createIncome(req, data: dto, user: user)
    }

    func createExpense(_ req: Request) async throws -> TransactionResponseDTO {
        try CreateTransactionDTO.validate(content: req)
        let dto = try req.content.decode(CreateTransactionDTO.self)
        let user = try req.authUser
        return try await service.createExpense(req, data: dto, user: user)
    }

    func getTransaction(_ req: Request) async throws -> TransactionResponseDTO {
        let user = try req.authUser
        guard let transactionID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid transaction ID")
        }
        return try await service.getTransaction(req, id: transactionID, user: user)
    }

    func updateTransaction(_ req: Request) async throws -> TransactionResponseDTO {
        let user = try req.authUser
        guard let transactionID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid transaction ID")
        }
        try UpdateTransactionDTO.validate(content: req)
        let dto = try req.content.decode(UpdateTransactionDTO.self)
        return try await service.updateTransaction(req, id: transactionID, data: dto, user: user)
    }
    
    func deleteTransaction(_ req: Request) async throws -> HTTPStatus {
        let user = try req.authUser
        guard let transactionID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid transaction ID")
        }
        return try await service.deleteTransaction(req, id: transactionID, user: user)
    }
    
    func getTransactionsByDateRange(_ req: Request) async throws -> [TransactionResponseDTO] {
        let user = try req.authUser

        guard let startDateString = req.query[String.self, at: "startDate"],
              let endDateString = req.query[String.self, at: "endDate"] else {
            throw Abort(.badRequest, reason: "Missing startDate or endDate query parameters")
        }

        let isoWithFractional = ISO8601DateFormatter()
        isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]

        guard let startDate = isoWithFractional.date(from: startDateString) ?? iso.date(from: startDateString),
              let endDate = isoWithFractional.date(from: endDateString) ?? iso.date(from: endDateString) else {
            throw Abort(.badRequest, reason: "startDate/endDate must be ISO8601 strings")
        }

        return try await service.getTransactionsByDateRange(req, user: user, startDate: startDate, endDate: endDate)
    }
    
    func getTransactionsByCategory(_ req: Request) async throws -> [TransactionResponseDTO] {
        let user = try req.authUser
        guard let category = req.query[String.self, at: "category"] else {
            throw Abort(.badRequest, reason: "Missing category query parameter")
        }
        return try await service.getTransactionsByCategory(req, user: user, category: category)
    }

    func listTransactions(_ req: Request) async throws -> [TransactionResponseDTO] {
        let user = try req.authUser
        return try await service.listTransactions(req, user: user)
    }

    func getBalance(_ req: Request) async throws -> BalanceResponseDTO {
        let user = try req.authUser
        return try await service.getBalance(req, user: user)
    }
}
