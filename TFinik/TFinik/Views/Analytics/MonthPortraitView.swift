import SwiftUI

// MARK: - Модели
struct MonthPortraitResponse: Decodable {
    struct Portrait: Decodable {
        let month: String?
        let year: Int?
        let balanced: Bool?
        let top_categories: [String]?
        let emoji: String?
        let mood: String?
        let summary: String?
        let status: String?
        let message: String?
    }

    struct Pattern: Decodable {
        let label: String
        let limit: Double
        let days_total: Int
        let weekdays: Int
        let weekends: Int
    }

    let portrait: Portrait
    let patterns: [Pattern]
}

// MARK: - ViewModel

class PortraitViewModel: ObservableObject {
    @Published var data: MonthPortraitResponse?
    @Published var isLoading = true

    func loadPortrait(token: String) {
        guard let url = URL(string: "http://169.254.142.87:8000/portrait") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Не удалось получить HTTP-ответ")
                    return
                }

                print("🔄 Status code: \(httpResponse.statusCode)")

                guard let data = data else {
                    print("❌ Данные отсутствуют")
                    return
                }

                // Печатаем тело ответа как строку
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 Ответ от сервера:\n\(raw)\n")
                } else {
                    print("❓ Не удалось декодировать ответ как строку")
                }

                do {
                    self.data = try JSONDecoder().decode(MonthPortraitResponse.self, from: data)
                } catch {
                    print("❌ Decode error: \(error)")
                }
            }
        }.resume()
    }
}


// MARK: - View

struct MonthPortraitView: View {
    @StateObject private var viewModel = PortraitViewModel()
    @EnvironmentObject var auth: AuthService

    var body: some View {
        ZStack {
            BackgroundView()

            if viewModel.isLoading {
                ProgressView("Загрузка портрета…")
                    .foregroundColor(.white)

            } else if let portrait = viewModel.data?.portrait {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Портрет месяца")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Ваше финансовое настроение и типы трат по дням")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 32)

                        if portrait.status == "no_data" {
                            PortraitCard {
                                Text(portrait.message ?? "Нет данных для анализа")
                                    .foregroundColor(.gray)
                                    .font(.body)
                            }
                        } else {
                            PortraitCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("\(portrait.month ?? "") \(portrait.year ?? 0)")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Text(portrait.summary ?? "")
                                        .font(.body)
                                        .foregroundColor(.white)

                                    Text("Настроение месяца: \(portrait.mood ?? "") \(portrait.emoji ?? "")")
                                        .font(.subheadline)
                                        .foregroundColor(.purple)
                                }
                            }

                            if let patterns = viewModel.data?.patterns {
                                PortraitCard {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Ваши денежные паттерны")
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        ForEach(patterns, id: \.label) { pattern in
                                            Text("• \(pattern.label) — до \(Int(pattern.limit)) ₽ (\(pattern.days_total) дн., будни: \(pattern.weekdays), выходные: \(pattern.weekends))")
                                        }
                                        .font(.body)
                                        .foregroundColor(.white)
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }

            } else {
                Text("Данных пока нет")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let token = auth.accessToken {
                viewModel.loadPortrait(token: token)
            }
        }
    }
}

// MARK: - Общий стиль карточки

struct PortraitCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple, lineWidth: 1)
                .background(Color.black.opacity(0.3).cornerRadius(16))
        )
    }
}
