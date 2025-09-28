import SwiftUI
import SharedModels

struct GoalSummaryHeaderView: View {
    let goals: [EducationalGoal]
    
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
    
    private var completedGoals: [EducationalGoal] {
        goals.filter { goal in
            if case .completed = goal.status {
                return true
            }
            return false
        }
    }
    
    private var overallProgress: Double {
        guard !activeGoals.isEmpty else { return 0.0 }
        
        let totalProgress = activeGoals.reduce(0.0) { sum, goal in
            switch goal.status {
            case .inProgress(let progress):
                return sum + progress
            case .completed:
                return sum + 1.0
            default:
                return sum
            }
        }
        
        return totalProgress / Double(activeGoals.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(activeGoals.count) active goals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !activeGoals.isEmpty {
                    ProgressRingView(
                        progress: overallProgress,
                        size: 44,
                        lineWidth: 4
                    )
                    .frame(width: 44, height: 44)
                }
            }
            
            if !activeGoals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overall Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ProgressView(value: overallProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    HStack {
                        Text("\(Int(overallProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(completedGoals.count) completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Progress Ring View

struct ProgressRingView: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color(.systemGray5),
                    lineWidth: lineWidth
                )
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .animation(.easeInOut, value: progress)
        }
    }
    
    private var progressColor: Color {
        if progress >= 0.75 {
            return .green
        } else if progress >= 0.5 {
            return .orange
        } else if progress >= 0.25 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Preview

struct GoalSummaryHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        GoalSummaryHeaderView(
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
                ),
                EducationalGoal(
                    childProfileID: "child1",
                    title: "Duolingo Streak",
                    description: "Use Duolingo for 7 days",
                    type: .streak(days: 7),
                    frequency: .weekly,
                    targetValue: 7,
                    currentValue: 5,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(7*24*60*60),
                    status: .inProgress(progress: 0.71),
                    isRecurring: true,
                    metadata: GoalMetadata(createdBy: "parent1", lastModifiedBy: "parent1")
                )
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}