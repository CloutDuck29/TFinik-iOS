// MARK: - Окно предпросмотра транзакций с сортировкой и фильтрами

import SwiftUI

struct TransactionPreviewView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @EnvironmentObject var auth: AuthService
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var selectedBank: String? = nil
    @State private var selectedYearMonth: String? = nil
    @AppStorage("selectedTab") private var selectedTab: String = "expenses"
    @State private var showMainBab = false

    let isInitialUpload: Bool
    let categories = ["Кофейни", "Магазины", "Транспорт", "Доставка", "Развлечения", "Пополнение", "ЖКХ", "Переводы", "Другие"]

    private var filteredTransactions: [Transaction] {
        transactionStore.transactions
            .filter { tx in
                let bankMatch = selectedBank == nil || tx.bank.lowercased() == selectedBank
                let ym = String(tx.date.prefix(7))
                let dateMatch = selectedYearMonth == nil || ym == selectedYearMonth
                return bankMatch && dateMatch
            }
            .sorted { lhs, rhs in
                lhs.date > rhs.date  //сортировка по убыванию
            }
    }


    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Spacer().frame(height: 20)
                    Text("Предпросмотр транзакций")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }

                filterView

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
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                Task {
                    await transactionStore.fetchTransactions()
                }
            }
        }
        .fullScreenCover(isPresented: $showMainBab) {
            MainBabView()
                .environmentObject(auth)
                .environmentObject(transactionStore)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var filterView: some View {
        let normalizedBank = selectedBank?.lowercased()

        let bankFilteredTransactions = transactionStore.transactions.filter {
            normalizedBank == nil || $0.bank.lowercased() == normalizedBank
        }

        let availableMonths = Array(Set(
            bankFilteredTransactions.map { String($0.date.prefix(7)) }
        )).sorted(by: >)

        return HStack(spacing: 24) {
            Picker("Месяц", selection: $selectedYearMonth) {
                Text("Все месяцы").tag(String?.none)
                ForEach(availableMonths, id: \.self) { ym in
                    Text(ym).tag(String?.some(ym))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.blue)

            Picker("Банк", selection: $selectedBank) {
                Text("Все банки").tag(String?.none)
                ForEach(Array(Set(transactionStore.transactions.map { $0.bank.lowercased() })), id: \.self) { bank in
                    Text(bank.capitalized).tag(String?.some(bank))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.blue)
        }
        .font(.subheadline)
        .padding(.horizontal)
    }

    //Загрузка транзакций, в случае если долго грузится
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

                            Text("\(tx.bank.capitalized) • \(tx.date)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        //Зеленый пополнение, если не пополнение - красный
                        let amountColor: Color = tx.category == "Пополнение" ? .green : (tx.amount >= 0 ? .green : .red)
                        Text("\(tx.amount, specifier: "%.2f") ₽")
                            .foregroundColor(amountColor)
                            .fontWeight(.semibold)
                    }

                    Menu {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                if let index = transactionStore.transactions.firstIndex(where: { $0.id == tx.id }) {
                                    transactionStore.transactions[index].category = cat

                                    if cat == "Пополнение" {
                                        //Смена знака в случае пополнения
                                        if transactionStore.transactions[index].amount < 0 {
                                            transactionStore.transactions[index].amount *= -1
                                        }
                                    } else {
                                        //Смена знака в случае не пополнения
                                        if transactionStore.transactions[index].amount > 0 {
                                            transactionStore.transactions[index].amount *= -1
                                        }
                                    }
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
            selectedTab = "expenses"
            showMainBab = true
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
