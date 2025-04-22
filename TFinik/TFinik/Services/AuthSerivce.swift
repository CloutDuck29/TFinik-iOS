import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?

    func login(email: String, password: String) async {
        // сброс предыдущей ошибки
        errorMessage = nil

        // готовим тело запроса
        let creds = ["email": email, "password": password]
        guard let body = try? JSONEncoder().encode(creds) else {
            errorMessage = "Invalid login data"
            return
        }

        do {
            // реальный вызов API
            let tokens: TokenPair = try await APIClient.shared.request(
                "POST",
                path: "/auth/login",
                body: body
            )
            // сохраняем токены
            KeychainHelper.shared.save(tokens: tokens)
            // отмечаем успешный логин
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
}
