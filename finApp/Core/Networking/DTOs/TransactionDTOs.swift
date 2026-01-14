import Foundation

struct CreateTransactionDTO: Codable {
    let category: String
    let amount: Double
    let date: Date
}

struct CreateTransactionResponseDTO: Codable {
    let id: UUID?
    let type: String
    let category: String
    let amount: Double
    let date: Date
}
