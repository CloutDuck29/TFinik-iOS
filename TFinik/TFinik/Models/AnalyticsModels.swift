//MARK: - модель данных для отображения категорий трат (с цветом и суммой), структура для парсинга ответа с бекенда с тратами (сумма, период, категории)

import SwiftUI

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct AnalyticsResponse: Codable {
    let totalSpent: Double
    let period: Period
    let categories: [CategoryData]

    struct Period: Codable {
        let start: String?
        let end: String?
    }

    struct CategoryData: Codable {
        let category: String
        let amount: Double
    }
}
