import SwiftUI

struct MainBabView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var transactionStore: TransactionStore
    @AppStorage("selectedTab") private var selectedTab: String = "expenses"

    var body: some View {
        NavigationStack {
            ZStack {
                switch selectedTab {
                case "expenses":
                    ExpensesChartView()
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                case "analytics":
                    AnalyticsMenuView()
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                case "profile":
                    ProfileMenuView()
                        .environmentObject(auth) // ✅ обязательно!
                        .environmentObject(transactionStore)
                default:
                    ExpensesChartView()
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                }

                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
    }
}
