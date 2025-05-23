// MARK: - Связующее звено между UI и сервисом портрета месяца (управляет портретом и уведомляет интерфейс об изменениях)

import Foundation

final class PortraitStore: ObservableObject {
    @Published var data: MonthPortraitResponse?
    @Published var isLoading = true
    @Published var month: Int
    @Published var year: Int

    init() {
        let now = Date()
        let calendar = Calendar.current
        self.month = calendar.component(.month, from: now)
        self.year = calendar.component(.year, from: now)
    }

    var formattedMonthYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"

        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1

        if let date = Calendar.current.date(from: comps) {
            return formatter.string(from: date).capitalized
        }
        return "\(month).\(year)"
    }

    func loadPortrait(token: String) {
        isLoading = true
        PortraitService.fetchPortrait(month: month, year: year, token: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.data = response
                case .failure(let error):
                    print("❌ Ошибка загрузки портрета: \(error)")
                }
            }
        }
    }

    func previousMonth(token: String) {
        if month == 1 {
            month = 12
            year -= 1
        } else {
            month -= 1
        }
        loadPortrait(token: token)
    }

    func nextMonth(token: String) {
        if month == 12 {
            month = 1
            year += 1
        } else {
            month += 1
        }
        loadPortrait(token: token)
    }
}
