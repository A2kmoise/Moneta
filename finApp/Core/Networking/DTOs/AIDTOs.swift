import Foundation

struct AIChatRequestDTO: Codable {
    let userMessage: String
}

struct AIChatResponseDTO: Codable {
    let reply: String
}
