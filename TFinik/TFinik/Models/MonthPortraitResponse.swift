import Foundation

struct MonthPortraitResponse: Decodable {
    struct Portrait: Decodable {
        let month: String?
        let year: Int?
        let balanced: Bool?
        let top_categories: [String]?
        let emoji: String?
        let mood: String?
        let summary: String?
        let status: String?
        let message: String?
    }

    struct Pattern: Decodable {
        let label: String
        let limit: Double
        let days_total: Int
        let weekdays: Int
        let weekends: Int
    }

    let portrait: Portrait
    let patterns: [Pattern]
}
