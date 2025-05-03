import SwiftUI

struct ProfileMenuView: View {
    @AppStorage("selectedTab") private var selectedTab: String = "analytics"
    @EnvironmentObject var auth: AuthService
    @State private var isShowingBankUploadView = false
    @State private var isShowingAdviceView = false
    @State private var isShowingHistoryView = false
    @State private var isShowingPortraitView = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack {
                    VStack(spacing: 8) {
                        Text("👦🏻")
                            .font(.system(size: 40))
                        Text("Профиль")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.top, 125)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ProfileCard(icon: "🎯", label: "Выписки") {
                            isShowingBankUploadView = true
                        }
                        ProfileCard(icon: "🔥", label: "Советы") {
                            isShowingAdviceView = true
                        }
                        ProfileCard(icon: "📃", label: "История") {
                            isShowingHistoryView = true
                        }
                        ProfileCard(icon: "😁", label: "Портрет") {
                            isShowingPortraitView = true
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.bottom, 80)

                .navigationDestination(isPresented: $isShowingBankUploadView) {
                    BankUploadView().environmentObject(auth)
                }
                .navigationDestination(isPresented: $isShowingAdviceView) {
                    FinanceAdviceView()
                }
                .navigationDestination(isPresented: $isShowingHistoryView) {
                    FinanceAdviceView()
                }
                .navigationDestination(isPresented: $isShowingPortraitView) {
                    FinanceAdviceView()
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct ProfileCard: View {
    let icon: String
    let label: String
    let action: () -> Void

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
