import Foundation

struct GroqChatMessageDTO: Codable {
    let role: String
    let content: String
}

struct GroqChatRequestDTO: Codable {
    let model: String
    let messages: [GroqChatMessageDTO]
    let temperature: Double?
    let max_tokens: Int?
}

struct GroqChatResponseDTO: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String?
            let content: String
        }
        let message: Message
    }

    let choices: [Choice]
}
