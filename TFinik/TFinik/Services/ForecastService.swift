// MARK: - Прогнозирование расходов. Отправляет список транзакций на бэк и получает прогнозы трат по месяцам и по категориям.

import Foundation

// MARK: - Модель одного пункта прогноза
struct ExpenseForecastItem: Codable, Identifiable {
    var id: String { month } // Можно заменить на уникальный yearMonth, если есть
    let month: String        // соответствует ключу "month" из JSON
    let amount: Double
}

// MARK: - Обертка ответа прогноза
struct ForecastResponse: Codable {
    let forecast: [ExpenseForecastItem]
}

// MARK: - Модель категории прогноза
struct ExpenseForecastCategory: Codable, Identifiable {
    var id: String { category }
    let category: String
    let amount: Double
}

// MARK: - Обертка ответа прогноза по категориям
struct CategoryForecastResponse: Codable {
    let month: String
    let categories: [ExpenseForecastCategory]
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
        case isIncome = "is_income"
        case category
    }
}

// MARK: - Обертка запроса
struct ForecastPayload: Codable {
    let transactions: [TransactionForForecast]
}

final class ForecastService {
    static let shared = ForecastService()

// MARK: - Отправляет все транзакции на forecast и получает прогноз по месяцам.
    func fetchForecast(transactions: [Transaction], completion: @escaping (Result<[ExpenseForecastItem], Error>) -> Void) {
        let simplified = transactions.map {
            TransactionForForecast(
                date: $0.date,
                cost: $0.amount,
                isIncome: $0.isIncome,
                category: $0.category
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
                    let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
                    completion(.success(decoded.forecast))
                } catch {
                    let rawText = String(data: data, encoding: .utf8) ?? "Unknown response"
                    print("Decode error:", error, "Response:", rawText)
                    completion(.failure(error))
                }
            } else {
                let rawText = String(data: data, encoding: .utf8) ?? "Unknown error"
                let error = NSError(domain: "Forecast API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: rawText])
                completion(.failure(error))
            }
        }.resume()
    }
// MARK: - Отправляет все транзакции + параметр месяц на forecast/categories/month=.. Получает прогноз по категориям за выбранный месяц.
    func fetchCategoryForecast(month: String, transactions: [Transaction], completion: @escaping (Result<[ExpenseForecastCategory], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "http://10.255.255.239:8000/forecast/categories/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "month", value: month)]

        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        // Преобразуем модели транзакций в словари для JSON-сериализации
        let transactionsPayload = transactions.map {
            [
                "date": $0.date,
                "cost": $0.amount,
                "is_income": $0.isIncome,
                "category": $0.category
            ] as [String: Any]
        }

        let payloadDict = ["transactions": transactionsPayload]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payloadDict, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "HTTP", code: code)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CategoryForecastResponse.self, from: data)
                completion(.success(decoded.categories))
            } catch {
                let rawText = String(data: data, encoding: .utf8) ?? "Unknown response"
                print("Decode error:", error, "Response:", rawText)
                completion(.failure(error))
            }
        }.resume()
    }
}
