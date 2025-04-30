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
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false
    
    let categories = ["Кофейни", "Магазины", "Транспорт", "Доставка/Еда", "Развлечения", "Пополнение", "ЖКХ/Коммуналка", "Переводы", "Другие"]

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
                                            withAnimation {
                                                tx.category = cat
                                                updateTransactionCategory(transactionID: tx.id, newCategory: cat) { result in
                                                    switch result {
                                                    case .success:
                                                        print("✅ Категория обновлена")
                                                    case .failure(let error):
                                                        print("❌ Ошибка обновления категории: \(error.localizedDescription)")
                                                    }
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
                            .id(tx.id)
                            .animation(.easeInOut(duration: 0.2), value: tx.category)
                        }

                        Spacer().frame(height: 24)
                    }
                    .padding(.top)
                    .padding(.bottom, 32)
                }

                NavigationLink(destination: ExpensesChartView(), isActive: $navigateToAnalytics) {
                    EmptyView()
                }

                Button(action: {
                    hasUploadedStatement = true
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
                .padding(.bottom, 32)
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
    }
}
