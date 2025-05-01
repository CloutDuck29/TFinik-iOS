import Foundation

enum APIError: Error {
  case invalidResponse, statusCode(Int), decoding(Error)
}

final class APIClient {
  static let shared = APIClient()
  private let baseURL = URL(string: "http://169.254.202.90:8000")!  // или ваш прод‑URL

  func request<T: Decodable>(
    _ method: String = "GET",
    path: String,
    body: Data? = nil
  ) async throws -> T {
    var req = URLRequest(url: baseURL.appendingPathComponent(path))
    req.httpMethod = method
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = KeychainHelper.shared.readAccessToken() {
      req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    req.httpBody = body

    let (data, resp) = try await URLSession.shared.data(for: req)
    guard let http = resp as? HTTPURLResponse else {
      throw APIError.invalidResponse
    }
    guard (200..<300).contains(http.statusCode) else {
      throw APIError.statusCode(http.statusCode)
    }
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw APIError.decoding(error)
    }
  }
}
