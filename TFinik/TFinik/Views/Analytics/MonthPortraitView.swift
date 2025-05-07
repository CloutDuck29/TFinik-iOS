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
    @Published var month: Int
    @Published var year: Int

    init() {
        let now = Date()
        let calendar = Calendar.current
        self.month = calendar.component(.month, from: now)
        self.year = calendar.component(.year, from: now)
    }

    func loadPortrait(token: String) {
        isLoading = true
        var components = URLComponents(string: "http://169.254.142.87:8000/portrait")!
        components.queryItems = [
            URLQueryItem(name: "month", value: "\(month)"),
            URLQueryItem(name: "year", value: "\(year)")
        ]
        guard let url = components.url else { return }

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

                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 Ответ от сервера:\n\(raw)\n")
                }

                do {
                    self.data = try JSONDecoder().decode(MonthPortraitResponse.self, from: data)
                } catch {
                    print("❌ Decode error: \(error)")
                }
            }
        }.resume()
    }

    func previousMonth(token: String) {
        if month == 1 {
            month = 12
            year -= 1
        } else {
            month -= 1
        }
        loadPortrait(token: token)
    }

    func nextMonth(token: String) {
        if month == 12 {
            month = 1
            year += 1
        } else {
            month += 1
        }
        loadPortrait(token: token)
    }
}


// MARK: - View
struct MonthPortraitView: View {
    @StateObject private var viewModel = PortraitViewModel()
    @EnvironmentObject var auth: AuthService

    var formattedMonthYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"

        var comps = DateComponents()
        comps.year = viewModel.year
        comps.month = viewModel.month
        comps.day = 1

        let calendar = Calendar.current
        if let date = calendar.date(from: comps) {
            return formatter.string(from: date).capitalized  // например, "Май 2025"
        }
        return "\(viewModel.month).\(viewModel.year)"
    }

    var body: some View {
        ZStack {
            BackgroundView()

            if viewModel.isLoading {
                ProgressView("Загрузка портрета…")
                    .foregroundColor(.white)

            } else if let portrait = viewModel.data?.portrait {
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
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

                        // Переключение месяцев
                        HStack {
                            Button(action: {
                                if let token = auth.accessToken {
                                    viewModel.previousMonth(token: token)
                                }
                            }) {
                                Image(systemName: "chevron.left")
                            }

                            Spacer()

                            Text(formattedMonthYear)
                                .foregroundColor(.white)
                                .font(.headline)

                            Spacer()

                            Button(action: {
                                if let token = auth.accessToken {
                                    viewModel.nextMonth(token: token)
                                }
                            }) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding(.horizontal)

                        if portrait.status == "no_data" {
                            PortraitCard {
                                Text(portrait.message ?? "Нет данных для анализа")
                                    .foregroundColor(.gray)
                                    .font(.body)
                            }
                        } else {
                            PortraitCard {
                                VStack(alignment: .leading, spacing: 12) {
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
