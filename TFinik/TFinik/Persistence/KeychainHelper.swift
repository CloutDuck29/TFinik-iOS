import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private let service = "com.taigo.TFinik"

    func save(tokens: TokenPair) {
        save(token: tokens.access_token, key: "access_token")
        save(token: tokens.refresh_token, key: "refresh_token")
    }

    func readAccessToken() -> String? {
        readToken(key: "access_token")
    }

    private func save(token: String, key: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func readToken(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String      : kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String : true,
            kSecMatchLimit as String : kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let str = String(data: data, encoding: .utf8)
        else { return nil }
        return str
    }
}
