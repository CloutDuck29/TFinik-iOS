import SwiftUI

/// Первый экран онбординга: кратко о главной возможности приложения
struct OnboardingStep1View: View {
    var body: some View {
        VStack(spacing: 24) {
            // Иконка или иллюстрация
            Image(systemName: "chart.pie.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)

            // Заголовок
            Text("Управляйте своими финансами")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Описание
            Text("Анализируйте доходы и расходы, ставьте цели и достигайте их вместе с T‑Finik.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct OnboardingStep1View_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStep1View()
            .preferredColorScheme(.dark)
    }
}
