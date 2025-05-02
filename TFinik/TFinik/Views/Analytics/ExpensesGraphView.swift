import SwiftUI
import Charts

struct ExpenseEntry: Identifiable, Decodable, Equatable {
    let id = UUID()
    let month: String
    let category: String
    let amount: Double
    let description: String?
}

struct ExpensesGraphView: View {
    @Environment(\.dismiss) var dismiss
    @State private var data: [ExpenseEntry] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
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

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.top, 60)
                } else {
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

                if !otherDescriptions.isEmpty {
                    HStack {
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
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.bottom, 80)
        }
        .ignoresSafeArea()
        .onAppear {
            fetchGraphData()
        }
    }

    var otherDescriptions: [String] {
        data.filter { $0.category == "Другие" }
            .compactMap { $0.description }
            .uniqued()
    }

    func fetchGraphData() {
        guard let token = KeychainHelper.shared.readAccessToken(),
              let url = URL(string: "http://10.255.255.239:8000/analytics/monthly") else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { responseData, response, error in
            if let data = responseData {
                do {
                    let decoded = try JSONDecoder().decode([ExpenseEntry].self, from: data)
                    DispatchQueue.main.async {
                        self.data = decoded
                        self.isLoading = false
                    }
                } catch {
                    print("❌ Ошибка декодирования: \(error)")
                }
            }
        }.resume()
    }
}

// Уникальные значения с помощью Set
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
