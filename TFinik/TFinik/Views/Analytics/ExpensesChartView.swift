// MARK: диаграмма расходов (аналитика трат)

import SwiftUI
import Charts

struct ExpensesChartView: View {
    @State private var isLoading = true
    @State private var loadedTotalSpent: Double = 0
    @State private var loadedPeriodStart: String = ""
    @State private var loadedPeriodEnd: String = ""
    @State private var loadedCategories: [ExpenseCategory] = []
    @State private var isUnauthorized = false
    @State private var noRecentData = false

    var body: some View {
        ZStack {
            BackgroundView()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if noRecentData {
                VStack(spacing: 16) {
                    Text("⚠️")
                        .font(.system(size: 48))
                    Text("Ваши выписки слишком старые")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Пожалуйста, загрузите новые выписки за последние 30 дней.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 300)
            } else {
                VStack(spacing: 24) {
                    HStack {
                        Text("💰")
                            .font(.system(size: 32))
                        Text("Анализ расходов")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.top, 110)

                    if !loadedCategories.isEmpty {
                        PieChartView(categories: loadedCategories)
                            .frame(height: 250)
                            .padding(.top, 8)
                    }


                    VStack(spacing: 4) {
                        Text("Траты за период (\(loadedPeriodStart.isEmpty ? "—" : loadedPeriodStart) — \(loadedPeriodEnd.isEmpty ? "—" : loadedPeriodEnd))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(Int(loadedTotalSpent))₽")
                            .font(.title.bold())
                            .foregroundColor(.white)
                    }

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
        .fullScreenCover(isPresented: $isUnauthorized) {
            LoginView()
        }
        .navigationBarBackButtonHidden(false)
        .ignoresSafeArea()
        .onAppear {
            Task {
                await loadAnalytics()
            }
        }
    }

    @MainActor
    private func loadAnalytics() async {
        isLoading = true

        switch await AnalyticsService.shared.fetchCategoryAnalytics() {
        case .success(let data):
            handleDecoded(data)
        case .failure(let error):
            switch error {
            case .unauthorized:
                isUnauthorized = true
            default:
                print("❌ Ошибка загрузки аналитики: \(error)")
            }
        }
    }


    private func handleDecoded(_ decoded: AnalyticsResponse) {
        self.loadedTotalSpent = decoded.totalSpent
        self.loadedPeriodStart = decoded.period.start ?? ""
        self.loadedPeriodEnd = decoded.period.end ?? ""
        self.loadedCategories = decoded.categories.map {
            ExpenseCategory(
                name: $0.category,
                amount: $0.amount,
                color: $0.category.expenseCategoryColor
            )
        }
        self.noRecentData = decoded.categories.isEmpty
        self.isLoading = false
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
