import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    @StateObject private var auth = AuthService()
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("T‑Finik")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(white: 0.1))
                .cornerRadius(8)

            SecureField("Пароль", text: $password)
                .padding()
                .background(Color(white: 0.1))
                .cornerRadius(8)

            // Кнопка с модификаторами
            Button(action: {
                Task { await auth.login(email: email, password: password) }
            }) {
                Text("Войти")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
        .padding()
        // Навигация при успешном входе
        .fullScreenCover(isPresented: $auth.isLoggedIn) {
            OnboardingStep1View()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
