import Foundation

struct TransactionUploadTransaction: Codable {
    let date: String
    let time: String?
    let amount: Double
    let isIncome: Bool
    let description: String
    let category: String
    let bank: String
}
