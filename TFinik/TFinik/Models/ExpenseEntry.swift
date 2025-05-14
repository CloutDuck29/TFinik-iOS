import Foundation

struct ExpenseEntry: Identifiable, Decodable, Equatable {
    let id = UUID()
    let month: String
    let category: String
    let amount: Double
    let description: String?
}
