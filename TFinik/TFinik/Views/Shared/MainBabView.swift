// MARK: - Менюшка приложения

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
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                default:
                    ExpensesChartView()
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                }

                Button("Выйти") {
                    KeychainHelper.shared.clear()
                    TokenStorage.shared.accessToken = nil
                    TokenStorage.shared.refreshToken = nil
                    UserDefaults.standard.set(false, forKey: "hasOnboarded")
                    UserDefaults.standard.set(false, forKey: "hasUploadedStatement")
                    auth.isLoggedIn = false
                }

                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
    }
}
