import Foundation

enum APIClientError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int, String?)
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL

    private init() {
        self.baseURL = URL(string: "http://localhost:8080")!
    }

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = TokenStore.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try JSONEncoder.api.encode(AnyEncodable(body))
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw APIClientError.httpError(http.statusCode, message)
        }

        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        return try JSONDecoder.api.decode(T.self, from: data)
    }
}

struct EmptyResponse: Decodable {
    init() {}
}

private struct AnyEncodable: Encodable {
    private let encodeImpl: (Encoder) throws -> Void

    init(_ encodable: Encodable) {
        self.encodeImpl = { encoder in
            try encodable.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeImpl(encoder)
    }
}

private extension JSONEncoder {
    static var api: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var api: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
