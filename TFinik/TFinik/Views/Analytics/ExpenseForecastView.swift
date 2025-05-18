import SwiftUI
import Charts

struct ExpenseForecastView: View {
    @State private var selectedMonth: String = ""
    @State private var forecastData: [ExpenseForecastItem] = []
    @State private var forecastCategories: [ExpenseForecastCategory] = []
    @EnvironmentObject var transactionStore: TransactionStore

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("🔮")
                        Text("Прогноз расходов")
                            .bold()
                    }
                    .font(.title2)
                    .foregroundColor(.white)

                    Text("Прогноз на 3 месяца основан на тратах за последний год")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, -30)

                // Диаграмма прогноза
                if forecastData.isEmpty {
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 50)
                } else {
                    VStack {
                        Chart(forecastData) { item in
                            BarMark(
                                x: .value("Месяц", item.month),
                                y: .value("Сумма", abs(item.amount))
                            )
                            .foregroundStyle(Color.purple)
                            .cornerRadius(10)
                            .annotation(position: .top) {
                                Text("\(Int(item.amount))₽")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.horizontal)
                }

                // Выбор месяца
                HStack {
                    Text("Выберите месяц")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    if !forecastData.isEmpty {
                        Picker("Выберите месяц", selection: $selectedMonth) {
                            ForEach(forecastData.map { $0.month }, id: \.self) { month in
                                Text(month).tag(month)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: 300)
                        .onChange(of: selectedMonth) { newMonth in
                            loadCategories(for: newMonth)
                        }
                    }
                }
                .padding(.horizontal)

                // Топ-3 категории для выбранного месяца
                if forecastCategories.isEmpty {
                    Text("Загрузка категорий...")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Топ-3 категории трат за \(selectedMonth)")
                            .foregroundColor(.white)
                            .font(.headline)

                        ForEach(forecastCategories) { cat in
                            HStack {
                                Text(cat.category)
                                    .foregroundColor(.pink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(Int(cat.amount))₽")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if let firstMonth = forecastData.first?.month {
                selectedMonth = firstMonth
                loadCategories(for: firstMonth)
            }

            let expensesOnly = transactionStore.transactions.filter { !$0.isIncome }
            if expensesOnly.isEmpty {
                return
            }

            ForecastService.shared.fetchForecast(transactions: expensesOnly) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let forecast):
                        self.forecastData = forecast
                        if let firstMonth = forecast.first?.month {
                            self.selectedMonth = firstMonth
                            loadCategories(for: firstMonth)
                        }
                    case .failure(let error):
                        print("❌ Forecast error:", error.localizedDescription)
                    }
                }
            }
        }
    }

    private func loadCategories(for month: String) {
        let expensesOnly = transactionStore.transactions.filter { !$0.isIncome }
        if expensesOnly.isEmpty { return }

        ForecastService.shared.fetchCategoryForecast(month: month, transactions: Array(expensesOnly)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self.forecastCategories = categories
                case .failure(let error):
                    print("❌ Category forecast error:", error.localizedDescription)
                    self.forecastCategories = []
                }
            }
        }
    }
}
