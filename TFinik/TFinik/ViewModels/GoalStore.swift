// MARK: - Связующее звено между UI и сервисом целей (управляет целями и уведомляет интерфейс об изменениях)
import Foundation
import Combine

class GoalStore: ObservableObject {
    @Published var goals: [FinancialGoalDTO] = []

    private let service = GoalService()

    func fetchGoals() {
        service.fetchGoals { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let goals):
                    self.goals = goals
                case .failure(let error):
                    print("❌ Ошибка загрузки целей: \(error.localizedDescription)")
                }
            }
        }
    }

    func createGoal(name: String, targetAmount: Double, deadline: Date?) {
        service.createGoal(name: name, targetAmount: targetAmount, deadline: deadline) { result in
            if case .success = result {
                DispatchQueue.main.async {
                    self.fetchGoals()
                }
            }
        }
    }

    func updateGoal(id: Int, name: String?, targetAmount: Double?, deadline: Date?) {
        service.updateGoal(id: id, name: name, targetAmount: targetAmount, deadline: deadline) { result in
            if case .success = result {
                DispatchQueue.main.async {
                    self.fetchGoals()
                }
            }
        }
    }

    func addAmount(to goalId: Int, amount: Double) {
        service.addAmount(to: goalId, amount: amount) { result in
            if case .success = result {
                DispatchQueue.main.async {
                    self.fetchGoals()
                }
            }
        }
    }
}
