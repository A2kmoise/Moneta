import Vapor
import Fluent

protocol BudgetServiceProtocol {
    func createBudget(_ req: Request, data: CreateBudgetDTO, user: User) async throws -> BudgetResponseDTO
    func listBudgets(_ req: Request, user: User) async throws -> [BudgetResponseDTO]
    func getBudget(_ req: Request, id: UUID, user: User) async throws -> BudgetResponseDTO
    func updateBudget(_ req: Request, id: UUID, data: CreateBudgetDTO, user: User) async throws -> BudgetResponseDTO
    func deleteBudget(_ req: Request, id: UUID, user: User) async throws -> HTTPStatus
    func getBudgetSummary(_ req: Request, user: User) async throws -> BudgetSummaryDTO
    func useBudget(_ req: Request, id: UUID, amount: Double, user: User) async throws -> HTTPStatus
    func closeBudget(_ req: Request, id: UUID, user: User) async throws -> BudgetResponseDTO
}

struct BudgetService: BudgetServiceProtocol {
    func createBudget(_ req: Request, data: CreateBudgetDTO, user: User) async throws -> BudgetResponseDTO {
        let userID = try user.requireID()

        // Calculate user's total income to validate allocatedAmount
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
        let totalIncome = txs.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }

        guard data.allocatedAmount <= totalIncome else {
            throw Abort(.badRequest, reason: "Allocated amount exceeds total income")
        }

        // Compute current spending for this category
        let categoryExpenses = txs.filter { $0.type == .expense && $0.category == data.relatedCategory }
        let totalExpenses = categoryExpenses.reduce(0.0) { $0 + $1.amount }

        let status = Self.computeStatus(spent: totalExpenses, allocated: data.allocatedAmount)

        let budget = Budget(
            userID: userID,
            name: data.budgetName,
            allocatedAmount: data.allocatedAmount,
            category: data.relatedCategory,
            status: status
        )
        try await budget.save(on: req.db)
        return budget.toDTO()
    }

    func listBudgets(_ req: Request, user: User) async throws -> [BudgetResponseDTO] {
        let userID = try user.requireID()
        let budgets = try await Budget.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()

        // For each budget, recompute status based on current expenses
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()

        var updatedBudgets: [BudgetResponseDTO] = []
        for budget in budgets {
            if budget.status == .completed {
                updatedBudgets.append(budget.toDTO())
                continue
            }
            let expensesForCategory = txs.filter { $0.type == .expense && $0.category == budget.category }
            let spent = expensesForCategory.reduce(0.0) { $0 + $1.amount }
            let newStatus = Self.computeStatus(spent: spent, allocated: budget.allocatedAmount)
            if budget.status != newStatus {
                budget.status = newStatus
                try await budget.save(on: req.db)
            }
            updatedBudgets.append(budget.toDTO())
        }

        return updatedBudgets
    }

    func getBudget(_ req: Request, id: UUID, user: User) async throws -> BudgetResponseDTO {
        let userID = try user.requireID()
        guard let budget = try await Budget.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Budget not found")
        }

        guard budget.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to view this budget")
        }

        if budget.status == .completed {
            return budget.toDTO()
        }

        // Recompute status using current expenses for its category
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()

        let expensesForCategory = txs.filter { $0.type == .expense && $0.category == budget.category }
        let spent = expensesForCategory.reduce(0.0) { $0 + $1.amount }
        let newStatus = Self.computeStatus(spent: spent, allocated: budget.allocatedAmount)
        if budget.status != newStatus {
            budget.status = newStatus
            try await budget.save(on: req.db)
        }

        return budget.toDTO()
    }

    func updateBudget(_ req: Request, id: UUID, data: CreateBudgetDTO, user: User) async throws -> BudgetResponseDTO {
        let userID = try user.requireID()
        
        guard let budget = try await Budget.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Budget not found")
        }
        
        guard budget.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to update this budget")
        }
        
        if budget.status == .completed {
            throw Abort(.badRequest, reason: "Completed budgets cannot be updated")
        }
        
        // Validate allocated amount against total income
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
        let totalIncome = txs.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
        
        guard data.allocatedAmount <= totalIncome else {
            throw Abort(.badRequest, reason: "Allocated amount exceeds total income")
        }
        
        // Update budget fields
        budget.name = data.budgetName
        budget.allocatedAmount = data.allocatedAmount
        budget.category = data.relatedCategory
        
        // Recompute status
        let categoryExpenses = txs.filter { $0.type == .expense && $0.category == data.relatedCategory }
        let totalExpenses = categoryExpenses.reduce(0.0) { $0 + $1.amount }
        budget.status = Self.computeStatus(spent: totalExpenses, allocated: data.allocatedAmount)
        
        try await budget.save(on: req.db)
        return budget.toDTO()
    }
    
    func deleteBudget(_ req: Request, id: UUID, user: User) async throws -> HTTPStatus {
        let userID = try user.requireID()
        
        guard let budget = try await Budget.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Budget not found")
        }
        
        guard budget.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to delete this budget")
        }
        
        try await budget.delete(on: req.db)
        return .noContent
    }
    
    func getBudgetSummary(_ req: Request, user: User) async throws -> BudgetSummaryDTO {
        let userID = try user.requireID()
        
        let budgets = try await Budget.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
        
        let txs = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
        
        let totalIncome = txs.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
        let totalExpenses = txs.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }
        let totalAllocated = budgets.reduce(0.0) { $0 + $1.allocatedAmount }
        let remainingBudget = totalIncome - totalAllocated
        
        var categoryBreakdown: [String: CategorySpending] = [:]
        for budget in budgets {
            let categoryExpenses = txs.filter { $0.type == .expense && $0.category == budget.category }
            let spent = categoryExpenses.reduce(0.0) { $0 + $1.amount }
            let spending = CategorySpending(
                allocated: budget.allocatedAmount,
                spent: spent,
                remaining: budget.allocatedAmount - spent
            )
            categoryBreakdown[budget.name] = spending
            categoryBreakdown[budget.category] = spending
        }
        
        return BudgetSummaryDTO(
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            totalAllocated: totalAllocated,
            remainingBudget: remainingBudget,
            categoryBreakdown: categoryBreakdown
        )
    }

    func useBudget(_ req: Request, id: UUID, amount: Double, user: User) async throws -> HTTPStatus {
        let userID = try user.requireID()
        
        guard let budget = try await Budget.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Budget not found")
        }
        
        guard budget.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to use this budget")
        }

        if budget.status == .completed {
            throw Abort(.badRequest, reason: "Completed budgets cannot be used")
        }

        guard amount > 0 else {
            throw Abort(.badRequest, reason: "Amount must be greater than 0")
        }
        
        // Create a transaction for budget usage
        let transaction = Transaction(
            id: nil,
            userID: userID,
            type: .expense,
            category: budget.category,
            amount: amount,
            date: Date()
        )
        
        try await transaction.save(on: req.db)
        return .noContent
    }

    func closeBudget(_ req: Request, id: UUID, user: User) async throws -> BudgetResponseDTO {
        let userID = try user.requireID()

        guard let budget = try await Budget.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Budget not found")
        }

        guard budget.$user.id == userID else {
            throw Abort(.forbidden, reason: "You don't have permission to close this budget")
        }

        budget.status = .completed
        try await budget.save(on: req.db)
        return budget.toDTO()
    }
    
    private static func computeStatus(spent: Double, allocated: Double) -> BudgetStatus {
        guard allocated > 0 else { return .active }
        let ratio = spent / allocated
        // Active: spending is under 80% of budget
        // Exceeded: spending is 80%+ of budget
        // Completed: reserved for manual close
        if ratio < 0.8 { return .active }
        return .exceeded
    }
}

extension Budget {
    func toDTO() -> BudgetResponseDTO {
        BudgetResponseDTO(
            id: self.id,
            name: self.name,
            allocatedAmount: self.allocatedAmount,
            category: self.category,
            status: self.status.rawValue
        )
    }
}
