import SwiftUI

struct TransactionHistoryResponse: Codable {
    let transactions: [Transaction]
}

struct TransactionHistoryView: View {
    @EnvironmentObject var store: TransactionStore

    @State private var selectedCategory: String? = nil
    @State private var selectedYearMonth: String? = nil
    @State private var hasLoaded = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                // Заголовок
                HStack {
                    Text("📝")
                        .font(.system(size: 32))
                    Text("История трат")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding(.top, 125)

                // Подзаголовок
                Text("Здесь Вы можете увидеть историю трат и информацию по ним")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Фильтры и сброс
                HStack(spacing: 12) {
                    Menu {
                        Button("Все месяцы") { selectedYearMonth = nil }
                        ForEach(uniqueYearMonths(), id: \.self) { ym in
                            Button(ym) { selectedYearMonth = ym }
                        }
                    } label: {
                        Label(selectedYearMonth ?? "Месяц", image: "")
                            .labelStyle(EmojiLabelStyle(emoji: "📅"))
                    }

                    Menu {
                        Button("Все категории") { selectedCategory = nil }
                        ForEach(uniqueCategories(), id: \.self) { category in
                            Button(category) { selectedCategory = category }
                        }
                    } label: {
                        Label(selectedCategory ?? "Категория", image: "")
                            .labelStyle(EmojiLabelStyle(emoji: "🗂"))
                    }

                    Button("↺") {
                        selectedCategory = nil
                        selectedYearMonth = nil
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

                // Контент
                if store.transactions.isEmpty {
                    Spacer()
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else {
                    // Общая сумма вне скролла
                    let total = filteredAndSortedTransactions().reduce(0) { $0 + $1.amount }
                    Text(String(format: "%.0f₽", total))
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Список транзакций
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredAndSortedTransactions()) { tx in
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
                                        Text(String(format: "%.0f₽", tx.amount))
                                            .foregroundColor(tx.isIncome ? .green : .white)
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
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }

                Spacer()
            }
            .padding(.bottom, 80)
        }
        .ignoresSafeArea()
        .onAppear {
            if !hasLoaded {
                hasLoaded = true
                store.fetchTransactions()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if selectedYearMonth == nil {
                        selectedYearMonth = uniqueYearMonths().first
                    }
                }
            }
        }
    }

    // Фильтрация и сортировка
    func filteredAndSortedTransactions() -> [Transaction] {
        return store.transactions
            .filter { tx in
                let matchCategory = selectedCategory == nil || tx.category == selectedCategory
                let matchYearMonth: Bool
                if let ym = selectedYearMonth, let txDate = parseDate(tx.date) {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ru_RU")
                    formatter.dateFormat = "LLLL yyyy"
                    matchYearMonth = formatter.string(from: txDate).capitalized == ym
                } else {
                    matchYearMonth = true
                }
                return matchCategory && matchYearMonth
            }
            .sorted {
                guard let d1 = parseDate($0.date), let d2 = parseDate($1.date) else { return false }
                return d1 > d2
            }
    }

    func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }

    func uniqueCategories() -> [String] {
        Array(Set(store.transactions.map { $0.category })).sorted()
    }

    func uniqueYearMonths() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"

        let dates = store.transactions.compactMap { parseDate($0.date) }

        let monthYearTuples = dates.map { date in
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            return components
        }

        let sorted = monthYearTuples
            .compactMap { $0 }
            .sorted {
                if $0.year == $1.year {
                    return ($0.month ?? 0) > ($1.month ?? 0)
                }
                return ($0.year ?? 0) > ($1.year ?? 0)
            }

        var seen: Set<String> = []
        let result = sorted.compactMap { comp -> String? in
            guard let date = Calendar.current.date(from: comp) else { return nil }
            let str = formatter.string(from: date).capitalized
            if seen.contains(str) {
                return nil
            } else {
                seen.insert(str)
                return str
            }
        }

        return result
    }

    func iconName(for category: String) -> String {
        switch category {
        case "Магазины": return "cart.fill"
        case "Транспорт": return "bus.fill"
        case "Пополнение": return "plus.circle.fill"
        case "Переводы": return "arrow.left.arrow.right"
        case "Развлечения": return "gamecontroller.fill"
        case "Доход": return "creditcard.fill"
        default: return "questionmark.circle"
        }
    }

    func iconColor(for category: String) -> Color {
        switch category {
        case "Магазины": return .purple
        case "Транспорт": return .red
        case "Пополнение": return .blue
        case "Переводы": return .orange
        case "Развлечения": return .pink
        case "Доход": return .green
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
