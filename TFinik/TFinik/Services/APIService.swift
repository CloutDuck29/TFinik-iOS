import Foundation

func updateTransactionCategory(transactionID: Int, newCategory: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let accessToken = KeychainHelper.shared.readAccessToken() else {
        completion(.failure(NSError(domain: "No token", code: -1)))
        return
    }

    let url = URL(string: "http://127.0.0.1:8000/transactions/\(transactionID)")!
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let body = ["category": newCategory]
    request.httpBody = try? JSONEncoder().encode(body)

    URLSession.shared.dataTask(with: request) { _, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(()))
    }.resume()
}
