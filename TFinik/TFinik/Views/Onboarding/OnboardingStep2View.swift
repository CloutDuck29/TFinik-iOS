import SwiftUI

struct OnboardingStep2View: View {
    var body: some View {
        ZStack {
            // Предметы
            Group {
                Image("beer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 190)
                    .offset(x: -180, y: -280)

                Image("snickers")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 300)
                    .offset(x: 175, y: -350)

                Image("shawarma")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 190)
                    .offset(x: 15, y: -120)

                Image("jacket")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 390, height: 250)
                    .rotationEffect(.degrees(35))
                    .offset(x: -180, y: 40)

                Image("iphone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 280)
                    .offset(x: 240, y: -20)
            }

            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Прогнозируйте расходы вперед")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Мы учитываем спонтанные покупки и прогнозируем, когда они могут повториться.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarHidden(true)
    }
}

struct OnboardingStep2View_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStep2View()
            .preferredColorScheme(.dark)
    }
}

