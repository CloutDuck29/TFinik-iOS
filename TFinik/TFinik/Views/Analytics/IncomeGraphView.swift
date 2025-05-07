import SwiftUI
import Charts

struct IncomeEntry: Identifiable, Decodable, Equatable {
    let id = UUID()
    let month: String
    let category: String
    let amount: Double
    let description: String?
}

struct IncomeGraphView: View {
    @Environment(\.dismiss) var dismiss
    @State private var data: [IncomeEntry] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
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

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.top, 60)
                } else {
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

                if !incomeDescriptions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание доходов")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)

                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(incomeDescriptions.enumerated()), id: \.offset) { index, desc in
                                    Text("• \(desc)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.trailing, 8) // 👈 Уменьшенный правый отступ
                            .padding(.leading, 4)  // 👈 Уменьшенный левый отступ
                        }
                        .frame(height: 150)
                    }
                    .padding(.horizontal, 16) // нормальные внешние боковые отступы блока
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple, lineWidth: 1)
                            .background(Color.black.opacity(0.1).cornerRadius(16))
                    )
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

    var incomeDescriptions: [String] {
        data.compactMap { $0.description }
    }

    func fetchGraphData() {
        guard let token = KeychainHelper.shared.readAccessToken(),
              let url = URL(string: "http://169.254.142.87:8000/analytics/income") else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { responseData, response, error in
            if let data = responseData {
                do {
                    let decoded = try JSONDecoder().decode([IncomeEntry].self, from: data)
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

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
