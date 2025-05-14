// MARK: портрет месяца 

import SwiftUI

struct MonthPortraitView: View {
    @StateObject private var store = PortraitStore()
    @EnvironmentObject var auth: AuthService

    var body: some View {
        ZStack {
            BackgroundView()

            if store.isLoading {
                ProgressView("Загрузка портрета…")
                    .foregroundColor(.white)
            } else if let portrait = store.data?.portrait {
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

                        HStack {
                            Button(action: {
                                if let token = auth.accessToken {
                                    store.previousMonth(token: token)
                                }
                            }) {
                                Image(systemName: "chevron.left")
                            }

                            Spacer()

                            Text(store.formattedMonthYear)
                                .foregroundColor(.white)
                                .font(.headline)

                            Spacer()

                            Button(action: {
                                if let token = auth.accessToken {
                                    store.nextMonth(token: token)
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

                            if let patterns = store.data?.patterns {
                                PortraitCard {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Ваши денежные паттерны")
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        ForEach(patterns, id: \.label) { pattern in
                                            Text("• \(pattern.label) — до \(Int(pattern.limit)) ₽ (\(pattern.days_total) дн., будни: \(pattern.weekdays), выходные: \(pattern.weekends))")
                                                .foregroundColor(.white)
                                                .font(.body)
                                        }
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
                store.loadPortrait(token: token)
            }
        }
    }
}

struct PortraitCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple, lineWidth: 1)
                )
        )
    }
}

