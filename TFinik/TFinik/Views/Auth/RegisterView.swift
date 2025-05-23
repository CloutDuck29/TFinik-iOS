// MARK: - Окно регистрации

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var navigateToOnboarding = false
    @State private var errorMessage: String?
    @Binding var hasOnboarded: Bool
    @EnvironmentObject var auth: AuthService

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack(spacing: 20) {
                    Spacer(minLength: 80)

                    VStack(spacing: 4) {
                        Text("Регистрация")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("в T-Finik")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 16)

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

                    SecureField("Пароль", text: $password)
                        .textContentType(.newPassword) // или попробуй убрать эту строку вообще
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )


                    SecureField("Повторите пароль", text: $confirmPassword)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )

                    Button("Создать аккаунт") {
                        Task {
                            if password == confirmPassword {
                                let success = await auth.register(email: email, password: password)
                                if success {
                                    navigateToOnboarding = true
                                } else {
                                    errorMessage = auth.errorMessage
                                }
                            } else {
                                errorMessage = "Пароли не совпадают"
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: 360)
                .navigationDestination(isPresented: $navigateToOnboarding) {
                    RegistrationSuccessView(
                        navigateToOnboarding: $navigateToOnboarding,
                        hasOnboarded: $hasOnboarded
                    )
                }
            }
        }
    }
}
