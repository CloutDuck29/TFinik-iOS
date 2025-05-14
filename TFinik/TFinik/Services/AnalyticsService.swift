// MARK: Основной сервис работы с аналитикой

import Foundation

enum AnalyticsError: Error {
    case unauthorized
    case invalidResponse
    case decoding(Error)
    case request(Error)
}

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    func fetchCategoryAnalytics() async -> Result<AnalyticsResponse, AnalyticsError> {
        if TokenStorage.shared.accessToken == nil {
            TokenStorage.shared.accessToken = KeychainHelper.shared.readAccessToken()
        }

        guard let token = TokenStorage.shared.accessToken,
              let url = URL(string: "http://10.255.255.239:8000/analytics/categories") else {
            return .failure(.invalidResponse)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            if httpResponse.statusCode == 401 {
                let refreshed = await AuthService().refreshAccessTokenIfNeeded()
                return refreshed ? await fetchCategoryAnalytics() : .failure(.unauthorized)
            }

            let decoded = try JSONDecoder().decode(AnalyticsResponse.self, from: data)
            return .success(decoded)

        } catch let decoding as DecodingError {
            return .failure(.decoding(decoding))
        } catch {
            return .failure(.request(error))
        }
    }
}
