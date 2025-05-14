import SwiftUI

struct OnboardingStep3View: View {
    @Binding var step: OnboardingStep
    @State private var isVisible = false

    var body: some View {
        ZStack {
            if isVisible {
                Image("palma")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 500)
                    .offset(x: 125, y: -250)
                    .transition(.opacity)

                Image("car")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 280)
                    .offset(x: 150, y: -20)
                    .transition(.opacity)
            }

            VStack {
                Spacer()

                if isVisible {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Создавайте финансовые цели")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        Text("Вместе с TFinik Вы сможете накопить на поездку в Сочи, а затем и на Mercedes AMG.")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            isVisible = step == .goals
        }
        .onChange(of: step) { newStep in
            withAnimation(.easeInOut(duration: 0.3)) {
                isVisible = newStep == .goals
            }
        }
        .navigationBarHidden(true)
    }
}
