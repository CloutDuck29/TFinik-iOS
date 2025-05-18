import SwiftUI
import Charts

struct ExpenseForecastView: View {
    @State private var selectedMonth: String = ""
    @State private var forecastData: [ExpenseForecastItem] = []
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
                                y: .value("Сумма", abs(item.amount))  // используем абсолютное значение, чтобы столбцы росли вверх
                            )
                            .foregroundStyle(Color.purple)
                            .cornerRadius(10)  // скругление столбцов
                            .annotation(position: .top) {
                                Text("\(Int(item.amount))₽")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))  // скругление фона
                    }
                    .padding(.horizontal)
                }

                // Выбор месяца (Picker вместо DatePicker)
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
                    }
                }
                .padding(.horizontal)

                // Последние 3 транзакции (расходы)
                VStack(spacing: 0) {
                    let recentExpenses = transactionStore.transactions.filter { !$0.isIncome }.prefix(3)
                    ForEach(recentExpenses) { tx in
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.pink)
                                .frame(width: 30)
                            Text(tx.category)
                                .foregroundColor(.pink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(tx.date.prefix(7))
                                .foregroundColor(.gray)
                            Text("\(Int(tx.amount))₽")
                                .foregroundColor(.white)
                                .padding(.leading, 4)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)

                        if tx.id != recentExpenses.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if let firstMonth = forecastData.first?.month {
                selectedMonth = firstMonth
            }

            print("📊 Все транзакции:")
            for tx in transactionStore.transactions {
                print("🧾 \(tx.date) | \(tx.amount)₽ | isIncome: \(tx.isIncome) | \(tx.category)")
            }

            let expensesOnly = transactionStore.transactions.filter { !$0.isIncome }
            print("📦 Отправляем транзакций: \(expensesOnly.count)")
            expensesOnly.forEach {
                print("🧾 \($0.date) — \($0.amount)₽ — \($0.category)")
            }

            if expensesOnly.isEmpty {
                print("⚠️ Нет расходов для прогноза")
                return
            }

            ForecastService.shared.fetchForecast(transactions: expensesOnly) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let forecast):
                        self.forecastData = forecast
                        if let firstMonth = forecast.first?.month {
                            self.selectedMonth = firstMonth
                        }
                        print("✅ Forecast received:", forecast)
                    case .failure(let error):
                        print("❌ Forecast error:", error.localizedDescription)
                    }
                }
            }
        }
    }
}
