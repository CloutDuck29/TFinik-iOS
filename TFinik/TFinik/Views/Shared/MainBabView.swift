import SwiftUI

struct MainBabView: View {
    @AppStorage("selectedTab") private var selectedTab: String = "expenses"

    var body: some View {
        NavigationStack {
            ZStack {
                switch selectedTab {
                case "expenses":
                    ExpensesChartView()
                case "analytics":
                    AnalyticsMenuView()
                case "profile":
                    ProfileMenuView()
                default:
                    ExpensesChartView()
                }

                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
    }
}
