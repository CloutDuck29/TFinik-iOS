import SwiftUI

struct FinancialGoal: Identifiable, Hashable {
    let id: UUID
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let isCompleted: Bool
}

struct FinancialGoalsView: View {
    @EnvironmentObject var goalStore: GoalStore
    @State private var selectedFilter: FilterType = .all
    @State private var selectedGoal: FinancialGoal? = nil

    enum FilterType {
        case all, active, completed
    }

    private var filteredGoals: [FinancialGoal] {
        let goals = goalStore.goals.map { $0.toModel() }
        switch selectedFilter {
        case .all:
            return goals
        case .active:
            return goals.filter { !$0.isCompleted }
        case .completed:
            return goals.filter { $0.isCompleted }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack(spacing: 24) {
                    HStack {
                        Text("🎯")
                            .font(.system(size: 32))
                        Text("Финансовые цели")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)

                    HStack {
                        FilterButton(title: "🟢 Активные", color: .green, isSelected: selectedFilter == .active) {
                            selectedFilter = .active
                        }
                        FilterButton(title: "🔴 Завершенные", color: .red, isSelected: selectedFilter == .completed) {
                            selectedFilter = .completed
                        }
                        FilterButton(title: "Все", color: .white, isSelected: selectedFilter == .all) {
                            selectedFilter = .all
                        }
                    }

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredGoals) { goal in
                                NavigationLink(destination: GoalDetailView(goalId: goal.id).environmentObject(goalStore)) {
                                    GoalCard(goal: goal)
                                }
                            }
                        }
                        .padding()
                    }

                    Spacer()

                    NavigationLink(destination: CreateGoalView().environmentObject(goalStore)) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                goalStore.fetchGoals()
            }

        }
    }
}
struct FilterButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(8)
                .background(isSelected ? color.opacity(0.2) : Color.clear)
                .foregroundColor(color)
                .cornerRadius(10)
        }
    }
}

struct GoalCard: View {
    let goal: FinancialGoal

    var progress: Double {
        min(goal.currentAmount / goal.targetAmount, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(goal.name)
                    .foregroundColor(.white)
                    .bold()
                Spacer()
                Text("\(Int(goal.targetAmount))₽")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                .background(Color.gray.opacity(0.3))
                .cornerRadius(4)

            Text("\(Int(progress * 100))% выполнено")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}
