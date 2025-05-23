// MARK: - Связующее звено между UI и сервисом транзакций (управляет списком транзакций и уведомляет интерфейс об изменениях)

import Foundation
import Combine

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []

    func loadMockTransactions(for banks: [String]) {
        transactions = [
            Transaction(
                id: 1,
                date: "22.04.2025",
                time: "12:00",
                amount: 1300,
                isIncome: false,
                description: "Перевод",
                category: "Покупки",
                bank: "Tinkoff"
            ),
            Transaction(
                id: 2,
                date: "21.04.2025",
                time: "15:30",
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

    func fetchTransactions() async {
        guard let token = KeychainHelper.shared.readAccessToken() else {
            print("❌ Нет токена")
            return
        }

        await withCheckedContinuation { continuation in
            TransactionService.shared.fetchAll(token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let txs):
                        self.transactions = txs
                        print("✅ Загрузили \(txs.count) транзакций")
                    case .failure(let error):
                        print("❌ Ошибка загрузки транзакций: \(error)")
                    }
                    continuation.resume()
                }
            }
        }
    }
}
