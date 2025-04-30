import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthService
    @Binding var hasOnboarded: Bool
    @State private var hasShownWelcome: Bool = false

    var body: some View {
        NavigationStack {
            if !auth.isLoggedIn {
                RegisterView(hasOnboarded: $hasOnboarded)
            } else if !hasOnboarded {
                OnboardingPagerView(hasOnboarded: $hasOnboarded)
            } else if !hasShownWelcome {
                WelcomeView(hasShownWelcome: $hasShownWelcome)
            } else {
                BankStatementUploadView(hasOnboarded: $hasOnboarded)
            }
        }
    }
}
