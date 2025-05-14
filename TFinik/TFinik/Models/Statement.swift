import Foundation

struct Statement: Identifiable, Decodable {
    var id: Int
    var bank: String
    var date_start: String
    var date_end: String

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    var dateStartAsDate: Date? {
        Self.formatter.date(from: date_start)
    }

    var dateEndAsDate: Date? {
        Self.formatter.date(from: date_end)
    }
}
