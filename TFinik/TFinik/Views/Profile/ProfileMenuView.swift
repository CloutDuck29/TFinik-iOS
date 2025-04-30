import SwiftUI

struct ProfileMenuView: View {
    @AppStorage("selectedTab") private var selectedTab: String = "analytics"
    @State private var isShowingBankUploadView = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack {
                    VStack {
                        HStack {
                            Text("👦🏻")
                                .font(.system(size: 32))
                            Text("Профиль")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.top, 150)
                    }

                    VStack(spacing: 16) {
                        // Заменяем здесь действие
                        AnalyticsButton(title: "Загрузить выписки", icon: "🎯", action: {
                            isShowingBankUploadView = true
                        })
                        AnalyticsButton(title: "Советы по финансам", icon: "🔥", action: {})
                        AnalyticsButton(title: "Финансовая история", icon: "📃", action: {})
                        AnalyticsButton(title: "Портрет месяца", icon: "😁", action: {})
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)

                    Spacer()
                }
                .padding(.bottom, 140)
            }
            .ignoresSafeArea()
            .navigationDestination(isPresented: $isShowingBankUploadView) {
                BankUploadView()
            }
        }
    }
}


struct ProfileButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Spacer перед эмодзи
                Spacer()
                // Эмодзи
                Text(icon)
                    .font(.system(size: 28)) // Увеличиваем размер эмодзи для лучшего выравнивания
                Spacer(minLength: 8) // Отступ между эмодзи и текстом
                // Текст
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                // Spacer после текста
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "1A1A1F")) // Задаем нужный цвет
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "5800D3"), Color(hex: "8661D2")]), startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            ) // Добавляем градиентный stroke
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsMenuView()
            .preferredColorScheme(.dark)
    }
}
