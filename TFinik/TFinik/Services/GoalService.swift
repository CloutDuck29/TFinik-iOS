// MARK: - Основной сервис работы с целями (выполняет запросы к API)

import Foundation

class GoalService {
    private let baseURL = "http://10.255.255.239:8000"
    
// MARK: - общая функция для установки токена и создания запросов на сервер
    private func makeRequest(
        path: String,
        method: String,
        payload: [String: Any]? = nil
    ) -> URLRequest? {
        guard let token = TokenStorage.shared.accessToken else {
            print("❌ Нет токена")
            return nil
        }

        guard let url = URL(string: baseURL + path) else {
            print("❌ Неверный URL: \(baseURL + path)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let payload = payload {
            if let body = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) {
                request.httpBody = body
                print("📦 Payload:")
                print(String(data: body, encoding: .utf8) ?? "—")
            } else {
                print("❌ Не удалось сериализовать payload")
            }
        }

        print("🚀 Запрос:")
        print("➡️ \(method) \(url.absoluteString)")
        print("🪪 Заголовки: \(request.allHTTPHeaderFields ?? [:])")

        return request
    }
    
// MARK: - делает запрос get /goals, получает список целей, декодирует и возвращает
    func fetchGoals(completion: @escaping (Result<[FinancialGoalDTO], Error>) -> Void) {
        guard let request = makeRequest(path: "/goals/", method: "GET") else { return }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка fetchGoals: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("❌ fetchGoals: Пустой ответ от сервера")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пустой ответ"])))
                return
            }

            do {
                let goals = try JSONDecoder().decode([FinancialGoalDTO].self, from: data)
                print("✅ Успешно загружены цели (\(goals.count))")
                completion(.success(goals))
            } catch {
                print("❌ Ошибка декодирования целей: \(error)")
                if let str = String(data: data, encoding: .utf8) {
                    print("📨 Ответ от сервера:\n\(str)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
// MARK: - делает post запрос, отправляет имя, сумму и сроки, возвращает результат
    func createGoal(name: String, targetAmount: Double, deadline: Date?, completion: @escaping (Result<Void, Error>) -> Void) {
        var payload: [String: Any] = [
            "name": name,
            "target_amount": targetAmount
        ]

        if let deadline = deadline {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            payload["deadline"] = formatter.string(from: deadline)
        }

        guard let request = makeRequest(path: "/goals/", method: "POST", payload: payload) else { return }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Ошибка createGoal: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Цель успешно создана")
                completion(.success(()))
            }
        }.resume()
    }
// MARK: - делает patch запрос, обновляет имя, сумму, срок и возвращает
    func updateGoal(id: Int, name: String?, targetAmount: Double?, deadline: Date?, completion: @escaping (Result<Void, Error>) -> Void) {
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

        guard let request = makeRequest(path: "/goals/\(id)", method: "PATCH", payload: payload) else { return }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Ошибка updateGoal: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Цель обновлена")
                completion(.success(()))
            }
        }.resume()
    }
// MARK: - делает post запрос, добавляет сумму в цель, возвращает результат
    func addAmount(to goalId: Int, amount: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = ["amount": amount]
        guard let request = makeRequest(path: "/goals/\(goalId)/add", method: "POST", payload: payload) else { return }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Ошибка addAmount: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Сумма успешно добавлена")
                completion(.success(()))
            }
        }.resume()
    }
}
