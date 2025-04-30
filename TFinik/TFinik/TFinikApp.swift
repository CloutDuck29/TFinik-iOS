import SwiftUI

@main
struct TFinikApp: App {
    @StateObject private var auth = AuthService()
    @StateObject private var transactionStore = TransactionStore()
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if !auth.isLoggedIn {
                    ContentView(hasOnboarded: $hasOnboarded)
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                } else if !hasOnboarded {
                    OnboardingPagerView(hasOnboarded: $hasOnboarded)
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                } else if !hasUploadedStatement {
                    BankStatementUploadView()
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                } else {
                    MainBabView()
                        .environmentObject(auth)
                        .environmentObject(transactionStore)
                }
            }
        }
    }
}
