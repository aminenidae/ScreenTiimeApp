import Foundation
import UserNotifications
import SharedModels

// MARK: - Notification Service Protocol

public protocol NotificationServiceProtocol {
    func requestNotificationPermission() async throws -> Bool
    func scheduleGoalCompletionNotification(for goal: EducationalGoal) async throws
    func scheduleBadgeEarnedNotification(for badge: AchievementBadge) async throws
    func cancelNotification(withIdentifier identifier: String) async
    func cancelAllNotifications() async
}

// MARK: - Notification Service Implementation

public class NotificationService: NotificationServiceProtocol {
    
    // MARK: - Notification Permission
    
    public func requestNotificationPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await center.requestAuthorization(options: options)
    }
    
    // MARK: - Goal Completion Notifications
    
    public func scheduleGoalCompletionNotification(for goal: EducationalGoal) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Goal Completed!"
        content.body = "Congratulations! You've completed your goal: \(goal.title)"
        content.sound = .default
        content.badge = 1
        
        // Create a unique identifier for this notification
        let identifier = "goal-completion-\(goal.id.uuidString)"
        
        // Create a date component for the notification (immediate delivery)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        try await center.add(request)
    }
    
    // MARK: - Badge Earned Notifications
    
    public func scheduleBadgeEarnedNotification(for badge: AchievementBadge) async throws {
        let content = UNMutableNotificationContent()
        content.title = "New Badge Earned!"
        content.body = "Congratulations! You've earned the \(badge.title) badge."
        content.sound = .default
        content.badge = 1
        
        // Add badge-specific information if available
        if let points = badge.metadata.pointsAwarded {
            content.body += " You've earned \(points) bonus points!"
        }
        
        // Create a unique identifier for this notification
        let identifier = "badge-earned-\(badge.id.uuidString)"
        
        // Create a date component for the notification (immediate delivery)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        try await center.add(request)
    }
    
    // MARK: - Notification Cancellation
    
    public func cancelNotification(withIdentifier identifier: String) async {
        let center = UNUserNotificationCenter.current()
        await center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    public func cancelAllNotifications() async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Custom Notification Scheduling
    
    public func scheduleCustomNotification(
        title: String,
        body: String,
        identifier: String,
        timeInterval: TimeInterval
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        try await center.add(request)
    }
}