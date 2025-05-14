import SwiftUI

struct CreateGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var goalStore: GoalStore

    @State private var name = ""
    @State private var targetAmount = ""
    @State private var deadline = Date()

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                Text("🎯")
                    .font(.system(size: 40))
                Text("Новая финансовая цель")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    TextField("Название цели", text: $name)
                        .textFieldStyle(.roundedBorder)

                    TextField("Желаемая сумма (₽)", text: $targetAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                    DatePicker("Срок достижения", selection: $deadline, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Button("Создать цель", action: createGoal)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 80)
        }
    }

    private func createGoal() {
        guard !name.isEmpty, let amount = Double(targetAmount) else { return }
        goalStore.createGoal(name: name, targetAmount: amount, deadline: deadline)
        dismiss()
    }
}
