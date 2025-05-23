// MARK: - Редактирование финансовой цели

import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var goalStore: GoalStore

    let goal: FinancialGoal

    @State private var name: String
    @State private var targetAmount: String
    @State private var deadline: Date

    init(goal: FinancialGoal) {
        self.goal = goal
        _name = State(initialValue: goal.name)
        _targetAmount = State(initialValue: String(Int(goal.targetAmount)))
        _deadline = State(initialValue: goal.deadline ?? Date())
    }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 32) {
                Text("✏️")
                    .font(.system(size: 40))
                Text("Редактировать цель")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    TextField("Название цели", text: $name)
                        .textFieldStyle(.roundedBorder)

                    TextField("Желаемая сумма (₽)", text: $targetAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                    DatePicker("Срок", selection: $deadline, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Button("Сохранить изменения", action: saveChanges)
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

    private func saveChanges() {
        guard !name.isEmpty, let amount = Double(targetAmount) else { return }
        goalStore.updateGoal(id: goal.originalId, name: name, targetAmount: amount, deadline: deadline)
        dismiss()
    }
}
