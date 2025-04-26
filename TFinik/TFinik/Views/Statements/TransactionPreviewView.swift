import SwiftUI

struct Transaction: Identifiable, Codable {
    var id = UUID()
    let date: String
    let time: String?
    let amount: Double
    var isIncome: Bool
    var description: String
    var category: String
    var bank: String
}

struct TransactionPreviewView: View {
    @State var transactions: [Transaction]  // ✅ Работаем только с локальным списком
    let categories = ["Покупки", "Доход", "Еда", "Транспорт", "Развлечения", "Другие", "Переводы"]

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
                .padding(.top, 95)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach($transactions) { $tx in
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

                                    Text("\(tx.amount, specifier: "%.2f") ₽")
                                        .foregroundColor(tx.isIncome ? .green : .red)
                                        .fontWeight(.semibold)
                                }

                                Menu {
                                    ForEach(categories, id: \.self) { cat in
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

                Spacer(minLength: 32)

                Button(action: {
                    // TODO: переход в аналитику
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
            Transaction(id: UUID(), date: "22.04.2025", time: "12:00", amount: 1300, isIncome: false, description: "Перевод в магазин", category: "Покупки", bank: "Tinkoff"),
            Transaction(id: UUID(), date: "21.04.2025", time: "15:30", amount: 70000, isIncome: true, description: "Зарплата", category: "Доход", bank: "Sber"),
            Transaction(id: UUID(), date: "20.04.2025", time: "10:15", amount: 250, isIncome: false, description: "Кофе", category: "Еда", bank: "Tinkoff")
        ])
        .preferredColorScheme(.dark)
    }
}
