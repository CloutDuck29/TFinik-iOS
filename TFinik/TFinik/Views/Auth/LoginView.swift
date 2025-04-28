import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthService
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("selectedTab") private var selectedTab: String = "expenses" // Для выбора вкладки

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                Text("T‑Finik")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
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
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                Button(action: {
                    Task {
                        let success = await fetchAndStoreToken(email: email, password: password)
                        if success {
                            hasOnboarded = true       // Пользователь прошёл онбординг
                            selectedTab = "analytics" // Сразу переходим на аналитику
                            auth.isLoggedIn = true    // Авторизован
                            dismiss()                // Закрываем LoginView
                        } else {
                            errorMessage = "Ошибка входа. Проверьте email и пароль."
                        }
                    }
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

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: 360)
            .padding()
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Получение токена
    func fetchAndStoreToken(email: String, password: String) async -> Bool {
        guard let url = URL(string: "http://127.0.0.1:8000/auth/login") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password]

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, _) = try await URLSession.shared.data(for: request)

            let tokens = try JSONDecoder().decode(TokenPair.self, from: data)
            
            TokenStorage.shared.accessToken = tokens.access_token
            KeychainHelper.shared.save(tokens: tokens)

            print("✅ Токены сохранены")
            return true
        } catch {
            print("❌ Ошибка получения токена: \(error.localizedDescription)")
            return false
        }
    }


    
    func uploadBankStatementIfNeeded() async {
        guard let token = TokenStorage.shared.accessToken else {
            print("❌ Нет токена для загрузки выписки")
            return
        }

        guard let pdfUrl = Bundle.main.url(forResource: "spravka_o_dvizhenii_denegnyh_sredstv", withExtension: "pdf") else {
            print("❌ PDF не найден в бандле")
            return
        }

        do {
            var request = URLRequest(url: URL(string: "http://127.0.0.1:8000/transactions/upload")!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let data = try createMultipartFormData(fileURL: pdfUrl, boundary: boundary)

            let (responseData, _) = try await URLSession.shared.upload(for: request, from: data)

            if let responseString = String(data: responseData, encoding: .utf8) {
                print("✅ Успешная загрузка выписки: \(responseString)")
            }
        } catch {
            print("❌ Ошибка загрузки выписки: \(error.localizedDescription)")
        }
    }

    private func createMultipartFormData(fileURL: URL, boundary: String) throws -> Data {
        var body = Data()
        let filename = fileURL.lastPathComponent
        let data = try Data(contentsOf: fileURL)
        let mimetype = "application/pdf"

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
