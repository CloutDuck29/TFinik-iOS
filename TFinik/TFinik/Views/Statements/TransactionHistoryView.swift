import SwiftUI

struct TransactionHistoryResponse: Codable {
    let transactions: [Transaction]
}

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
            Text("История трат")
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }

    var filters: some View {
        HStack(spacing: 12) {
            Menu {
                Button("Все месяцы") {
                    selectedYearMonth = nil
                    applyFilters()
                }
                ForEach(allYearMonths, id: \.self) { ym in
                    Button(ym) {
                        selectedYearMonth = ym
                        applyFilters()
                    }
                }
            } label: {
                Label(selectedYearMonth ?? "Месяц", image: "")
                    .labelStyle(EmojiLabelStyle(emoji: "📅"))
            }

            Menu {
                Button("Все категории") {
                    selectedCategory = nil
                    applyFilters()
                }
                ForEach(uniqueCategories(), id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                        applyFilters()
                    }
                }
            } label: {
                Label(selectedCategory ?? "Категория", image: "")
                    .labelStyle(EmojiLabelStyle(emoji: "🗂"))
            }

            Button("↺") {
                selectedCategory = nil
                selectedYearMonth = nil
                if store.transactions.isEmpty {
                    loadData()
                } else {
                    applyFilters()
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
        }
        .font(.footnote)
        .foregroundColor(.gray)
    }

    func loadData() {
        Task {
            isLoading = true
            await store.fetchTransactions()
            allYearMonths = uniqueYearMonths()
            if selectedYearMonth == nil {
                selectedYearMonth = allYearMonths.first
            }
            applyFilters()
            isLoading = false
        }
    }

    func applyFilters() {
        if store.transactions.isEmpty {
            Task {
                isLoading = true
                await store.fetchTransactions()
                allYearMonths = uniqueYearMonths()
                isLoading = false
                applyFilters()
            }
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"

        print("📌 selectedYM: \(selectedYearMonth ?? "nil")")

        filteredTransactions = store.transactions
            .filter { tx in
                guard !tx.isIncome, tx.category != "Пополнение" else { return false }

                let matchCategory = selectedCategory == nil || tx.category == selectedCategory

                let matchYM: Bool = {
                    guard let ym = selectedYearMonth,
                          let date = parseDate(tx.date) else {
                        print("⚠️ Ошибка парсинга даты: \(tx.date)")
                        return true
                    }

                    let formatted = formatter.string(from: date).capitalized
                    return formatted.lowercased() == ym.lowercased()
                }()

                return matchCategory && matchYM
            }
            .sorted {
                guard let d1 = parseDate($0.date), let d2 = parseDate($1.date) else { return false }
                return d1 > d2
            }

        totalAmount = filteredTransactions.reduce(0) { $0 + $1.amount }

        print("✅ Результат: \(filteredTransactions.count) транзакций")
    }

    func uniqueYearMonths() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"

        let sortedDates = store.transactions
            .filter { !$0.isIncome && $0.category != "Пополнение" }
            .compactMap { parseDate($0.date) }
            .sorted(by: >)

        var seen: Set<String> = []
        var result: [String] = []

        for date in sortedDates {
            let ym = formatter.string(from: date).capitalized
            if !seen.contains(ym) {
                seen.insert(ym)
                result.append(ym)
            }
        }

        return result
    }

    func uniqueCategories() -> [String] {
        Array(Set(
            store.transactions
                .filter { !$0.isIncome && $0.category != "Пополнение" }
                .map { $0.category }
        )).sorted()
    }

    func parseDate(_ string: String?) -> Date? {
        guard let string = string?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: string) {
            return date
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return isoFormatter.date(from: string)
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
        case "Магазины": return "cart.fill"
        case "Транспорт": return "bus.fill"
        case "Переводы": return "arrow.left.arrow.right"
        case "Развлечения": return "gamecontroller.fill"
        default: return "questionmark.circle"
        }
    }

    func iconColor(for category: String) -> Color {
        switch category {
        case "Магазины": return .purple
        case "Транспорт": return .red
        case "Переводы": return .orange
        case "Развлечения": return .pink
        default: return .gray
        }
    }
}

struct EmojiLabelStyle: LabelStyle {
    let emoji: String

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
            configuration.title
        }
    }
}
