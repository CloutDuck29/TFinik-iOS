import SwiftUI

struct TransactionPreviewView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var navigateToAnalytics = false

    let isInitialUpload: Bool  // ← добавлен флаг

    let categories = ["Кофейни", "Магазины", "Транспорт", "Доставка", "Развлечения", "Пополнение", "ЖКХ", "Переводы", "Другие"]

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 0) {
                headerView

                if transactionStore.transactions.isEmpty {
                    loadingView
                } else {
                    transactionListView

                    // Показываем кнопку "Продолжить" только при первичной загрузке
                    if isInitialUpload {
                        continueButton
                    }
                }

                NavigationLink(destination: ExpensesChartView(), isActive: $navigateToAnalytics) {
                    EmptyView()
                }
            }
            .ignoresSafeArea()
            .onAppear {
                Task {
                    await transactionStore.fetchTransactions()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Text("Предпросмотр транзакций")
                .font(.title2.bold())
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 95)
        .padding(.bottom, 16)
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Загрузка транзакций...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .foregroundColor(.white)
            Spacer()
        }
    }

    private var transactionListView: some View {
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
                                    if let token = KeychainHelper.shared.readAccessToken() {
                                        TransactionService.shared.updateCategory(
                                            transactionID: tx.id,
                                            to: cat,
                                            token: token
                                        ) { _ in
                                            Task {
                                                await AnalyticsService.shared.fetchCategoryAnalytics()
                                            }
                                        }
                                    }
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
    }

    private var continueButton: some View {
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
}
