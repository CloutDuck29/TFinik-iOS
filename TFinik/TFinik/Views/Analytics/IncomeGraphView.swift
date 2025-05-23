// MARK: - График доходов

import SwiftUI
import Charts

struct IncomeGraphView: View {
    @Environment(\.dismiss) var dismiss
    @State private var data: [IncomeEntry] = []
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

                    if !incomeDescriptions.isEmpty {
                        descriptionBlock
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
                Text("График доходов")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .padding(.top, 125)

            Text("Здесь Вы можете увидеть график Ваших доходов")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    // MARK: - График
    private var graph: some View {
        Chart(data) {
            BarMark(
                x: .value("Месяц", $0.month),
                y: .value("Сумма", $0.amount)
            )
            .foregroundStyle(by: .value("Категория", $0.category))
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

    // MARK: - Блок описания
    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание доходов")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(incomeDescriptions.uniqued(), id: \.self) { desc in
                        Text("• \(desc)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                .padding(.trailing, 8)
                .padding(.leading, 4)
            }
            .frame(height: 150)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple, lineWidth: 1)
                .background(Color.black.opacity(0.1).cornerRadius(16))
        )
        .padding(.horizontal)
    }

    // MARK: - Уникальные описания
    var incomeDescriptions: [String] {
        data.compactMap { $0.description }
    }

    // MARK: - Загрузка данных
    @MainActor
    func loadData() async {
        isLoading = true
        switch await AnalyticsService.shared.fetchIncomeAnalytics() {
        case .success(let result):
            data = result
            isLoading = false
        case .failure(let error):
            print("❌ Ошибка получения доходов: \(error)")
            isLoading = false
        }
    }
}
