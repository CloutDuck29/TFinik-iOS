// MARK: Расширения для работы с данными и разными форматами

import Foundation
import SwiftUI

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

extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate]
        return formatter.string(from: self)
    }
}


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
