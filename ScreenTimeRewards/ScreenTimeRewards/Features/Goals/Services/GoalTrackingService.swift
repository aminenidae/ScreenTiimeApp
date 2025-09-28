import Foundation
import SharedModels
import Combine

// MARK: - Goal Tracking Service Protocol

public protocol GoalTrackingServiceProtocol {
    func calculateGoalProgress(goal: EducationalGoal, sessions: [UsageSession], transactions: [PointTransaction]) -> Double
    func updateGoalStatus(goal: EducationalGoal, progress: Double) -> GoalStatus
    func checkBadgeCriteria(badge: BadgeType, childID: String, sessions: [UsageSession], transactions: [PointTransaction]) -> Bool
    func calculateStreakData(childID: String, sessions: [UsageSession]) -> (currentStreak: Int, longestStreak: Int)
}

// MARK: - Goal Tracking Service Implementation

public class GoalTrackingService: GoalTrackingServiceProtocol {
    
    // MARK: - Progress Calculation
    
    public func calculateGoalProgress(goal: EducationalGoal, sessions: [UsageSession], transactions: [PointTransaction]) -> Double {
        switch goal.type {
        case .timeBased(let hours):
            let learningSessions = filterLearningSessions(sessions)
            let totalMinutes = learningSessions.reduce(0) { $0 + Int($1.durationSeconds / 60) }
            let targetMinutes = hours * 60
            return min(Double(totalMinutes) / Double(targetMinutes), 1.0)
            
        case .pointBased(let points):
            let learningTransactions = filterLearningTransactions(transactions)
            let totalPoints = learningTransactions.reduce(0) { $0 + $1.amount }
            return min(Double(totalPoints) / Double(points), 1.0)
            
        case .appSpecific(let bundleID, let hours):
            let appSessions = sessions.filter { $0.appCategorizationID == bundleID }
            let totalMinutes = appSessions.reduce(0) { $0 + Int($1.durationSeconds / 60) }
            let targetMinutes = hours * 60
            return min(Double(totalMinutes) / Double(targetMinutes), 1.0)
            
        case .streak(let days):
            // For streak goals, we check if the current streak meets the required days
            let streakData = calculateStreakData(childID: goal.childProfileID, sessions: sessions)
            return min(Double(streakData.currentStreak) / Double(days), 1.0)
        }
    }
    
    // MARK: - Goal Status Updates
    
    public func updateGoalStatus(goal: EducationalGoal, progress: Double) -> GoalStatus {
        // Check if goal is already completed or failed
        if case .completed = goal.status {
            return goal.status
        }
        
        if case .failed = goal.status {
            return goal.status
        }
        
        // Check if goal is completed
        if progress >= 1.0 {
            return .completed
        }
        
        // Check if goal has expired
        if Date() > goal.endDate {
            return .failed
        }
        
        // Check if goal is in progress
        if progress > 0.0 {
            return .inProgress(progress: progress)
        }
        
        // Default to not started
        return .notStarted
    }
    
    // MARK: - Badge Criteria Checking
    
    public func checkBadgeCriteria(badge: BadgeType, childID: String, sessions: [UsageSession], transactions: [PointTransaction]) -> Bool {
        switch badge {
        case .streak(let days):
            let streakData = calculateStreakData(childID: childID, sessions: sessions)
            return streakData.currentStreak >= days
            
        case .points(let points):
            let totalPoints = transactions.reduce(0) { $0 + $1.amount }
            return totalPoints >= points
            
        case .time(let hours):
            let learningSessions = filterLearningSessions(sessions)
            let totalMinutes = learningSessions.reduce(0) { $0 + Int($1.durationSeconds / 60) }
            return totalMinutes >= (hours * 60)
            
        case .appSpecific(let bundleID, let hours):
            let appSessions = sessions.filter { $0.appCategorizationID == bundleID }
            let totalMinutes = appSessions.reduce(0) { $0 + Int($1.durationSeconds / 60) }
            return totalMinutes >= (hours * 60)
            
        case .milestone(let milestoneType):
            return checkMilestoneCriteria(milestoneType: milestoneType, childID: childID, sessions: sessions, transactions: transactions)
        }
    }
    
    // MARK: - Streak Calculation
    
    public func calculateStreakData(childID: String, sessions: [UsageSession]) -> (currentStreak: Int, longestStreak: Int) {
        let learningSessions = filterLearningSessions(sessions)
        
        // Group sessions by date
        let sessionsByDate = Dictionary(grouping: learningSessions) { session in
            Calendar.current.startOfDay(for: session.startTime)
        }
        
        // Get all dates with learning activity
        let activeDates = sessionsByDate.keys.sorted()
        
        guard !activeDates.isEmpty else {
            return (currentStreak: 0, longestStreak: 0)
        }
        
        // Calculate current streak
        var currentDate = Calendar.current.startOfDay(for: Date())
        var currentStreak = 0
        
        while activeDates.contains(currentDate) || activeDates.contains(Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!) {
            if activeDates.contains(currentDate) {
                currentStreak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        // Calculate longest streak
        var longestStreak = 0
        var tempStreak = 0
        var previousDate: Date?
        
        for date in activeDates {
            if let prev = previousDate,
               Calendar.current.date(byAdding: .day, value: 1, to: prev) == date {
                tempStreak += 1
            } else {
                longestStreak = max(longestStreak, tempStreak)
                tempStreak = 1
            }
            previousDate = date
        }
        
        longestStreak = max(longestStreak, tempStreak)
        
        return (currentStreak: currentStreak, longestStreak: longestStreak)
    }
    
    // MARK: - Private Helper Methods
    
    private func filterLearningSessions(_ sessions: [UsageSession]) -> [UsageSession] {
        // In a real implementation, this would filter sessions based on app categorization
        // For now, we'll return all sessions as a placeholder
        return sessions
    }
    
    private func filterLearningTransactions(_ transactions: [PointTransaction]) -> [PointTransaction] {
        // In a real implementation, this would filter transactions based on source
        // For now, we'll return all transactions as a placeholder
        return transactions
    }
    
    private func checkMilestoneCriteria(milestoneType: MilestoneType, childID: String, sessions: [UsageSession], transactions: [PointTransaction]) -> Bool {
        switch milestoneType {
        case .firstGoalCompleted:
            // This would require tracking completed goals
            return false // Placeholder implementation
            
        case .hundredPoints:
            let totalPoints = transactions.reduce(0) { $0 + $1.amount }
            return totalPoints >= 100
            
        case .tenHoursLearning:
            let learningSessions = filterLearningSessions(sessions)
            let totalMinutes = learningSessions.reduce(0) { $0 + Int($1.durationSeconds / 60) }
            return totalMinutes >= 600 // 10 hours
            
        case .oneWeekStreak:
            let streakData = calculateStreakData(childID: childID, sessions: sessions)
            return streakData.currentStreak >= 7
            
        case .fiveGoalsCompleted:
            // This would require tracking completed goals
            return false // Placeholder implementation
            
        case .custom:
            return false // Custom milestones would need specific logic
        }
    }
}