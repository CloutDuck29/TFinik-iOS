import SwiftUI

struct AdviceItem: Decodable, Identifiable {
    var id: UUID { UUID() }
    let category: String
    let change_percent: Double
    let share_percent: Double
    let advice: String
}

struct FinanceAdviceView: View {
    @State private var tips: [AdviceItem] = []
    @State private var isLoading = true

    let cardColors: [Color] = [
        Color.purple.opacity(0.4),
        Color.blue.opacity(0.4),
        Color.orange.opacity(0.4),
        Color.green.opacity(0.4),
        Color.pink.opacity(0.4),
        Color.cyan.opacity(0.4),
        Color.indigo.opacity(0.4)
    ]

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                HStack {
                    Text("💡")
                        .font(.system(size: 32))
                    Text("Советы по финансам")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding(.top, 125)

                Text("Мы проанализировали Ваши траты и подготовили несколько советов.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.top, 60)
                } else if tips.isEmpty {
                    Text("Советы пока не найдены. Отличная финансовая дисциплина! 🎉")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(tips.enumerated()), id: \.element.id) { index, tip in
                                let color = cardColors[index % cardColors.count]

                                Text(tip.advice)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(color)
                                            .shadow(color: color.opacity(0.6), radius: 10)
                                    )
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                }

                Spacer()
            }
            .padding(.bottom, 80)
        }
        .ignoresSafeArea()
        .onAppear {
            loadAdvice()
        }
    }

    func loadAdvice() {
        guard let token = KeychainHelper.shared.readAccessToken(),
              let url = URL(string: "http://169.254.142.87:8000/advice/monthly") else {
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                defer { self.isLoading = false }

                if let data = data {
                    print("📦 Ответ сервера: \(String(data: data, encoding: .utf8) ?? "nil")")
                    print("🔁 Статус ответа: \((response as? HTTPURLResponse)?.statusCode ?? -1)")

                    do {
                        let decoded = try JSONDecoder().decode([AdviceItem].self, from: data)
                        self.tips = decoded
                    } catch {
                        print("❌ Ошибка декодирования советов:", error)
                    }
                }
            }
        }.resume()
    }
}
