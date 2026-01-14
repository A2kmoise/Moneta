import Vapor

struct UpdateProfileRequest: Content {
    let fullName: String?
    let currentPassword: String?
    let password: String?
}
