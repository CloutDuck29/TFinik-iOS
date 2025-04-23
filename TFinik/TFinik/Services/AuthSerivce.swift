import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?

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
            KeychainHelper.shared.save(tokens: tokens)
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

            // Устанавливаем hasOnboarded в false
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

}

struct Creds: Codable {
    let email: String
    let password: String
}

struct EmptyResponse: Decodable {}
