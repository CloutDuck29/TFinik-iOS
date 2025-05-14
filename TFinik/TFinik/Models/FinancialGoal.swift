import Foundation

struct FinancialGoal: Identifiable, Hashable {
    let id: UUID
    let originalId: Int
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let deadline: Date?
}
