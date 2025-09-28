import SwiftUI
import SharedModels

struct ActiveGoalsListView: View {
    let goals: [EducationalGoal]
    let hasActiveSubscription: Bool
    let onGoalSelected: (EducationalGoal) -> Void
    
    private var activeGoals: [EducationalGoal] {
        goals.filter { goal in
            if case .completed = goal.status {
                return false
            }
            if case .failed = goal.status {
                return false
            }
            return true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Goals")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !hasActiveSubscription && activeGoals.count >= 3 {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Upgrade for more")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
            
            LazyVStack(spacing: 12) {
                ForEach(activeGoals) { goal in
                    GoalProgressCard(goal: goal) {
                        onGoalSelected(goal)
                    }
                }
            }
        }
    }
}

// MARK: - Goal Progress Card

struct GoalProgressCard: View {
    let goal: EducationalGoal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text(goal.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    ProgressRingView(
                        progress: progressValue,
                        size: 40,
                        lineWidth: 3
                    )
                    .frame(width: 40, height: 40)
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: progressValue, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    
                    HStack {
                        Text(progressText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(targetText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var progressValue: Double {
        switch goal.status {
        case .inProgress(let progress):
            return progress
        case .completed:
            return 1.0
        default:
            return 0.0
        }
    }
    
    private var progressColor: Color {
        if progressValue >= 0.75 {
            return .green
        } else if progressValue >= 0.5 {
            return .orange
        } else if progressValue >= 0.25 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private var progressText: String {
        switch goal.type {
        case .timeBased(let hours):
            let minutes = Int(goal.currentValue)
            return "\(minutes / 60)h \(minutes % 60)m"
        case .pointBased(let points):
            return "\(Int(goal.currentValue)) pts"
        case .appSpecific(_, let hours):
            let minutes = Int(goal.currentValue)
            return "\(minutes / 60)h \(minutes % 60)m"
        case .streak(let days):
            return "\(Int(goal.currentValue)) days"
        }
    }
    
    private var targetText: String {
        switch goal.type {
        case .timeBased(let hours):
            return "of \(hours)h"
        case .pointBased(let points):
            return "of \(points) pts"
        case .appSpecific(_, let hours):
            return "of \(hours)h"
        case .streak(let days):
            return "of \(days) days"
        }
    }
}

// MARK: - Preview

struct ActiveGoalsListView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveGoalsListView(
            goals: [
                EducationalGoal(
                    childProfileID: "child1",
                    title: "Reading Goal",
                    description: "Read for 5 hours this week",
                    type: .timeBased(hours: 5),
                    frequency: .weekly,
                    targetValue: 300,
                    currentValue: 150,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(7*24*60*60),
                    status: .inProgress(progress: 0.5),
                    isRecurring: true,
                    metadata: GoalMetadata(createdBy: "parent1", lastModifiedBy: "parent1")
                ),
                EducationalGoal(
                    childProfileID: "child1",
                    title: "Math Points",
                    description: "Earn 100 math points",
                    type: .pointBased(points: 100),
                    frequency: .weekly,
                    targetValue: 100,
                    currentValue: 75,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(7*24*60*60),
                    status: .inProgress(progress: 0.75),
                    isRecurring: false,
                    metadata: GoalMetadata(createdBy: "parent1", lastModifiedBy: "parent1")
                )
            ],
            hasActiveSubscription: false
        ) { _ in }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}