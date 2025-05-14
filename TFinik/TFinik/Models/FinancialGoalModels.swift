import Foundation

// MARK: - DTO (для работы с API)
struct FinancialGoalDTO: Codable, Identifiable {
    let id: Int
    let uuid: String
    let name: String
    let target_amount: Double
    let current_amount: Double
    let deadline: String?
    let user_email: String?

    func toModel() -> FinancialGoal {
        let parsedDeadline: Date? = {
            if let deadline = deadline {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate]
                return formatter.date(from: deadline)
            }
            return nil
        }()

        return FinancialGoal(
            id: UUID(uuidString: uuid) ?? UUID(),
            originalId: id,
            name: name,
            targetAmount: target_amount,
            currentAmount: current_amount,
            deadline: parsedDeadline
        )
    }
}

// MARK: - Модель для отображения в UI
struct FinancialGoal: Identifiable, Hashable {
    let id: UUID
    let originalId: Int
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let deadline: Date?
}
