import Foundation

struct UploadResponse: Codable {
    let period: Period
    let transactions: [ServerTransaction]
}

struct ServerTransaction: Codable {
    let id: Int            // 🛠️ Добавляем сюда
    let date: String
    let time: String?
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
