import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    var accessToken: String? {
        KeychainHelper.shared.readAccessToken()
    }

    init() {
        if KeychainHelper.shared.readAccessToken() != nil {
            isLoggedIn = true
            print("✅ Токен найден при запуске и вход выполнен")
        } else {
            isLoggedIn = false
        }
    }


    func login(email: String, password: String) async {
        errorMessage = nil

        let creds = Creds(email: email, password: password)
        guard let body = try? JSONEncoder().encode(creds) else {
            errorMessage = "Invalid login data"
            return
        }

        do {
            let tokens: TokenPair = try await APIClient.shared.request(
                "POST",
                path: "/auth/login",
                body: body
            )
            TokenStorage.shared.accessToken = tokens.access_token
            TokenStorage.shared.refreshToken = tokens.refresh_token
            KeychainHelper.shared.save(tokens: tokens)
            if let saved = KeychainHelper.shared.readAccessToken() {
                print("✅ Токен успешно сохранён и считан: \(saved)")
            } else {
                print("❌ Токен не сохранился в Keychain")
            }
            isLoggedIn = true
        } catch let err as APIError {
            switch err {
            case .statusCode(let code):
                errorMessage = "Server returned \(code)"
            default:
                errorMessage = "Network error: \(err)"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func register(email: String, password: String) async -> Bool {
        errorMessage = nil

        let creds = Creds(email: email, password: password)
        guard let body = try? JSONEncoder().encode(creds) else {
            errorMessage = "Invalid registration data"
            return false
        }

        do {
            _ = try await APIClient.shared.request(
                "POST",
                path: "/auth/register",
                body: body
            ) as EmptyResponse

            // ✅ Очищаем старые токены перед логином
            TokenStorage.shared.accessToken = nil
            TokenStorage.shared.refreshToken = nil
            KeychainHelper.shared.clear()

            // ✅ Сброс онбординга
            UserDefaults.standard.set(false, forKey: "hasOnboarded")

            await login(email: email, password: password)
            return true
        } catch let err as APIError {
            switch err {
            case .statusCode(let code):
                errorMessage = "Server returned \(code)"
            default:
                errorMessage = "Network error: \(err)"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        return false
    }

    func isTokenAvailable() -> Bool {
        return KeychainHelper.shared.readAccessToken() != nil
    }

    func refreshAccessTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = TokenStorage.shared.refreshToken else {
            completion(false)
            return
        }

        guard let url = URL(string: "http://169.254.142.87:8000/auth/refresh") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["refresh_token": refreshToken]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Ошибка кодирования body для refresh")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Нет данных от сервера")
                completion(false)
                return
            }

            do {
                let tokens = try JSONDecoder().decode(TokenPair.self, from: data)
                TokenStorage.shared.accessToken = tokens.access_token
                TokenStorage.shared.refreshToken = tokens.refresh_token
                KeychainHelper.shared.save(tokens: tokens)

                print("✅ Access токен обновлён успешно")
                completion(true)
            } catch {
                print("❌ Ошибка обновления токена: \(error)")
                completion(false)
            }
        }.resume()
    }
}

struct Creds: Codable {
    let email: String
    let password: String
}

struct EmptyResponse: Decodable {}
