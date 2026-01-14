import Vapor

final class AIController {
    private let service: AIServiceProtocol

    init(service: AIServiceProtocol? = nil) {
        // Try to initialize Groq service, fall back to mock if API key not configured
        if let service = service {
            self.service = service
        } else if let groqService = try? GroqAIService() {
            self.service = groqService
        } else {
            print("⚠️ Warning: GROQ_API_KEY not configured, using MockAIService")
            self.service = MockAIService()
        }
    }

    func chat(_ req: Request) async throws -> AIChatResponse {
        let dto = try req.content.decode(AIChatRequest.self)
        let user = try req.authUser
        let reply = try await service.sendMessage(req, message: dto.userMessage, user: user)
        return AIChatResponse(reply: reply)
    }
}
