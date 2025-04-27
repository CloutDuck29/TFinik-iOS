import Foundation

class TokenStorage {
    static let shared = TokenStorage()

    private init() {}

    var accessToken: String?
}
