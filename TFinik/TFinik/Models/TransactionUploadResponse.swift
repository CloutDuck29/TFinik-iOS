import Foundation

struct TransactionUploadResponse: Codable {
    let period: Period
    let transactions: [TransactionUploadTransaction]
}

struct Period: Codable {
    let start: String?
    let end: String?
}
