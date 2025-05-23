// MARK: Обеспечивает аутентификацию пользователя с помощью email и пароля, сохраняет токены и отслеживает статус входа

import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published var isLoggedIn = false //статус входа
    @Published var errorMessage: String? //хранение ошибки
    var accessToken: String? { //токен из keychain
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

//MARK: - отправляет POST-ЗАПРОС, получает токены, сохраняет их в TokenStorage и KeyChain, обновляет флаг isLoggedIn
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
//MARK: - отправляет POST-ЗАПРОС, если регистрация успешна - сбрасывает токены, онбординг и вызывает логин
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
//MARK: - проверка актуальности и наличия токена
    func isTokenAvailable() -> Bool {
        return KeychainHelper.shared.readAccessToken() != nil
    }
//MARK: - отправляет refresh_token на auth/refresh и получает новые токены и сохраняет их, используется для обновления, в случае устаревания.
    @MainActor
    func refreshAccessTokenIfNeeded() async -> Bool {
        guard let refreshToken = TokenStorage.shared.refreshToken else { return false }

        guard let url = URL(string: "http://10.255.255.239:8000/auth/refresh") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(["refresh_token": refreshToken])
        } catch {
            print("Ошибка кодирования body для refresh")
            return false
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let tokens = try JSONDecoder().decode(TokenPair.self, from: data)
            TokenStorage.shared.accessToken = tokens.access_token
            TokenStorage.shared.refreshToken = tokens.refresh_token
            KeychainHelper.shared.save(tokens: tokens)
            print("✅ Access токен обновлён успешно")
            return true
        } catch {
            print("❌ Ошибка обновления токена: \(error)")
            return false
        }
    }

}

struct Creds: Codable {
    let email: String
    let password: String
}

struct EmptyResponse: Decodable {}
