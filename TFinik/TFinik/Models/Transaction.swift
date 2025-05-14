import Foundation

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
