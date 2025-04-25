import SwiftUI

struct Transaction: Identifiable {
    let id = UUID()
    let bank: String
    let date: String
    let description: String
    let amount: Double
    let isIncome: Bool
    var category: String
}

struct TransactionPreviewView: View {
    @State var transactions: [Transaction]
    @EnvironmentObject var transactionStore: TransactionStore
    let categories = ["Покупки", "Доход", "Еда", "Транспорт", "Развлечения"]

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Text("Предпросмотр транзакций")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 95) // Подняли надпись ниже

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach($transactionStore.transactions) { $tx in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(tx.description)
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        Text("\(tx.bank) • \(tx.date)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Text(String(format: "%@%.2f ₽", tx.isIncome ? "+" : "-", tx.amount))
                                        .foregroundColor(tx.isIncome ? .green : .red)
                                        .fontWeight(.semibold)
                                }

                                Menu {
                                    ForEach(categories, id: \ .self) { cat in
                                        Button(action: {
                                            tx.category = cat
                                        }) {
                                            Text(cat)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(tx.category)
                                        Image(systemName: "chevron.down")
                                    }
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.white.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }

                Spacer(minLength: 32) // Подняли кнопку чуть выше

                Button("Добавить транзакцию") {
                    let newTx = Transaction(
                        bank: "TestBank",
                        date: "25.04.2025",
                        description: "Тестовая покупка",
                        amount: 999.0,
                        isIncome: false,
                        category: "Тест"
                    )
                    transactionStore.add(newTx)
                }
                .foregroundColor(.white)

                
                Button(action: {
                    // Действие "Продолжить"
                }) {
                    Text("Продолжить")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea()
    }
}

struct TransactionPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionPreviewView(transactions: [
            Transaction(bank: "Tinkoff", date: "22.04.2025", description: "Перевод в магазин", amount: 1300.0, isIncome: false, category: "Покупки"),
            Transaction(bank: "Sber", date: "21.04.2025", description: "Зарплата", amount: 7000000.0, isIncome: true, category: "Доход"),
            Transaction(bank: "Tinkoff", date: "20.04.2025", description: "Кофе", amount: 250.0, isIncome: false, category: "Еда")
        ])
        .preferredColorScheme(.dark)
    }
}
