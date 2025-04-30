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
    @EnvironmentObject var transactionStore: TransactionStore
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var navigateToAnalytics = false

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

                if transactionStore.transactions.isEmpty {
                    Spacer()
                    ProgressView("Загрузка транзакций...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                    Spacer()
                } else {
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

                                        Text("\(tx.amount, specifier: "%.2f") ₽")
                                            .foregroundColor(tx.isIncome ? .green : .red)
                                            .fontWeight(.semibold)
                                    }

                                    Menu {
                                        ForEach(categories, id: \.self) { cat in
                                            Button {
                                                tx.category = cat
                                                updateTransactionCategory(transactionID: tx.id, newCategory: cat)
                                            } label: {
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

                    Button {
                        hasUploadedStatement = true
                        hasOnboarded = true
                        navigateToAnalytics = true
                    } label: {
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

                NavigationLink(destination: ExpensesChartView(), isActive: $navigateToAnalytics) {
                    EmptyView()
                }
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
    }

    func updateTransactionCategory(transactionID: Int, newCategory: String) {
        guard let token = KeychainHelper.shared.readAccessToken() else {
            print("❌ Token not found")
            return
        }

        guard let url = URL(string: "http://169.254.218.217:8000/transactions/\(transactionID)/category") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = ["category": newCategory]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request).resume()
    }
}
