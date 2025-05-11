import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) var dismiss

    var goal: FinancialGoal

    @State private var name: String
    @State private var targetAmount: String
    @State private var deadline: Date

    init(goal: FinancialGoal) {
        self.goal = goal
        _name = State(initialValue: goal.name)
        _targetAmount = State(initialValue: String(Int(goal.targetAmount)))
        _deadline = State(initialValue: Date()) // Заменить, если есть хранимое значение
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

                Group {
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

                Button("Сохранить изменения") {
                    saveChanges()
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

    private func saveChanges() {
        guard !name.isEmpty, let amount = Double(targetAmount) else { return }

        // TODO: сохранить изменения в цель (через API или локально)
        print("Цель обновлена: \(name), сумма: \(amount), срок: \(deadline)")
        dismiss()
    }
}
