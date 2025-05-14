import SwiftUI

struct GoalDetailView: View {
    @EnvironmentObject var goalStore: GoalStore
    let goalId: UUID

    var goal: FinancialGoal? {
        goalStore.goals.map { $0.toModel() }.first(where: { $0.id == goalId })
    }


    @State private var isEditing = false
    @State private var isAddingAmount = false

    var body: some View {
        ZStack {
            BackgroundView()

            if let goal = goal {
                VStack(spacing: 20) {
                    Text("🎯")
                        .font(.system(size: 40))
                    Text(goal.name)
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 12) {
                        ProgressView(value: goal.currentAmount / goal.targetAmount)
                            .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(4)

                        Text("Прогресс: \(Int(goal.currentAmount / goal.targetAmount * 100))% (\(Int(goal.currentAmount))₽ из \(Int(goal.targetAmount))₽)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    HStack(spacing: 20) {
                        Button("Редактировать") {
                            isEditing = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(12)

                        Button("Добавить сумму") {
                            isAddingAmount = true
                        }
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 60)
                .sheet(isPresented: $isEditing) {
                    EditGoalView(goal: goal).environmentObject(goalStore)
                }
                .sheet(isPresented: $isAddingAmount) {
                    AddAmountView(goal: goal).environmentObject(goalStore)
                }
            } else {
                Text("Цель не найдена")
                    .foregroundColor(.white)
            }
        }
    }
}
