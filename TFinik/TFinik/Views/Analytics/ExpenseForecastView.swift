import SwiftUI
import Charts

struct ExpenseForecastView: View {
    struct Forecast: Identifiable {
        let id = UUID()
        let month: String
        let amount: Double
    }

    struct ForecastDetail: Identifiable {
        let id = UUID()
        let category: String
        let month: String
        let amount: Double
    }

    @State private var selectedDate = Date()

    let forecastData = [
        Forecast(month: "Июнь", amount: 30000),
        Forecast(month: "Июль", amount: 60000),
        Forecast(month: "Август", amount: 190000)
    ]

    let details = [
        ForecastDetail(category: "Магазины", month: "Июнь", amount: -2500),
        ForecastDetail(category: "Магазины", month: "Июнь", amount: -2500),
        ForecastDetail(category: "Магазины", month: "Июнь", amount: -2500)
    ]

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

                // Диаграмма
                VStack {
                    Chart(forecastData) { item in
                        BarMark(
                            x: .value("Месяц", item.month),
                            y: .value("Сумма", item.amount)
                        )
                        .foregroundStyle(Color.purple)
                        .cornerRadius(10)
                        .annotation(position: .top) {
                            Text("\(Int(item.amount)).000Р")
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

                // Заголовок + DatePicker
                HStack {
                    Text("Выберите месяц")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                .padding(.horizontal)

                // Список трат
                VStack(spacing: 0) {
                    ForEach(Array(details.enumerated()), id: \.element.id) { index, detail in
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.pink)
                                .frame(width: 30)
                            Text(detail.category)
                                .foregroundColor(.pink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(detail.month)
                                .foregroundColor(.gray)
                            Text("\(Int(detail.amount))₽")
                                .foregroundColor(.white)
                                .padding(.leading, 4)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)

                        if index < details.count - 1 {
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
    }
}
