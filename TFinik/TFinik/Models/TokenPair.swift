// MARK: - модель для парсинга JSON-ответа от API

struct TokenPair: Codable{
    let access_token: String
    let refresh_token: String
    let expires_in: Int
}
