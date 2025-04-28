import SwiftUI
import Charts

// MARK: - Модель категории расходов
struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

// MARK: - Модель ответа аналитики
struct AnalyticsResponse: Codable {
    let totalSpent: Double
    let period: Period
    let categories: [CategoryData]

    struct Period: Codable {
        let start: String
        let end: String
    }

    struct CategoryData: Codable {
        let category: String
        let amount: Double
    }
}

// MARK: - Основной экран аналитики расходов
struct ExpensesChartView: View {
    @State private var isLoading = true
    @State private var loadedTotalSpent: Double = 0
    @State private var loadedPeriodStart: String = ""
    @State private var loadedPeriodEnd: String = ""
    @State private var loadedCategories: [ExpenseCategory] = []

    var body: some View {
        ZStack {
            BackgroundView()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                VStack(spacing: 24) {
                    Text("\u{1F4B0}")
                        .font(.system(size: 40))
                        .padding(.top, 40)

                    Text("Аналитика по тратам")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    PieChartView(categories: loadedCategories)
                        .frame(height: 250)
                        .padding(.top, 8)

                    VStack(spacing: 4) {
                        Text("Траты за период (\(loadedPeriodStart) — \(loadedPeriodEnd))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(Int(loadedTotalSpent))₽")
                            .font(.title.bold())
                            .foregroundColor(.white)
                    }

                    // Используем ForEach для отображения только действительных категорий
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(loadedCategories) { category in
                                HStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 12, height: 12)
                                    Text(category.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(category.amount))₽")
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(false)
        .ignoresSafeArea()
        .onAppear {
            loadAnalytics()
        }
    }

    private func loadAnalytics() {
        if TokenStorage.shared.accessToken == nil {
            TokenStorage.shared.accessToken = KeychainHelper.shared.readAccessToken()
        }
        guard let url = URL(string: "http://127.0.0.1:8000/analytics/categories"),
              let token = TokenStorage.shared.accessToken else {
            print("❌ URL или токен не найдены")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка запроса: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ Нет данных в ответе")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(AnalyticsResponse.self, from: data)

                DispatchQueue.main.async {
                    self.loadedTotalSpent = decoded.totalSpent
                    self.loadedPeriodStart = decoded.period.start
                    self.loadedPeriodEnd = decoded.period.end
                    self.loadedCategories = decoded.categories.map { cat in
                        ExpenseCategory(
                            name: cat.category,
                            amount: cat.amount,
                            color: randomColor(for: cat.category)
                        )
                    }
                    self.isLoading = false
                }
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                if let json = String(data: data, encoding: .utf8) {
                    print("Ответ сервера: \(json)")
                }
            }
        }.resume()
    }

    private func randomColor(for category: String) -> Color {
        let colors: [Color] = [.green, .purple, .yellow, .orange, .blue, .pink, .red]
        return colors[abs(category.hashValue) % colors.count]
    }
}

// MARK: - Кастомная PieChart диаграмма
struct PieChartView: View {
    let categories: [ExpenseCategory]

    var body: some View {
        Chart {
            ForEach(categories) { category in
                SectorMark(
                    angle: .value("Amount", category.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(category.color)
                .cornerRadius(4)
            }
        }
        .chartBackground { proxy in
            GeometryReader { geo in
                VStack {
                    Text("Потрачено")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(categories.map { $0.amount }.reduce(0, +)))₽")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
    }
}
