// MARK: Меню профиля

import SwiftUI

struct ProfileMenuView: View {
    @AppStorage("selectedTab") private var selectedTab: String = "analytics"
    @EnvironmentObject var auth: AuthService
    @State private var destination: ProfileDestination?
    @EnvironmentObject var transactionStore: TransactionStore

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack {
                    VStack(spacing: 8) {
                        Text("👦🏻")
                            .font(.system(size: 40))
                        Text("Профиль")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.top, 125)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(cards, id: \.label) { card in
                            ProfileCard(icon: card.icon, label: card.label) {
                                destination = card.destination
                            }
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
                case .statements:
                    BankUploadView().environmentObject(auth)
                case .advice:
                    FinanceAdviceView()
                case .forecast:
                    ExpenseForecastView()
                        .environmentObject(transactionStore)
                case .portrait:
                    MonthPortraitView().environmentObject(auth)
                }
            }
        }
        .onAppear {
            Task {
                await transactionStore.fetchTransactions()
            }
        }
    }

    private var cards: [ProfileCardData] {
        [
            .init(icon: "🎯", label: "Выписки", destination: .statements),
            .init(icon: "🔥", label: "Советы", destination: .advice),
            .init(icon: "🛠", label: "Прогноз", destination: .forecast),
            .init(icon: "😁", label: "Портрет", destination: .portrait)
        ]
    }
}


struct ProfileCard: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon).font(.system(size: 40))
                Text(label).font(.subheadline).foregroundColor(.white)
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

struct ProfileCardData: Hashable {
    let icon: String
    let label: String
    let destination: ProfileDestination
}

enum ProfileDestination: Hashable {
    case statements, advice, forecast, portrait
}
