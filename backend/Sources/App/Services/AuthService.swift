import Vapor
import Fluent
import JWT

struct AuthPayload: JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

protocol AuthServiceProtocol {
    func register(_ req: Request, data: RegisterRequest) async throws -> String
    func login(_ req: Request, data: LoginRequest) async throws -> String
    func updateProfile(_ req: Request, data: UpdateProfileRequest) async throws -> HTTPStatus
}

struct AuthService: AuthServiceProtocol {
    func register(_ req: Request, data: RegisterRequest) async throws -> String {
        let existing = try await User.query(on: req.db)
            .filter(\.$email == data.email.lowercased())
            .first()
        if existing != nil {
            throw Abort(.badRequest, reason: "Email is already registered")
        }

        guard Self.isStrongPassword(data.password) else {
            throw Abort(.badRequest, reason: "make a strong password")
        }

        let hash = try Bcrypt.hash(data.password)
        let user = User(
            fullName: data.fullName,
            email: data.email.lowercased(),
            phoneNumber: data.phoneNumber,
            passwordHash: hash
        )
        try await user.save(on: req.db)

        let expiration = ExpirationClaim(value: .init(timeIntervalSinceNow: 60 * 60 * 24))
        let payload = AuthPayload(subject: .init(value: try user.requireID().uuidString), expiration: expiration)
        return try req.jwt.sign(payload)
    }

    func login(_ req: Request, data: LoginRequest) async throws -> String {
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == data.email.lowercased())
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }

        let isValid = try Bcrypt.verify(data.password, created: user.passwordHash)
        guard isValid else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }

        let expiration = ExpirationClaim(value: .init(timeIntervalSinceNow: 60 * 60 * 24))
        let payload = AuthPayload(subject: .init(value: try user.requireID().uuidString), expiration: expiration)
        let token = try req.jwt.sign(payload)
        return token
    }

    func updateProfile(_ req: Request, data: UpdateProfileRequest) async throws -> HTTPStatus {
        let user = try req.authUser

        if let fullName = data.fullName {
            user.fullName = fullName
        }

        if let password = data.password {
            // Verify current password before allowing password change
            guard let currentPassword = data.currentPassword else {
                throw Abort(.badRequest, reason: "Current password is required to change password")
            }
            
            let isValid = try Bcrypt.verify(currentPassword, created: user.passwordHash)
            guard isValid else {
                throw Abort(.unauthorized, reason: "Current password is incorrect")
            }
            
            guard Self.isStrongPassword(password) else {
                throw Abort(.badRequest, reason: "make a strong password")
            }
            let hash = try Bcrypt.hash(password)
            user.passwordHash = hash
        }

        try await user.save(on: req.db)
        return .ok
    }

    private static func isStrongPassword(_ password: String) -> Bool {
        guard password.count >= 6 else { return false }
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        return hasLetter && hasNumber
    }
}
