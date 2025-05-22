import SwiftUI

struct TransactionPreviewView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var navigateToAnalytics = false

    @State private var selectedBank: String? = nil
    @State private var selectedYearMonth: String? = nil

    let isInitialUpload: Bool

    let categories = ["Кофейни", "Магазины", "Транспорт", "Доставка", "Развлечения", "Пополнение", "ЖКХ", "Переводы", "Другие"]

    private var filteredTransactions: [Transaction] {
        transactionStore.transactions.filter { tx in
            let bankMatch = selectedBank == nil || tx.bank == selectedBank
            let ym = String(tx.date.prefix(7)) // формат YYYY-MM
            let dateMatch = selectedYearMonth == nil || ym == selectedYearMonth
            return bankMatch && dateMatch
        }
    }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                // Заголовок
                VStack(spacing: 8) {
                    Spacer().frame(height: 20)
                    Text("Предпросмотр транзакций")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }

                // Фильтры в одну строку
                filterView

                // Список или прелоадер
                if transactionStore.transactions.isEmpty {
                    loadingView
                } else {
                    ScrollView {
                        transactionListView
                    }

                    if isInitialUpload {
                        continueButton
                    }
                }

                NavigationLink(destination: ExpensesChartView(), isActive: $navigateToAnalytics) {
                    EmptyView()
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                Task {
                    await transactionStore.fetchTransactions()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var filterView: some View {
        HStack(spacing: 24) {
            // Месяц
            Picker("Месяц", selection: $selectedYearMonth) {
                Text("Все месяцы").tag(String?.none)
                ForEach(Array(Set(transactionStore.transactions.map {
                    String($0.date.prefix(7))
                })).sorted(by: >), id: \.self) { ym in
                    Text(ym).tag(String?.some(ym))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.blue)

            // Банк
            Picker("Банк", selection: $selectedBank) {
                Text("Все банки").tag(String?.none)
                ForEach(Array(Set(transactionStore.transactions.map { $0.bank })), id: \.self) { bank in
                    Text(bank).tag(String?.some(bank))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.blue)
        }
        .font(.subheadline)
        .padding(.horizontal)
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
        LazyVStack(spacing: 16) {
            ForEach(filteredTransactions, id: \.id) { tx in
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
                                if let index = transactionStore.transactions.firstIndex(where: { $0.id == tx.id }) {
                                    transactionStore.transactions[index].category = cat
                                }
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
