// MARK: Основной сервис работы с транзакциями

import Foundation

final class TransactionService {
    static let shared = TransactionService()
    private init() {}

    // Загрузка PDF-выписки и возврат транзакций
    func uploadStatement(fileURL: URL, bank: String, token: String, completion: @escaping (Result<[Transaction], Error>) -> Void) {
        let boundary = UUID().uuidString
        let url = URL(string: "http://10.255.255.239:8000/transactions/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let fileData = try? Data(contentsOf: fileURL) else {
            completion(.failure(NSError(domain: "Invalid file", code: -2)))
            return
        }

        let filename = fileURL.lastPathComponent
        let mimeType = "application/pdf"
        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"bank\"\r\n\r\n")
        body.append("\(bank)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n")

        let task = URLSession.shared.uploadTask(with: request, from: body) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Empty response", code: -3)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
                let transactions = decoded.transactions.map { tx in
                    Transaction(
                        id: tx.id,
                        date: tx.date,
                        time: tx.time,
                        amount: tx.amount,
                        isIncome: tx.isIncome,
                        description: tx.description,
                        category: tx.category,
                        bank: tx.bank
                    )
                }
                completion(.success(transactions))
            } catch {
                // Пробуем декодировать {"detail": "..."}
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorResponse["detail"] {
                    print("❌ Сервер вернул ошибку: \(message)")
                    let serverError = NSError(domain: "Server", code: 400, userInfo: [NSLocalizedDescriptionKey: message])
                    completion(.failure(serverError))
                } else {
                    print("❌ Ошибка декодирования JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }


    // Обновление категории транзакции
    func updateCategory(transactionID: Int, to category: String, token: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://10.255.255.239:8000/transactions/\(transactionID)/category") else {
            completion?(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = ["category": category]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion?(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion?(.failure(URLError(.badServerResponse)))
                    return
                }

                completion?(.success(()))
            }
        }.resume()
    }


    // Получение всех транзакций
    func fetchAll(token: String, completion: @escaping (Result<[Transaction], Error>) -> Void) {
        guard let url = URL(string: "http://10.255.255.239:8000/transactions/history") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Empty data", code: -2)))
                return
            }

            do {
                let transactions = try JSONDecoder().decode([Transaction].self, from: data)
                completion(.success(transactions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    //Для дозагрузки выписок на странице "Загрузки выписок"
    func uploadStatementSimple(fileURL: URL, bank: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let boundary = UUID().uuidString
        let url = URL(string: "http://10.255.255.239:8000/transactions/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard fileURL.startAccessingSecurityScopedResource() else {
            completion(.failure(NSError(domain: "Security access failed", code: -9)))
            return
        }
        defer { fileURL.stopAccessingSecurityScopedResource() }

        guard let fileData = try? Data(contentsOf: fileURL) else {
            completion(.failure(NSError(domain: "Invalid file", code: -2)))
            return
        }

        let filename = fileURL.lastPathComponent
        let mimeType = "application/pdf"
        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"bank\"\r\n\r\n")
        body.append("\(bank)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n")

        URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "No response", code: -1)))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                let error = NSError(
                    domain: "ServerError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: serverMessage]
                )
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }.resume()
    }


    
    // Получение всех выписок
    func fetchStatements(token: String, completion: @escaping (Result<[Statement], Error>) -> Void) {
        guard let url = URL(string: "http://10.255.255.239:8000/statements") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Empty data", code: -2)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Statement].self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Ошибка декодирования: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
