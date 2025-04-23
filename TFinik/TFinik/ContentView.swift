import SwiftUI
struct ContentView: View {
    @EnvironmentObject var auth: AuthService
    @Binding var hasOnboarded: Bool
    @State private var hasShownWelcome = false

    var body: some View {
        if !auth.isLoggedIn {
            RegisterView(hasOnboarded: $hasOnboarded)
                .environmentObject(auth)
        } else if !hasOnboarded {
            OnboardingPagerView(hasOnboarded: $hasOnboarded)
        } else {
            WelcomeView(hasShownWelcome: $hasShownWelcome)
        }
    }
}
