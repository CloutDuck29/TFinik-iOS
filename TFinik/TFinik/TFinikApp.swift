import SwiftUI

@main
struct TFinikApp: App {
    @StateObject private var auth = AuthService()
    @StateObject private var transactionStore = TransactionStore()
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                if hasUploadedStatement {
                    NavigationStack {
                        MainBabView()
                            .environmentObject(auth)
                            .environmentObject(transactionStore)
                    }
                } else {
                    NavigationStack {
                        BankStatementUploadView(hasOnboarded: $hasOnboarded)
                            .environmentObject(auth)
                            .environmentObject(transactionStore)
                    }
                }
            } else {
                ContentView(hasOnboarded: $hasOnboarded)
                    .environmentObject(auth)
                    .environmentObject(transactionStore)
            }
        }
    }
}
