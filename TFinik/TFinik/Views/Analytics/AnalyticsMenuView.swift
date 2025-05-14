// MARK: Меню аналитики

import SwiftUI

struct AnalyticsMenuView: View {
    @AppStorage("selectedTab") private var selectedTab: String = "analytics"
    @State private var destination: AnalyticsDestination?
    @StateObject private var goalStore = GoalStore()

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack {
                    VStack(spacing: 8) {
                        Text("📈")
                            .font(.system(size: 40))
                        Text("Аналитика")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.top, 125)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(Array(cards.enumerated()), id: \.offset) { _, card in
                            let (icon, label, action, fullWidth) = card
                            AnalyticsCard(icon: icon, label: label, action: action)
                                .gridCellColumns(fullWidth ? 2 : 1)
                        }

                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.bottom, 80)
            }
            .ignoresSafeArea()
            .navigationDestination(item: $destination) { dest in
                switch dest {
                case .goals:
                    FinancialGoalsView().environmentObject(goalStore)
                case .expenses:
                    ExpensesGraphView()
                case .income:
                    IncomeGraphView()
                case .history:
                    TransactionHistoryView().environmentObject(TransactionStore())
                }
            }
        }
    }

    private var cards: [(String, String, () -> Void, Bool)] {
        [
            ("🎯", "Цели", { destination = .goals }, false),
            ("💸", "Траты", { destination = .history }, false),
            ("💰", "Расходы", { destination = .expenses }, false),
            ("🤑", "Доходы", { destination = .income }, true)
        ]
    }
}

enum AnalyticsDestination: Hashable {
    case goals, expenses, income, history
}

struct AnalyticsCard: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 40))
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.5), lineWidth: 1)
            )
        }
    }
}
