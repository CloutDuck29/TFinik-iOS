import SwiftUI

struct TransactionHistoryResponse: Codable {
    let transactions: [Transaction]
}

struct TransactionHistoryView: View {
    @EnvironmentObject var store: TransactionStore

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

                // Фильтры
                HStack(spacing: 16) {
                    Label("Дата", image: "")
                        .labelStyle(EmojiLabelStyle(emoji: "📅"))
                    Label("Категория", image: "")
                        .labelStyle(EmojiLabelStyle(emoji: "🗂"))
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
                    let total = store.transactions.reduce(0) { $0 + $1.amount }
                    Text(String(format: "%.0f₽", total))
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Список транзакций
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedTransactions()) { tx in
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
            store.fetchTransactions()
        }
    }

    // Сортировка транзакций по убыванию даты
    func sortedTransactions() -> [Transaction] {
        store.transactions.sorted {
            guard let d1 = parseDate($0.date), let d2 = parseDate($1.date) else { return false }
            return d1 > d2
        }
    }

    func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // формат от сервера
        return formatter.date(from: string)
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
