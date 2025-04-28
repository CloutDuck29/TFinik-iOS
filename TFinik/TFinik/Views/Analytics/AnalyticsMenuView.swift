import SwiftUI

struct AnalyticsMenuView: View {
    @AppStorage("selectedTab") private var selectedTab: String = "analytics"

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                // Заголовок экрана с иконкой
                VStack {
                    HStack {
                        Text("📈")
                            .font(.system(size: 32))
                        Text("Аналитика")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.top, 150) // Уменьшаем верхний отступ, чтобы поднять заголовок
                }

                // Список кнопок
                VStack(spacing: 16) {
                    AnalyticsButton(title: "Финансовые цели", icon: "🎯", action: {
                        // Действие для финансовых целей
                    })
                    AnalyticsButton(title: "Список транзакций", icon: "💸", action: {
                        // Действие для списка транзакций
                    })
                    AnalyticsButton(title: "График расходов", icon: "💰", action: {
                        // Действие для графика расходов
                    })
                    AnalyticsButton(title: "Прогноз расходов", icon: "🛠", action: {
                        // Действие для прогноза расходов
                    })
                    AnalyticsButton(title: "График заработков", icon: "🤑", action: {
                        // Действие для графика заработков
                    })
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .padding(.top, 24) // Уменьшаем отступ сверху для кнопок

                Spacer() // Для того, чтобы кнопки не расползались по экрану
            }
            .padding(.bottom, 140) // Убираем лишний отступ, чтобы нижняя панель не съезжала
        }
        .ignoresSafeArea()
    }
}

struct AnalyticsButton: View {
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

struct AnalyticsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsMenuView()
            .preferredColorScheme(.dark)
    }
}
