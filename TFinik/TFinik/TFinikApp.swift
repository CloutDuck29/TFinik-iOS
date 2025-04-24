import SwiftUI

@main
struct TFinikApp: App {
    @StateObject private var auth = AuthService()
    @StateObject private var transactionStore = TransactionStore()
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            ContentView(hasOnboarded: $hasOnboarded)
                .environmentObject(auth)
                .environmentObject(transactionStore)
        }
    }
}
