import Foundation

// MARK: - Общая модель транзакции
struct Transaction: Identifiable, Codable {
    var id: Int
    let date: String
    let time: String?
    var amount: Double
    var isIncome: Bool
    var description: String
    var category: String
    var bank: String
}

// MARK: - Для отправки на сервер
struct TransactionUploadTransaction: Codable {
    let date: String
    let time: String?
    let amount: Double
    let isIncome: Bool
    let description: String
    let category: String
    let bank: String
}

// MARK: - Ответ от сервера после загрузки
struct UploadResponse: Codable {
    let period: Period
    let transactions: [ServerTransaction]
}

struct ServerTransaction: Codable {
    let id: Int
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
