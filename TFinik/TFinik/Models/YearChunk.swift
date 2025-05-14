import Foundation

struct YearChunk: Identifiable {
    var id = UUID()
    var year: Int
    var months: [Int: Bool]
}
