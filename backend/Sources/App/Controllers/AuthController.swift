import Vapor

final class AuthController {
    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol = AuthService()) {
        self.service = service
    }

    func register(_ req: Request) async throws -> LoginResponse {
        try RegisterRequest.validate(content: req)
        let dto = try req.content.decode(RegisterRequest.self)
        let token = try await service.register(req, data: dto)
        return LoginResponse(token: token)
    }

    struct LoginResponse: Content {
        let token: String
    }

    func login(_ req: Request) async throws -> LoginResponse {
        try LoginRequest.validate(content: req)
        let dto = try req.content.decode(LoginRequest.self)
        let token = try await service.login(req, data: dto)
        return LoginResponse(token: token)
    }

    func me(_ req: Request) async throws -> UserProfileResponse {
        let user = try req.authUser
        return UserProfileResponse(
            id: user.id,
            fullName: user.fullName,
            email: user.email,
            phoneNumber: user.phoneNumber,
            createdAt: user.createdAt
        )
    }

    func updateProfile(_ req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(UpdateProfileRequest.self)
        return try await service.updateProfile(req, data: dto)
    }
}
