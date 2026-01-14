import Vapor
import Fluent

protocol AIServiceProtocol {
    func sendMessage(_ req: Request, message: String, user: User) async throws -> String
}

/// Default mock implementation. In production you can swap this for a real provider.
struct MockAIService: AIServiceProtocol {
    func sendMessage(_ req: Request, message: String, user: User) async throws -> String {
        // In a real implementation, forward to an external AI API here.
        return "This is a mock AI response to: \(message)"
    }
}

/// Groq AI Service Implementation
struct GroqAIService: AIServiceProtocol {
    private let apiKey: String
    private let model = "llama-3.1-8b-instant"
    
    init() throws {
        guard let key = Environment.get("GROQ_API_KEY"), !key.isEmpty else {
            throw Abort(.internalServerError, reason: "GROQ_API_KEY not configured")
        }
        self.apiKey = key
    }
    
    func sendMessage(_ req: Request, message: String, user: User) async throws -> String {
        // Build financial context
        let context = try await buildFinancialContext(req, user: user)
        
        // Create system prompt with context
        let systemPrompt = """
        You are Moneta AI, a helpful financial advisor assistant for \(user.fullName). 
        You provide personalized financial advice based on their real transaction data.
        
        User's Financial Summary:
        \(context)
        
        Guidelines:
        - Be concise and actionable
        - Provide specific recommendations based on their data
        - Use friendly, encouraging tone
        - Focus on practical money management tips
        - Keep responses under 150 words
        """
        
        // Prepare Groq API request
        let url = "https://api.groq.com/openai/v1/chat/completions"
        
        let requestBody = GroqRequest(
            model: model,
            messages: [
                GroqMessage(role: "system", content: systemPrompt),
                GroqMessage(role: "user", content: message)
            ],
            temperature: 0.7,
            maxTokens: 500
        )
        
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        
        let response = try await req.client.post(
            URI(string: url),
            headers: headers,
            beforeSend: { try $0.content.encode(requestBody) }
        )
        
        guard response.status == HTTPStatus.ok else {
            req.logger.error("Groq API error: \(response.status)")
            throw Abort(.internalServerError, reason: "AI service unavailable")
        }
        
        let groqResponse = try response.content.decode(GroqResponse.self)
        
        guard let content = groqResponse.choices.first?.message.content else {
            throw Abort(.internalServerError, reason: "Invalid AI response")
        }
        
        return content
    }
    
    private func buildFinancialContext(_ req: Request, user: User) async throws -> String {
        // Get recent transactions
        let transactions = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .sort(\.$createdAt, .descending)
            .limit(20)
            .all()
        
        // Calculate totals
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }
        let balance = totalIncome - totalExpenses
        
        // Get budgets
        let budgets = try await Budget.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .all()
        
        // Category breakdown
        var categorySpending: [String: Double] = [:]
        for transaction in transactions where transaction.type == .expense {
            categorySpending[transaction.category, default: 0] += transaction.amount
        }
        
        let topCategories = categorySpending.sorted { $0.value > $1.value }.prefix(5)
        let categoryText = topCategories.map { "\($0.key): $\(String(format: "%.2f", $0.value))" }.joined(separator: ", ")
        
        return """
        Total Income: $\(String(format: "%.2f", totalIncome))
        Total Expenses: $\(String(format: "%.2f", totalExpenses))
        Current Balance: $\(String(format: "%.2f", balance))
        Active Budgets: \(budgets.count)
        Recent Transactions: \(transactions.count)
        Top Spending Categories: \(categoryText.isEmpty ? "None yet" : categoryText)
        """
    }
}

// Groq API Request Models
struct GroqRequest: Content {
    let model: String
    let messages: [GroqMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct GroqMessage: Content {
    let role: String?
    let content: String
}

// Groq API Response Models
struct GroqResponse: Content {
    let choices: [GroqChoice]
}

struct GroqChoice: Content {
    let message: GroqMessage
}
