import Vapor

struct UserProfileResponse: Content {
    let id: UUID?
    let fullName: String
    let email: String
    let phoneNumber: String
    let createdAt: Date?
}
