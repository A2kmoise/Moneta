import Foundation

struct LoginResponseDTO: Decodable {
    let token: String
}

struct RegisterRequestDTO: Encodable {
    let fullName: String
    let email: String
    let phoneNumber: String
    let password: String
}

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct UpdateProfileRequestDTO: Encodable {
    let fullName: String?
    let currentPassword: String?
    let password: String?
}

struct UserProfileDTO: Decodable {
    let id: String?
    let fullName: String
    let email: String
    let phoneNumber: String
    let createdAt: Date?
}

final class AuthAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func register(fullName: String, email: String, phoneNumber: String, password: String) async throws -> String {
        let dto = RegisterRequestDTO(fullName: fullName, email: email, phoneNumber: phoneNumber, password: password)
        let response: LoginResponseDTO = try await client.request("/auth/register", method: "POST", body: dto, requiresAuth: false)
        TokenStore.shared.token = response.token
        return response.token
    }

    func login(email: String, password: String) async throws -> String {
        let dto = LoginRequestDTO(email: email, password: password)
        let response: LoginResponseDTO = try await client.request("/auth/login", method: "POST", body: dto, requiresAuth: false)
        TokenStore.shared.token = response.token
        return response.token
    }

    func me() async throws -> UserProfileDTO {
        try await client.request("/auth/me")
    }

    func updateProfile(fullName: String?, currentPassword: String?, password: String?) async throws {
        let dto = UpdateProfileRequestDTO(fullName: fullName, currentPassword: currentPassword, password: password)
        let _: EmptyResponse = try await client.request("/auth/profile", method: "PUT", body: dto)
    }

    func logout() {
        TokenStore.shared.clear()
    }
}
