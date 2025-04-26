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
}
