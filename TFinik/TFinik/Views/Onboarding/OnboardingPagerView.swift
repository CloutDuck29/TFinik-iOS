import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case intro, forecast, goals
}

struct OnboardingPagerView: View {
    @State private var currentStep: OnboardingStep = .intro
    @Binding var hasOnboarded: Bool
    @State private var navigateToUpload = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                TabView(selection: $currentStep) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        onboardingView(for: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                Spacer()

                HStack {
                    HStack(spacing: 8) {
                        ForEach(OnboardingStep.allCases.indices, id: \.self) { index in
                            Capsule()
                                .fill(currentStep.rawValue == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: currentStep.rawValue == index ? 24 : 8, height: 8)
                        }
                    }

                    Spacer()

                    Button(action: {
                        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                            currentStep = nextStep
                        } else {
                            navigateToUpload = true
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

    @ViewBuilder
    private func onboardingView(for step: OnboardingStep) -> some View {
        switch step {
        case .intro:
            OnboardingStep1View(step: $currentStep)
        case .forecast:
            OnboardingStep2View(step: $currentStep)
        case .goals:
            OnboardingStep3View(step: $currentStep)
        }
    }
}
