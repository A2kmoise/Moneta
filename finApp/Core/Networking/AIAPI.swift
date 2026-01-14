import Foundation

final class AIAPI {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func sendMessage(_ message: String) async throws -> String {
        let dto = AIChatRequestDTO(userMessage: message)
        let response: AIChatResponseDTO = try await client.request("/ai/chat", method: "POST", body: dto)
        return response.reply
    }
}
