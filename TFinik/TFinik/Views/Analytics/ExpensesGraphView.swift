import SwiftUI
import Charts

struct ExpensesGraphView: View {
    @Environment(\.dismiss) var dismiss
    @State private var data: [ExpenseEntry] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                header

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.top, 60)
                } else {
                    graph

                    if !otherDescriptions.isEmpty {
                        otherBlock
                    }
                }

                Spacer()
            }
            .padding(.bottom, 80)
        }
        .ignoresSafeArea()
        .onAppear {
            Task { await loadData() }
        }
    }

    // MARK: - Заголовок
    private var header: some View {
        VStack(spacing: 8) {
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
        }
    }

    // MARK: - График
    private var graph: some View {
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
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut, value: data)
    }

    // MARK: - Блок "другие"
    private var otherBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Что попало в категорию \"Другие\"")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(otherDescriptions, id: \.self) { desc in
                        Text("• \(desc)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
            }
            .frame(height: 150)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple, lineWidth: 1)
                .background(Color.black.opacity(0.1).cornerRadius(16))
        )
        .padding(.horizontal)
    }

    // MARK: - Выделение описаний
    var otherDescriptions: [String] {
        data.filter { $0.category == "Другие" }
            .compactMap { $0.description }
            .uniqued()
    }

    // MARK: - Загрузка данных
    @MainActor
    func loadData() async {
        isLoading = true
        switch await AnalyticsService.shared.fetchMonthlyAnalytics() {
        case .success(let result):
            data = result
            isLoading = false
        case .failure(let error):
            print("❌ Ошибка получения графика: \(error)")
            isLoading = false
        }
    }
}
