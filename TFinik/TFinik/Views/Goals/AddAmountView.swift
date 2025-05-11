import SwiftUI

struct AddAmountView: View {
    let goal: FinancialGoal
    @Environment(\.dismiss) var dismiss

    @State private var amountText: String = ""

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 24) {
                Text("💵")
                    .font(.system(size: 40))
                Text("Добавить сумму к цели")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Сумма (₽)", text: $amountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }

                Button("Занести") {
                    addAmount()
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 60)
        }
    }

    private func addAmount() {
        guard let amount = Double(amountText), amount > 0 else {
            return // можно добавить alert
        }

        // TODO: отправка суммы к цели на сервер или локально
        print("Добавлено \(amount)₽ к цели '", goal.name, "'")
        dismiss()
    }
}
