import SwiftUI

struct WelcomeView: View {
    @Binding var hasShownWelcome: Bool

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 32) {
                Spacer()

                Text("Добро пожаловать в T‑Finik!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Теперь вы можете загрузить банковские выписки и начать отслеживать свои расходы.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: {
                    hasShownWelcome = true
                }) {
                    Text("Продолжить")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(hasShownWelcome: .constant(false))
            .preferredColorScheme(.dark)
    }
}
