// MARK: Расширения для работы с данными и разными форматами

import Foundation
import SwiftUI

//Список категорий
extension String {
    var expenseCategoryColor: Color {
        switch self {
        case "Кофейни": return .orange
        case "Магазины": return .blue
        case "Транспорт": return .purple
        case "Доставка": return .brown
        case "Развлечения": return .green
        case "Пополнение": return .teal
        case "ЖКХ": return .pink
        case "Переводы": return .red
        case "Другие": return .mint
        default: return .gray
        }
    }
}

//Формат работы с датами
extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate]
        return formatter.string(from: self)
    }
}

//Формат для работы с массивами без повторяющихся элементов, сохраняя оригинальный порядок появления
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

//Формат для работы с данными
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
