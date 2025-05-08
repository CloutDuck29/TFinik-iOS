import Foundation
import Combine

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []

    func loadMockTransactions(for banks: [String]) {
        // Пример моков:
        transactions = [
            Transaction(
                id: 1,
                date: "22.04.2025",
                time: "12:00", // или nil, если времени нет
                amount: 1300,
                isIncome: false,
                description: "Перевод",
                category: "Покупки",
                bank: "Tinkoff"
            ),
            Transaction(
                id: 2,
                date: "21.04.2025",
                time: "15:30", // или nil
                amount: 70000,
                isIncome: true,
                description: "Зарплата",
                category: "Доход",
                bank: "Sber"
            )
        ].filter { banks.contains($0.bank) }

    }

    func add(_ transaction: Transaction) {
        transactions.append(transaction)
    }

    func clear() {
        transactions.removeAll()
    }
    
    func fetchTransactions() {
        print("🚀 Запуск запроса на сервер")

        guard let token = KeychainHelper.shared.readAccessToken(),
              let url = URL(string: "http://10.255.255.239:8000/transactions/history") else {
            print("❌ Нет токена или URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    print("📦 Получены данные:", String(data: data, encoding: .utf8) ?? "nil")
                    do {
                        self.transactions = try JSONDecoder().decode([Transaction].self, from: data)
                        print("✅ Распарсили \(self.transactions.count) транзакций")
                    } catch {
                        print("❌ Ошибка декодирования:", error)
                    }
                } else if let error = error {
                    print("❌ Ошибка запроса:", error.localizedDescription)
                }
            }
        }.resume()
    }
}
