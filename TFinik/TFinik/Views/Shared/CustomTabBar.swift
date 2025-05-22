import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack {
            tabItem(icon: "bag.fill", title: "Расходы", tab: "expenses")
            Spacer()
            tabItem(icon: "chart.bar.fill", title: "Аналитика", tab: "analytics")
            Spacer()
            tabItem(icon: "person.crop.circle", title: "Профиль", tab: "profile")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 10)
        .background(Color.clear)
    }

    private func tabItem(icon: String, title: String, tab: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == tab ? .purple : .white)
        }
    }
}
