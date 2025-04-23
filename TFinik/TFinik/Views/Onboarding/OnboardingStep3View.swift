import SwiftUI

struct OnboardingStep3View: View {
    var body: some View {
        ZStack {
            Image("palma")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 500)
                .offset(x: 125, y: -250)

            Image("car")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 280)
                .offset(x: 150, y: -20)

            VStack {
                Spacer()

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
            }
        }
        .navigationBarHidden(true)
    }
}

struct OnboardingStep3View_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStep3View()
            .preferredColorScheme(.dark)
    }
}
