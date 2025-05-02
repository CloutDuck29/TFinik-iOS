import SwiftUI
import Charts

struct ExpensesGraphView: View {
    @Environment(\.dismiss) var dismiss

    struct ExpenseEntry: Identifiable {
        let id = UUID()
        let month: String
        let category: String
        let amount: Double
    }

    let data: [ExpenseEntry] = [
        ExpenseEntry(month: "Янв", category: "Магазин", amount: 5000),
        ExpenseEntry(month: "Фев", category: "Магазин", amount: 8000),
        ExpenseEntry(month: "Мар", category: "Магазин", amount: 3000),
        ExpenseEntry(month: "Апр", category: "Магазин", amount: 9000),
        ExpenseEntry(month: "Май", category: "Магазин", amount: 7000),
        ExpenseEntry(month: "Июнь", category: "Магазин", amount: 4000),

        ExpenseEntry(month: "Янв", category: "Аптека", amount: 2000),
        ExpenseEntry(month: "Фев", category: "Аптека", amount: 10000),
        ExpenseEntry(month: "Мар", category: "Аптека", amount: 3000),
        ExpenseEntry(month: "Апр", category: "Аптека", amount: 6000),
        ExpenseEntry(month: "Май", category: "Аптека", amount: 9000),
        ExpenseEntry(month: "Июнь", category: "Аптека", amount: 11000),

        ExpenseEntry(month: "Янв", category: "Транспорт", amount: 1000),
        ExpenseEntry(month: "Фев", category: "Транспорт", amount: 2000),
        ExpenseEntry(month: "Мар", category: "Транспорт", amount: 10000),
        ExpenseEntry(month: "Апр", category: "Транспорт", amount: 60000),
        ExpenseEntry(month: "Май", category: "Транспорт", amount: 30000),
        ExpenseEntry(month: "Июнь", category: "Транспорт", amount: 50000),
    ]

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                // Заголовок с иконкой в одном стиле
                HStack {
                    Text("📈")
                        .font(.system(size: 32))
                    Text("График расходов")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding(.top, 125)

                Text("Здесь Вы можете увидеть график Ваших расходов")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Chart(data) {
                    LineMark(
                        x: .value("Месяц", $0.month),
                        y: .value("Сумма", $0.amount)
                    )
                    .foregroundStyle(by: .value("Категория", $0.category))
                    .symbol(by: .value("Категория", $0.category))
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 250)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple, lineWidth: 1)
                        .background(Color.black.opacity(0.1).cornerRadius(16))
                )
                .padding(.horizontal)

                // Легенда
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Circle().fill(Color.pink).frame(width: 10, height: 10)
                        Text("Магазин").foregroundColor(.white)
                    }
                    HStack(spacing: 12) {
                        Circle().fill(Color.blue).frame(width: 10, height: 10)
                        Text("Аптека").foregroundColor(.white)
                    }
                    HStack(spacing: 12) {
                        Circle().fill(Color.white).frame(width: 10, height: 10)
                        Text("Транспорт").foregroundColor(.white)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple, lineWidth: 1)
                        .background(Color.black.opacity(0.1).cornerRadius(16))
                )
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom, 80)
        }
        .ignoresSafeArea()
    }
}
