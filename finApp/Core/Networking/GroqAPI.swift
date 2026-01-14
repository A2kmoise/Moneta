import Foundation

enum GroqAPIError: Error {
    case missingAPIKey
    case invalidResponse
    case httpError(Int, String?)
}

final class GroqAPI {
    private let baseURL = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    /// Reads the key from the app's Info dictionary.
    /// Add `GROQ_API_KEY` in Target -> Info (Custom iOS Target Properties) or via an xcconfig build setting.
    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String
    }

    func sendMessage(systemPrompt: String, messages: [GroqChatMessageDTO]) async throws -> String {
        guard let apiKey, !apiKey.isEmpty else {
            throw GroqAPIError.missingAPIKey
        }

        var fullMessages: [GroqChatMessageDTO] = []
        if !systemPrompt.isEmpty {
            fullMessages.append(.init(role: "system", content: systemPrompt))
        }
        fullMessages.append(contentsOf: messages)

        let body = GroqChatRequestDTO(
            model: "llama-3.1-8b-instant",
            messages: fullMessages,
            temperature: 0.7,
            max_tokens: 500
        )

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw GroqAPIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw GroqAPIError.httpError(http.statusCode, message)
        }

        let decoded = try JSONDecoder().decode(GroqChatResponseDTO.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw GroqAPIError.invalidResponse
        }
        return content
    }
}
