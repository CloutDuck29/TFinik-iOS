import SwiftUI

@main
struct TFinikApp: App {
    @StateObject private var auth = AuthService()
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            ContentView(hasOnboarded: $hasOnboarded)
                .environmentObject(auth)
        }
    }
}

