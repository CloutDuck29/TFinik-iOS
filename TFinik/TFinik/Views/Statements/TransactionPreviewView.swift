import SwiftUI

struct Transaction: Identifiable, Codable {
    var id: Int
    let date: String
    let time: String?
    var amount: Double
    var isIncome: Bool
    var description: String
    var category: String
    var bank: String
}

struct TransactionPreviewView: View {
    @State private var navigateToAnalytics = false
    @State var transactions: [Transaction]
    
    let categories = ["Покупки", "Доход", "Еда", "Транспорт", "Развлечения", "Другие", "Переводы"]

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Предпросмотр транзакций")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 95)
                .padding(.bottom, 16)

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
                                            updateTransactionCategory(transactionID: tx.id, newCategory: cat) { result in
                                                switch result {
                                                case .success:
                                                    print("✅ Категория обновлена")
                                                case .failure(let error):
                                                    print("❌ Ошибка обновления категории: \(error.localizedDescription)")
                                                }
                                            }
                                        }) {
                                            Text(cat)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(tx.category)
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }

                        Spacer().frame(height: 24)
                    }
                    .padding(.top)
                    .padding(.bottom, 32)
                }

                NavigationLink(destination: ExpensesChartView(), isActive: $navigateToAnalytics) {
                    Button(action: {
                        navigateToAnalytics = true
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
                }
                .padding(.bottom, 32)
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true) // Скрываем кнопку back на текущем экране
    }
}

struct TransactionPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionPreviewView(transactions: [
            Transaction(id: 1, date: "22.04.2025", time: "12:00", amount: 1300, isIncome: false, description: "Перевод в магазин", category: "Покупки", bank: "Tinkoff"),
            Transaction(id: 2, date: "21.04.2025", time: "15:30", amount: 70000, isIncome: true, description: "Зарплата", category: "Доход", bank: "Sber"),
            Transaction(id: 3, date: "20.04.2025", time: "10:15", amount: 250, isIncome: false, description: "Кофе", category: "Еда", bank: "Tinkoff")
        ])
        .preferredColorScheme(.dark)
    }
}
