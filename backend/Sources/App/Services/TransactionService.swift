import Vapor
import Fluent

protocol TransactionServiceProtocol {
    func createIncome(_ req: Request, data: CreateTransactionDTO, user: User) async throws -> TransactionResponseDTO
    func createExpense(_ req: Request, data: CreateTransactionDTO, user: User) async throws -> TransactionResponseDTO
    func listTransactions(_ req: Request, user: User) async throws -> [TransactionResponseDTO]
    func getBalance(_ req: Request, user: User) async throws -> BalanceResponseDTO
    func getTransaction(_ req: Request, id: UUID, user: User) async throws -> TransactionResponseDTO
    func updateTransaction(_ req: Request, id: UUID, data: UpdateTransactionDTO, user: User) async throws -> TransactionResponseDTO
    func deleteTransaction(_ req: Request, id: UUID, user: User) async throws -> HTTPStatus
    func getTransactionsByDateRange(_ req: Request, user: User, startDate: Date, endDate: Date) async throws -> [TransactionResponseDTO]
    func getTransactionsByCategory(_ req: Request, user: User, category: String) async throws -> [TransactionResponseDTO]
}

struct TransactionService: TransactionServiceProtocol {
    func createIncome(_ req: Request, data: CreateTransactionDTO, user: User) async throws -> TransactionResponseDTO {
        let transaction = Transaction(
            id: nil,
            userID: try user.requireID(),
            type: .income,
            category: data.category,
            amount: data.amount,
            date: data.date
        )
        try await transaction.save(on: req.db)
        return transaction.toDTO()
    }

    func createExpense(_ req: Request, data: CreateTransactionDTO, user: User) async throws -> TransactionResponseDTO {
        let transaction = Transaction(
            id: nil,
            userID: try user.requireID(),
            type: .expense,
            category: data.category,
            amount: data.amount,
            date: data.date
        )
        try await transaction.save(on: req.db)
        return transaction.toDTO()
    }

    func listTransactions(_ req: Request, user: User) async throws -> [TransactionResponseDTO] {
        let userID = try user.requireID()
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$date, .descending)
            .all()
        return txs.map { $0.toDTO() }
    }

    func getBalance(_ req: Request, user: User) async throws -> BalanceResponseDTO {
        let userID = try user.requireID()
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
        let income = txs.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
        let expenses = txs.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }
        return BalanceResponseDTO(balance: income - expenses)
    }

    func getTransaction(_ req: Request, id: UUID, user: User) async throws -> TransactionResponseDTO {
        let userID = try user.requireID()
        guard let transaction = try await Transaction.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Transaction not found")
        }

        guard transaction.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to view this transaction")
        }

        return transaction.toDTO()
    }

    func updateTransaction(_ req: Request, id: UUID, data: UpdateTransactionDTO, user: User) async throws -> TransactionResponseDTO {
        let userID = try user.requireID()
        guard let transaction = try await Transaction.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Transaction not found")
        }

        guard transaction.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to update this transaction")
        }

        if let typeString = data.type?.lowercased() {
            guard let newType = TransactionType(rawValue: typeString) else {
                throw Abort(.badRequest, reason: "Invalid transaction type")
            }
            transaction.type = newType
        }

        if let category = data.category, !category.isEmpty {
            transaction.category = category
        }

        if let amount = data.amount {
            guard amount > 0 else {
                throw Abort(.badRequest, reason: "Amount must be greater than 0")
            }
            transaction.amount = amount
        }

        if let date = data.date {
            transaction.date = date
        }

        try await transaction.save(on: req.db)
        return transaction.toDTO()
    }
    
    func deleteTransaction(_ req: Request, id: UUID, user: User) async throws -> HTTPStatus {
        let userID = try user.requireID()
        guard let transaction = try await Transaction.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Transaction not found")
        }
        
        guard transaction.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to delete this transaction")
        }
        
        try await transaction.delete(on: req.db)
        return .noContent
    }
    
    func getTransactionsByDateRange(_ req: Request, user: User, startDate: Date, endDate: Date) async throws -> [TransactionResponseDTO] {
        let userID = try user.requireID()
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$date >= startDate)
            .filter(\.$date <= endDate)
            .sort(\.$date, .descending)
            .all()
        return txs.map { $0.toDTO() }
    }
    
    func getTransactionsByCategory(_ req: Request, user: User, category: String) async throws -> [TransactionResponseDTO] {
        let userID = try user.requireID()
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$category == category)
            .sort(\.$date, .descending)
            .all()
        return txs.map { $0.toDTO() }
    }
}

extension Transaction {
    func toDTO() -> TransactionResponseDTO {
        TransactionResponseDTO(
            id: self.id,
            type: self.type.rawValue,
            category: self.category,
            amount: self.amount,
            date: self.date,
            createdAt: self.createdAt
        )
    }
}
