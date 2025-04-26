import Foundation

struct UploadResponse: Codable {
    let period: Period
    let transactions: [ServerTransaction]
}

struct ServerTransaction: Codable {
    let date: String
    let time: String?      // обязательно, потому что твоя Transaction ожидает time
    let amount: Double
    let isIncome: Bool
    let description: String
    let category: String
    let bank: String
}

struct Period: Codable {
    let start: String
    let end: String
}
