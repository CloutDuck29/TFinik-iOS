import SwiftUI

struct AddAmountView: View {
    let goal: FinancialGoal
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var goalStore: GoalStore
    @State private var showOverflowAlert = false
    @State private var amountText: String = ""
    
    var onSuccess: (() -> Void)? = nil

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
        // 👇 Добавляем alert здесь
        .alert("⚠️ Превышение цели", isPresented: $showOverflowAlert) {
            Button("Ок", role: .cancel) { }
        } message: {
            Text("Добавляемая сумма превышает целевое значение. Пожалуйста, введите меньшую сумму.")
        }
    }


    private func addAmount() {
        guard let amount = Double(amountText), amount > 0 else { return }

        if let dto = goalStore.goals.first(where: { $0.name == goal.name }) {
            let total = dto.current_amount + amount
            if total > dto.target_amount {
                showOverflowAlert = true
                return
            }

            goalStore.addAmount(to: dto.id, amount: amount)
            onSuccess?()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                goalStore.fetchGoals()
            }

            dismiss()
        }
    }
}
