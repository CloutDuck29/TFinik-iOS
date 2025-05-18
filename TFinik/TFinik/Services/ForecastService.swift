import Foundation

// MARK: - Модель одного пункта прогноза
struct ExpenseForecastItem: Codable, Identifiable {
    var id: String { month }
    let month: String
    let amount: Double
}

// MARK: - Модель транзакции для прогноза (что уходит на backend)
struct TransactionForForecast: Codable {
    let date: String
    let cost: Double
    let isIncome: Bool
    let category: String

    enum CodingKeys: String, CodingKey {
        case date
        case cost
        case isIncome = "is_income" // 👈 важно!
        case category
    }
}

// MARK: - Обёртка запроса
struct ForecastPayload: Codable {
    let transactions: [TransactionForForecast]
}

// MARK: - ForecastService
final class ForecastService {
    static let shared = ForecastService()

    func fetchForecast(transactions: [Transaction], completion: @escaping (Result<[ExpenseForecastItem], Error>) -> Void) {
        // Конвертация модели в нужную структуру
        let simplified = transactions.map {
            TransactionForForecast(
                date: $0.date,
                cost: $0.amount,
                isIncome: $0.isIncome,
                category: $0.category // ✅ добавлено
            )
        }

        let payload = ForecastPayload(transactions: simplified)

        guard let url = URL(string: "http://10.255.255.239:8000/forecast/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encodedData = try JSONEncoder().encode(payload)
            request.httpBody = encodedData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let decoded = try JSONDecoder().decode([String: [ExpenseForecastItem]].self, from: data)
                    completion(.success(decoded["forecast"] ?? []))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let rawText = String(data: data, encoding: .utf8) ?? "Unknown error"
                let error = NSError(domain: "Forecast API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: rawText])
                completion(.failure(error))
            }
        }.resume()
    }
}
