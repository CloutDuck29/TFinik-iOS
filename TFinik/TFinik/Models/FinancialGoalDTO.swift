import Foundation

struct FinancialGoalDTO: Codable, Identifiable {
    let id: Int  // ✅ исправлено с String на Int
    let uuid: String  // если нужно — используешь UUID отдельно
    let name: String
    let target_amount: Double
    let current_amount: Double
    let deadline: String?
    let is_completed: Bool?
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
            isCompleted: is_completed ?? (current_amount >= target_amount),
            deadline: parsedDeadline
        )
    }
}
