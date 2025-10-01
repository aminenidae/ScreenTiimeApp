import SwiftUI
import SharedModels

struct GoalHistoryView: View {
    let goals: [EducationalGoal]
    
    private var completedGoals: [EducationalGoal] {
        goals.filter { goal in
            if case .completed = goal.status {
                return true
            }
            return false
        }
    }
    
    private var failedGoals: [EducationalGoal] {
        goals.filter { goal in
            if case .failed = goal.status {
                return true
            }
            return false
        }
    }
    
    var body: some View {
        if !completedGoals.isEmpty || !failedGoals.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Goal History")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !completedGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completed")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(completedGoals) { goal in
                                GoalHistoryRow(goal: goal, isCompleted: true)
                            }
                        }
                    }
                }
                
                if !failedGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Failed")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(failedGoals) { goal in
                                GoalHistoryRow(goal: goal, isCompleted: false)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Goal History Row

struct GoalHistoryRow: View {
    let goal: EducationalGoal
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(completedDateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(goalTypeText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCompleted ? Color.green : Color.red, lineWidth: 1)
        )
    }
    
    private var completedDateText: String {
        if isCompleted, let completedAt = goal.metadata.completedAt {
            return formatDate(completedAt)
        } else if !isCompleted, let failedAt = goal.metadata.failedAt {
            return formatDate(failedAt)
        } else {
            return formatDate(goal.endDate)
        }
    }
    
    private var goalTypeText: String {
        switch goal.type {
        case .timeBased(let hours):
            return "\(hours)h goal"
        case .pointBased(let points):
            return "\(points) pts goal"
        case .appSpecific(let bundleID, let hours):
            return "\(hours)h \(bundleID)"
        case .streak(let days):
            return "\(days)d streak"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview

struct GoalHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        GoalHistoryView(
            goals: [
                EducationalGoal(
                    id: UUID(),
                    childProfileID: "child1",
                    title: "Reading Goal",
                    description: "Read for 5 hours this week",
                    type: .timeBased(hours: 5),
                    frequency: .weekly,
                    targetValue: 300,
                    currentValue: 300,
                    startDate: Date().addingTimeInterval(-7*24*60*60),
                    endDate: Date(),
                    status: .completed,
                    isRecurring: true,
                    metadata: GoalMetadata(
                        createdBy: "parent1",
                        lastModifiedAt: Date(),
                        lastModifiedBy: "parent1",
                        completedAt: Date()
                    )
                ),
                EducationalGoal(
                    id: UUID(),
                    childProfileID: "child1",
                    title: "Math Points",
                    description: "Earn 100 math points",
                    type: .pointBased(points: 100),
                    frequency: .weekly,
                    targetValue: 100,
                    currentValue: 75,
                    startDate: Date().addingTimeInterval(-7*24*60*60),
                    endDate: Date(),
                    status: .failed,
                    isRecurring: false,
                    metadata: GoalMetadata(
                        createdBy: "parent1",
                        lastModifiedAt: Date(),
                        lastModifiedBy: "parent1",
                        failedAt: Date()
                    )
                )
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}