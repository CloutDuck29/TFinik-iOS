import Foundation
import Combine

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []

    func loadMockTransactions(for banks: [String]) {
        // Пример моков:
        transactions = [
            Transaction(bank: "Tinkoff", date: "22.04.2025", description: "Перевод", amount: 1300, isIncome: false, category: "Покупки"),
            Transaction(bank: "Sber", date: "21.04.2025", description: "Зарплата", amount: 70000, isIncome: true, category: "Доход")
        ].filter { banks.contains($0.bank) }
    }

    func add(_ transaction: Transaction) {
        transactions.append(transaction)
    }

    func clear() {
        transactions.removeAll()
    }
}
