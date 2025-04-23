import SwiftUI

struct RegistrationSuccessView: View {
    @State private var proceed = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 24) {
                Spacer()

                Text("Аккаунт успешно создан!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Вы вошли в систему. Повторная авторизация потребуется раз в месяц.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                Button(action: {
                    proceed = true
                }) {
                    Text("Продолжить")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            }
            .frame(maxWidth: 360)
            .padding()
            .navigationDestination(isPresented: $proceed) {
                OnboardingPagerView()
            }
        }
    }
}
