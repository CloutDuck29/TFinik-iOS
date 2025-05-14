import SwiftUI

struct OnboardingStep1View: View {
    @Binding var step: OnboardingStep
    @State private var isVisible = false
    @State private var currentIndex: Int = 0

    private let banknoteImages = ["banknote500", "banknote1000", "banknote5000"]

    var body: some View {
        VStack {
            Spacer(minLength: 80)

            if isVisible {
                let displayed = [
                    banknoteImages[currentIndex],
                    banknoteImages[(currentIndex + 1) % banknoteImages.count],
                    banknoteImages[(currentIndex + 2) % banknoteImages.count]
                ]

                VStack(alignment: .trailing, spacing: -40) {
                    ForEach(displayed.indices, id: \.self) { idx in
                        Image(displayed[idx])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 4)
                            .offset(x: CGFloat(idx) * 35)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 56)
                .padding(.bottom, 20)
                .transition(.opacity)
            }

            Spacer(minLength: 60)

            if isVisible {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Управляйте своими финансами")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Забудьте о том, чтобы вспоминать, куда вы вчера потратили очередную тысячу рублей.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
            }
        }
        .onAppear {
            isVisible = step == .intro
        }
        .onChange(of: step) { newStep in
            withAnimation(.easeInOut(duration: 0.3)) {
                isVisible = (newStep == .intro)
            }
        }
    }
}
