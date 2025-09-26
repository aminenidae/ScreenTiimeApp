import Foundation
import SharedModels

public class RewardCalculator {

    public static let shared = RewardCalculator()
    private init() {}

    /// Calculate points for a single session
    public func calculatePoints(for session: ScreenTimeSession, category: AppCategory) -> Int {
        let basePoints: Int
        
        switch category {
        case .educational:
            basePoints = 10
        case .productivity:
            basePoints = 5
        case .entertainment, .social, .gaming:
            basePoints = 2
        case .other:
            basePoints = 1
        }
        
        // Calculate duration in minutes
        let durationMinutes = Int(session.duration / 60)
        
        // Cap at 60 minutes per session
        let cappedMinutes = min(durationMinutes, 60)
        
        return basePoints * cappedMinutes
    }
    
    /// Calculate daily points from multiple sessions
    public func calculateDailyPoints(for sessions: [ScreenTimeSession]) -> Int {
        return sessions.reduce(0) { total, session in
            let points = calculatePoints(for: session, category: session.category)
            return total + points
        }
    }
    
    /// Check for achievements based on sessions
    public func checkAchievements(for childProfile: ChildProfile, sessions: [ScreenTimeSession]) -> [Achievement] {
        var achievements: [Achievement] = []
        
        // Check for "First Session" achievement
        if sessions.count >= 1 {
            let firstSessionAchievement = Achievement(
                id: "first_session_\(childProfile.id)",
                name: "First Session",
                description: "Complete your first screen time session",
                criteria: "Complete 1 session",
                pointReward: 10,
                imageURL: nil,
                isUnlocked: true,
                unlockedAt: Date()
            )
            achievements.append(firstSessionAchievement)
        }
        
        // Check for "Daily Goal" achievement
        let dailyPoints = calculateDailyPoints(for: sessions)
        if dailyPoints >= 100 {
            let dailyGoalAchievement = Achievement(
                id: "daily_goal_\(childProfile.id)",
                name: "Daily Goal",
                description: "Earn 100 points in a day",
                criteria: "Earn 100 points",
                pointReward: 25,
                imageURL: nil,
                isUnlocked: true,
                unlockedAt: Date()
            )
            achievements.append(dailyGoalAchievement)
        }
        
        return achievements
    }
    
    /// Check if a reward can be redeemed
    public func canRedeem(reward: Reward, for childProfile: ChildProfile) -> RedemptionValidationResult {
        if !reward.isActive {
            return .rewardInactive
        }
        
        if childProfile.pointBalance < reward.pointCost {
            return .insufficientPoints(required: reward.pointCost, available: childProfile.pointBalance)
        }
        
        return .valid
    }
    
    /// Redeem a reward
    public func redeemReward(_ reward: Reward, for childProfile: ChildProfile) -> RedemptionResult {
        let validation = canRedeem(reward: reward, for: childProfile)
        
        switch validation {
        case .valid:
            // In a real implementation, this would update the child's point balance
            // and create a transaction record
            return .success(transactionID: UUID().uuidString)
        case .insufficientPoints:
            return .failure(reason: "Insufficient points")
        case .rewardInactive:
            return .failure(reason: "Reward is not active")
        case .otherError(let reason):
            return .failure(reason: reason)
        }
    }
    
    /// Calculate current streak
    public func calculateCurrentStreak(for childProfile: ChildProfile, sessions: [ScreenTimeSession]) -> Int {
        // Simple implementation - count consecutive days with sessions
        // In a real implementation, this would be more sophisticated
        return min(sessions.count, 7) // Cap at 7 days for demo
    }
}

public struct Achievement {
    public let id: String
    public let name: String
    public let description: String
    public let criteria: String
    public let pointReward: Int
    public let imageURL: URL?
    public let isUnlocked: Bool
    public let unlockedAt: Date?

    public init(id: String, name: String, description: String, criteria: String, pointReward: Int, imageURL: URL?, isUnlocked: Bool, unlockedAt: Date?) {
        self.id = id
        self.name = name
        self.description = description
        self.criteria = criteria
        self.pointReward = pointReward
        self.imageURL = imageURL
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}

public struct Goal {
    public let id: String
    public let childID: String
    public let title: String
    public let targetValue: Int
    public let currentValue: Int
    public let deadline: Date?

    public init(id: String, childID: String, title: String, targetValue: Int, currentValue: Int, deadline: Date? = nil) {
        self.id = id
        self.childID = childID
        self.title = title
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.deadline = deadline
    }
}

public struct GoalProgress {
    public let goalID: String
    public let currentValue: Int
    public let targetValue: Int
    public let progress: Double
    public let isCompleted: Bool

    public init(goalID: String, currentValue: Int, targetValue: Int, progress: Double, isCompleted: Bool) {
        self.goalID = goalID
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.progress = progress
        self.isCompleted = isCompleted
    }
}

public enum RedemptionValidationResult {
    case valid
    case insufficientPoints(required: Int, available: Int)
    case rewardInactive
    case otherError(String)
}

public enum RedemptionResult {
    case success(transactionID: String)
    case failure(reason: String)
}

public struct ChildProfile {
    public let id: String
    public var pointBalance: Int
    public var achievements: [Achievement]
    public var streak: Int

    public init(id: String, pointBalance: Int, achievements: [Achievement], streak: Int) {
        self.id = id
        self.pointBalance = pointBalance
        self.achievements = achievements
        self.streak = streak
    }
}

public struct Reward {
    public let id: String
    public let name: String
    public let pointCost: Int
    public let isActive: Bool

    public init(id: String, name: String, pointCost: Int, isActive: Bool) {
        self.id = id
        self.name = name
        self.pointCost = pointCost
        self.isActive = isActive
    }
}

public struct ScreenTimeSession {
    public let id: String
    public let childID: String
    public let category: AppCategory
    public let duration: TimeInterval
    public let date: Date

    public init(id: String, childID: String, category: AppCategory, duration: TimeInterval, date: Date) {
        self.id = id
        self.childID = childID
        self.category = category
        self.duration = duration
        self.date = date
    }
}

public enum AppCategory: String {
    case educational
    case productivity
    case entertainment
    case social
    case gaming
    case other
}
