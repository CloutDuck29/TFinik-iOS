// MARK: - хелпер для безопасного хрангения и чтения токенов
//Сохраняет токены, удаляет, читает токены, очищает токены
//Чтобы авторизационные токены не сохранялись в памяти, а были безопасно зашифрованы системой через Keychain
//KeyChain - встроенная система безопасного хранения конфиденциальных данных во всех устройствах эппл (пароли, токены, сертификаты)
//Даные хранятся зашифрованными, только мое приложение получает к ним доступ, защита на уровне железа (secure enclave).
//Обрабатывает биометрию, криптографические ключи, работает независимо от процессор, аппаратно шифруются.
import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private let service = "com.taigo.TFinik"

    func save(tokens: TokenPair?) {
        if let tokens {
            save(token: tokens.access_token, key: "access_token")
            save(token: tokens.refresh_token, key: "refresh_token")
        } else {
            deleteToken(key: "access_token")
            deleteToken(key: "refresh_token")
        }
    }

    func readAccessToken() -> String? {
        readToken(key: "access_token")
    }

    func clear() {
        save(tokens: nil)
    }

    // MARK: - Private

    private func save(token: String, key: String) {
        print("💾 Сохраняю токен с ключом \(key)")
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        print("🔐 Status сохранения: \(status == errSecSuccess ? "Успех" : "Ошибка: \(status)")")
    }


    private func deleteToken(key: String) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func readToken(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let str = String(data: data, encoding: .utf8)
        else { return nil }
        return str
    }
}
