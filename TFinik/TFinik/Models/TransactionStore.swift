import SwiftUI

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    // Заглушка для подстановки фейковых транзакций после "загрузки"
    func loadMockTransactions(for banks: [String]) {
        var loaded: [Transaction] = []
        
        if banks.contains("Tinkoff") {
            loaded.append(contentsOf: [
                Transaction(bank: "Tinkoff", date: "22.04.2025", description: "Перевод в магазин", amount: 1300.0, isIncome: false, category: "Покупки"),
                Transaction(bank: "Tinkoff", date: "20.04.2025", description: "Кофе", amount: 250.0, isIncome: false, category: "Еда")
            ])
        }
        if banks.contains("Sber") {
            loaded.append(Transaction(bank: "Sber", date: "21.04.2025", description: "Зарплата", amount: 70000.0, isIncome: true, category: "Доход"))
        }
        if banks.contains("Alfa") {
            loaded.append(Transaction(bank: "Alfa", date: "18.04.2025", description: "Интернет", amount: 600.0, isIncome: false, category: "Услуги"))
        }
        if banks.contains("VTB") {
            loaded.append(Transaction(bank: "VTB", date: "15.04.2025", description: "Кино", amount: 800.0, isIncome: false, category: "Развлечения"))
        }

        transactions = loaded
    }
}
