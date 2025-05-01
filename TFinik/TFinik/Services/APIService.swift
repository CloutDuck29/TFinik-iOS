import Foundation

func updateTransactionCategory(transactionID: Int, newCategory: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let accessToken = TokenStorage.shared.accessToken else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Нет токена"])))
        return
    }
    
    guard let url = URL(string: "http://169.254.202.90:8000/transactions/\(transactionID)") else {
        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Некорректный URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let body = ["category": newCategory]
    request.httpBody = try? JSONEncoder().encode(body)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                completion(.success(()))
            } else if response.statusCode == 401 {
                print("⚠️ Access токен истёк, пытаемся обновить")
                AuthService().refreshAccessTokenIfNeeded { success in
                    if success {
                        print("✅ Токен обновлён, повторяем обновление категории")
                        updateTransactionCategory(transactionID: transactionID, newCategory: newCategory, completion: completion)
                    } else {
                        print("❌ Не удалось обновить токен")
                        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Не удалось обновить токен"])))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера: \(response.statusCode)"])))
            }
        }
    }.resume()
}
