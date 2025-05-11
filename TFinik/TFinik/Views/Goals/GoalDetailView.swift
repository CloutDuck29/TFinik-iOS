import SwiftUI

struct GoalDetailView: View {
    let goal: FinancialGoal
    @State private var isEditing = false
    @State private var isAddingAmount = false

    var progress: Double {
        min(goal.currentAmount / goal.targetAmount, 1.0)
    }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                Text("🎯")
                    .font(.system(size: 40))
                Text(goal.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(4)

                    Text("Прогресс: \(Int(progress * 100))% (\(Int(goal.currentAmount))₽ из \(Int(goal.targetAmount))₽)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Дополнительная информация (заглушка срока)
                    Text("Срок достижения: —")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Ежемесячный платёж: —")
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
                EditGoalView(goal: goal)
            }
            .sheet(isPresented: $isAddingAmount) {
                AddAmountView(goal: goal)
            }
        }
    }
}
