import SwiftUI

struct OnboardingPagerView: View {
    @State private var page = 0
    @Binding var hasOnboarded: Bool
    @State private var navigateToUpload = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                TabView(selection: $page) {
                    OnboardingStep1View().tag(0)
                    OnboardingStep2View().tag(1)
                    OnboardingStep3View().tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                Spacer()

                HStack {
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(page == 0 ? Color.white : Color.white.opacity(0.3))
                            .frame(width: page == 0 ? 24 : 8, height: 8)
                        Capsule()
                            .fill(page == 1 ? Color.white : Color.white.opacity(0.3))
                            .frame(width: page == 1 ? 24 : 8, height: 8)
                        Capsule()
                            .fill(page == 2 ? Color.white : Color.white.opacity(0.3))
                            .frame(width: page == 2 ? 24 : 8, height: 8)
                    }

                    Spacer()

                    Button(action: {
                        if page < 2 {
                            page += 1
                        } else {
                            navigateToUpload = true
                            // 🔥 НЕ УСТАНАВЛИВАЕМ hasOnboarded ЗДЕСЬ
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 52, height: 52)
                            .background(Circle().fill(Color.white))
                            .foregroundStyle(.black)
                            .shadow(radius: 4)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 30)

                NavigationLink(
                    destination: BankStatementUploadView()
                        .environmentObject(TransactionStore()),
                    isActive: $navigateToUpload
                ) {
                    EmptyView()
                }

            }
        }
        .ignoresSafeArea()
    }
}
