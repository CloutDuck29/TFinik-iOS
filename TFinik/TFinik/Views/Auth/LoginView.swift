import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    @StateObject private var auth = AuthService()
    @State private var errorMessage: String?
    
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                Text("T‑Finik")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 16)

                // Белое поле Email
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                // Белое поле Пароль
                SecureField("Пароль", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                // Белая кнопка
                Button(action: {
                    Task { await auth.login(email: email, password: password) }
                }) {
                    Text("Войти")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .disabled(email.isEmpty || password.isEmpty)

                // Ошибка ниже кнопки
                if let error = auth.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: 360)
            .padding()
            .fullScreenCover(isPresented: $auth.isLoggedIn) {
                OnboardingPagerView(hasOnboarded: $hasOnboarded)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
