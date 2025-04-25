import Foundation

struct TransactionUploadTransaction: Codable {
    let bank: String
    let date: String
    let description: String
    let amount: Double
    let isIncome: Bool
    let category: String
}
