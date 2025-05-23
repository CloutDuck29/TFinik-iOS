// MARK: Основной сервис работы с аналитикой с сервера

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

    //Получает категории и суммы трат
    func fetchCategoryAnalytics() async -> Result<AnalyticsResponse, AnalyticsError> {
        await fetch(endpoint: "/analytics/categories", as: AnalyticsResponse.self)
    }

    //Получает расходы по категориям помесячно
    func fetchMonthlyAnalytics() async -> Result<[ExpenseEntry], AnalyticsError> {
        await fetch(endpoint: "/analytics/monthly", as: [ExpenseEntry].self)
    }
    
    //Получает доходы по месяцам
    func fetchIncomeAnalytics() async -> Result<[IncomeEntry], AnalyticsError> {
        await fetch(endpoint: "/analytics/income", as: [IncomeEntry].self)
    }

    //Универсальная функция для выполнения сетевых запросов к API и парсинга ответа (один раз пишешь и затем вызываешь с нужной моделью, как выше)
    private func fetch<T: Decodable>(endpoint: String, as type: T.Type) async -> Result<T, AnalyticsError> {
        guard let token = KeychainHelper.shared.readAccessToken(),
              let url = URL(string: "http://10.255.255.239:8000\(endpoint)") else {
            return .failure(.invalidResponse)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch let decodingError as DecodingError {
            return .failure(.decoding(decodingError))
        } catch {
            return .failure(.request(error))
        }
    }
}
