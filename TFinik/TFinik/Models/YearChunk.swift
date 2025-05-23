// MARK: - модель для загруженных банковских выписок по годам и месяцам

import Foundation

struct YearChunk: Identifiable {
    var id = UUID()
    var year: Int
    var months: [Int: Bool]
}
