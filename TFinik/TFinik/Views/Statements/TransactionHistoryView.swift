// MARK: - Окно истории операций

import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var store: TransactionStore

    @State private var isLoading = true
    @State private var selectedCategory: String? = nil
    @State private var selectedYearMonth: String? = nil
    @State private var filteredTransactions: [Transaction] = []
    @State private var totalAmount: Double = 0
    @State private var allYearMonths: [String] = []

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                header
                filters

                if isLoading {
                    Spacer()
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else if filteredTransactions.isEmpty {
                    Spacer()
                    Text("Нет транзакций")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    Text("Всего: \(Int(totalAmount))₽")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 8)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTransactions) { tx in
                                transactionCard(tx)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }

                Spacer()
            }
            .padding(.top, 80)
            .padding(.bottom, 60)
        }
        .ignoresSafeArea()
        .onAppear(perform: loadData)
    }

    var header: some View {
        HStack {
            Text("📝")
                .font(.system(size: 32))
            Text("История операций")
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }

    var filters: some View {
        HStack(spacing: 12) {
            Picker("📅", selection: $selectedYearMonth.onChange { newYM in
                Task {
                    isLoading = true
                    await store.fetchTransactions()
                    applyFilters()
                    isLoading = false
                }
            }) {
                Text("Все месяцы").tag(String?.none)
                ForEach(allYearMonths, id: \.self) { ym in
                    Text(ym).tag(String?.some(ym))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.gray)

            Picker("🗂", selection: $selectedCategory.onChange { _ in applyFilters() }) {
                Text("Все категории").tag(String?.none)
                ForEach(uniqueCategories(), id: \.self) { category in
                    Text(category).tag(String?.some(category))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.gray)

            Button("↺") {
                selectedCategory = nil
                selectedYearMonth = nil
                loadData()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
        }
        .font(.footnote)
    }

    func loadData() {
        isLoading = true
        Task {
            await store.fetchTransactions()
            allYearMonths = uniqueYearMonths()
            let currentYM = {
                let comps = Calendar.current.dateComponents([.year, .month], from: Date())
                return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
            }()
            selectedYearMonth = allYearMonths.contains(currentYM) ? currentYM : allYearMonths.first
            applyFilters()
            isLoading = false
        }
    }

    func applyFilters() {
        print("📌 selectedYM: \(selectedYearMonth ?? "nil")")
        print("📦 Всего загружено транзакций: \(store.transactions.count)")

        var selectedYear: Int? = nil
        var selectedMonth: Int? = nil
        if let ym = selectedYearMonth {
            let parts = ym.split(separator: "-").compactMap { Int($0) }
            if parts.count == 2 {
                selectedYear = parts[0]
                selectedMonth = parts[1]
            }
        }

        filteredTransactions = store.transactions
            .filter { tx in
                let matchCategory = selectedCategory == nil || tx.category == selectedCategory

                let matchYM: Bool = {
                    guard let date = parseDate(tx.date) else {
                        return false
                    }
                    if let year = selectedYear, let month = selectedMonth {
                        let comps = Calendar.current.dateComponents([.year, .month], from: date)
                        return comps.year == year && comps.month == month
                    }
                    return true
                }()

                return matchCategory && matchYM
            }
            .sorted {
                guard let d1 = parseDate($0.date), let d2 = parseDate($1.date) else { return false }
                return d1 > d2
            }

        totalAmount = filteredTransactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + $1.amount }

        print("✅ Результат: \(filteredTransactions.count) транзакций")
    }

    func uniqueYearMonths() -> [String] {
        let dates = store.transactions
            .compactMap { parseDate($0.date) }
            .sorted(by: >)

        var seen: Set<String> = []
        var result: [String] = []

        for date in dates {
            let comps = Calendar.current.dateComponents([.year, .month], from: date)
            let ym = String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
            if seen.insert(ym).inserted {
                result.append(ym)
            }
        }

        return result
    }

    func uniqueCategories() -> [String] {
        Array(Set(store.transactions.map { $0.category })).sorted()
    }

    func parseDate(_ string: String?) -> Date? {
        guard let raw = string?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        for format in ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss", "dd.MM.yyyy"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) { return date }
        }

        return nil
    }

    func transactionCard(_ tx: Transaction) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(iconColor(for: tx.category).opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: iconName(for: tx.category))
                    .foregroundColor(iconColor(for: tx.category))
            }
            VStack(alignment: .leading) {
                Text(tx.description)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(tx.category)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(tx.date)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(Int(tx.amount))₽")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple, lineWidth: 1)
                )
        )
    }

    func iconName(for category: String) -> String {
        switch category {
        case "Кофейни": return "cup.and.saucer.fill"
        case "Магазины": return "cart.fill"
        case "Транспорт": return "bus.fill"
        case "Доставка": return "bicycle"
        case "Развлечения": return "gamecontroller.fill"
        case "Пополнение": return "arrow.down.circle.fill"
        case "ЖКХ": return "bolt.fill"
        case "Переводы": return "arrow.left.arrow.right"
        case "Другие": return "ellipsis.circle.fill"
        default: return "questionmark.circle"
        }
    }

    func iconColor(for category: String) -> Color {
        switch category {
        case "Кофейни": return .brown
        case "Магазины": return .purple
        case "Транспорт": return .red
        case "Доставка": return .green
        case "Развлечения": return .pink
        case "Пополнение": return .blue
        case "ЖКХ": return .yellow
        case "Переводы": return .orange
        case "Другие": return .gray
        default: return .gray
        }
    }

}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                handler($0)
            }
        )
    }
}
