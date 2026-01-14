import Vapor

struct UpdateTransactionDTO: Content {
    let type: String?
    let category: String?
    let amount: Double?
    let date: Date?
}
