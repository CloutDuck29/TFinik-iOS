import Foundation
import Combine

class GoalStore: ObservableObject {
    @Published var goals: [FinancialGoalDTO] = []

    func createGoal(name: String, targetAmount: Double, deadline: Date?) {
        guard let token = TokenStorage.shared.accessToken else {
            print("❌ Нет токена")
            return
        }

        guard let url = URL(string: "http://10.255.255.239:8000/goals/") else {
            print("❌ Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var payload: [String: Any] = [
            "name": name,
            "target_amount": targetAmount
        ]

        if let deadline = deadline {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            payload["deadline"] = formatter.string(from: deadline)
        }


        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка при создании цели: \(error.localizedDescription)")
                return
            }

            print("✅ Цель успешно создана")
            DispatchQueue.main.async {
                self.fetchGoals() // Обновить список
            }
        }.resume()
    }

    func updateGoal(id: Int, name: String?, targetAmount: Double?, deadline: Date?) {
        guard let token = TokenStorage.shared.accessToken else {
            print("❌ Нет токена")
            return
        }

        guard let url = URL(string: "http://10.255.255.239:8000/goals/\(id)") else {
            print("❌ Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var payload: [String: Any] = [:]
        if let name = name {
            payload["name"] = name
        }
        if let targetAmount = targetAmount {
            payload["target_amount"] = targetAmount
        }
        if let deadline = deadline {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            payload["deadline"] = formatter.string(from: deadline)
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка при обновлении цели: \(error.localizedDescription)")
                return
            }

            print("✅ Цель обновлена")
            DispatchQueue.main.async {
                self.fetchGoals()
            }
        }.resume()
    }

    
    func addAmount(to goalId: Int, amount: Double) {
        guard let token = TokenStorage.shared.accessToken else {
            print("❌ Нет токена")
            return
        }

        guard let url = URL(string: "http://10.255.255.239:8000/goals/\(goalId)/add") else {
            print("❌ Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["amount": amount]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка при добавлении суммы: \(error.localizedDescription)")
                return
            }

            print("✅ Сумма добавлена к цели")
            DispatchQueue.main.async {
                self.fetchGoals()
            }
        }.resume()
    }

    
    func fetchGoals() {
        guard let token = TokenStorage.shared.accessToken else {
            print("❌ Токен не найден")
            return
        }

        guard let url = URL(string: "http://10.255.255.239:8000/goals") else {
            print("❌ Неверный URL")
            return
        }

        var request = URLRequest(url: URL(string: "http://10.255.255.239:8000/goals/")!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка загрузки целей: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ Данные отсутствуют")
                return
            }

            do {
                let goals = try JSONDecoder().decode([FinancialGoalDTO].self, from: data)
                DispatchQueue.main.async {
                    self.goals = goals
                }
            } catch {
                print("❌ Ошибка декодирования: \(error)")
                if let str = String(data: data, encoding: .utf8) {
                    print("Ответ: \(str)")
                }
            }
        }.resume()
    }
}
