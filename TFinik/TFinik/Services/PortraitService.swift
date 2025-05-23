// MARK: - основной сервис для работы с портретом месяца пользователя

import Foundation

enum PortraitAPIError: Error {
    case invalidURL
    case invalidResponse
    case decoding(Error)
    case network(Error)
}
// MARK: - отправляет get запрос, добавляет токен, получает json, возвращает результат
struct PortraitService {
    static func fetchPortrait(month: Int, year: Int, token: String, completion: @escaping (Result<MonthPortraitResponse, PortraitAPIError>) -> Void) {
        var components = URLComponents(string: "http://10.255.255.239:8000/portrait")!
        components.queryItems = [
            URLQueryItem(name: "month", value: "\(month)"),
            URLQueryItem(name: "year", value: "\(year)")
        ]

        guard let url = components.url else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.network(error)))
                    return
                }

                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(MonthPortraitResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decoding(error)))
                }
            }
        }.resume()
    }
}
