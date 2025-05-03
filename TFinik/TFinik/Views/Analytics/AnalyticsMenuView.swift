import SwiftUI

struct AnalyticsMenuView: View {
    @AppStorage("selectedTab") private var selectedTab: String = "analytics"
    @State private var isShowingExpensesGraphic = false
    @State private var isShowingIncomeGraphic = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                VStack(spacing: 8) {
                    Text("📈")
                        .font(.system(size: 40))
                    Text("Аналитика")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding(.top, 125)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    AnalyticsCard(icon: "🎯", label: "Цели") {
                        // TODO
                    }
                    AnalyticsCard(icon: "💸", label: "Траты") {
                        // TODO
                    }
                    AnalyticsCard(icon: "💰", label: "Расходы") {
                        isShowingExpensesGraphic = true
                    }
                    AnalyticsCard(icon: "🛠", label: "Прогноз") {
                        // TODO
                    }
                    AnalyticsCard(icon: "🤑", label: "Доходы") {
                        isShowingIncomeGraphic = true
                    }
                    .gridCellColumns(2) // ← добавь это
                }

                .padding(.top, 40)
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.bottom, 80)
        }
        .ignoresSafeArea()
        .navigationDestination(isPresented: $isShowingExpensesGraphic) {
            ExpensesGraphView()
        }
        .navigationDestination(isPresented: $isShowingIncomeGraphic) {
            IncomeGraphView()
        }
    }
}

struct AnalyticsCard: View {
    let icon: String
    let label: String
    let action: () -> Void
    var fullWidth: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 40))
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.5), lineWidth: 1)
            )
        }
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
