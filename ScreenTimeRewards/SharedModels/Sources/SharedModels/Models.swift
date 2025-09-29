import Foundation

// MARK: - Core Data Models

public struct Family: Codable, Identifiable {
    public let id: String
    public var name: String
    public let createdAt: Date
    public let ownerUserID: String
    public var sharedWithUserIDs: [String]
    public var childProfileIDs: [String]
    // COPPA compliance properties
    public var parentalConsentGiven: Bool
    public var parentalConsentDate: Date?
    public var parentalConsentMethod: String?
    // Trial and subscription metadata
    public var subscriptionMetadata: SubscriptionMetadata?

    public init(id: String, name: String, createdAt: Date, ownerUserID: String, sharedWithUserIDs: [String], childProfileIDs: [String], parentalConsentGiven: Bool = false, parentalConsentDate: Date? = nil, parentalConsentMethod: String? = nil, subscriptionMetadata: SubscriptionMetadata? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.ownerUserID = ownerUserID
        self.sharedWithUserIDs = sharedWithUserIDs
        self.childProfileIDs = childProfileIDs
        self.parentalConsentGiven = parentalConsentGiven
        self.parentalConsentDate = parentalConsentDate
        self.parentalConsentMethod = parentalConsentMethod
        self.subscriptionMetadata = subscriptionMetadata
    }
}

public struct ChildProfile: Codable, Identifiable {
    public let id: String
    public let familyID: String
    public var name: String
    public var avatarAssetURL: String?
    public let birthDate: Date
    public var pointBalance: Int
    // Additional properties for COPPA compliance and data management
    public var totalPointsEarned: Int
    public var deviceID: String?
    public var cloudKitZoneID: String?
    public var createdAt: Date
    public var ageVerified: Bool
    public var verificationMethod: String?
    public var dataRetentionPeriod: Int? // In days
    // Notification preferences
    public var notificationPreferences: NotificationPreferences?
    
    public init(id: String, familyID: String, name: String, avatarAssetURL: String?, birthDate: Date, pointBalance: Int, totalPointsEarned: Int = 0, deviceID: String? = nil, cloudKitZoneID: String? = nil, createdAt: Date = Date(), ageVerified: Bool = false, verificationMethod: String? = nil, dataRetentionPeriod: Int? = nil, notificationPreferences: NotificationPreferences? = nil) {
        self.id = id
        self.familyID = familyID
        self.name = name
        self.avatarAssetURL = avatarAssetURL
        self.birthDate = birthDate
        self.pointBalance = pointBalance
        self.totalPointsEarned = totalPointsEarned
        self.deviceID = deviceID
        self.cloudKitZoneID = cloudKitZoneID
        self.createdAt = createdAt
        self.ageVerified = ageVerified
        self.verificationMethod = verificationMethod
        self.dataRetentionPeriod = dataRetentionPeriod
        self.notificationPreferences = notificationPreferences
    }
}

// MARK: - Authentication Models

public enum AccountStatus: String, Codable {
    case available = "available"
    case restricted = "restricted"
    case noAccount = "noAccount"
    case couldNotDetermine = "couldNotDetermine"
}

public struct AuthState: Codable {
    public let isAuthenticated: Bool
    public let accountStatus: AccountStatus
    public let userID: String?
    public let familyID: String?
    
    public init(isAuthenticated: Bool, accountStatus: AccountStatus, userID: String?, familyID: String?) {
        self.isAuthenticated = isAuthenticated
        self.accountStatus = accountStatus
        self.userID = userID
        self.familyID = familyID
    }
}

// MARK: - App Category
public enum AppCategory: String, CaseIterable, Codable {
    case learning = "Learning"
    case reward = "Reward"
}

// MARK: - App Filter for UI
public enum AppFilter: CaseIterable {
    case all
    case learning
    case reward

    public var title: String {
        switch self {
        case .all:
            return "All"
        case .learning:
            return "Learning"
        case .reward:
            return "Reward"
        }
    }
}

// MARK: - App Metadata
public struct AppMetadata: Identifiable, Codable, Equatable {
    public let id: String
    public let bundleID: String
    public let displayName: String
    public let isSystemApp: Bool
    public let iconData: Data?
    
    public init(id: String, bundleID: String, displayName: String, isSystemApp: Bool, iconData: Data?) {
        self.id = id
        self.bundleID = bundleID
        self.displayName = displayName
        self.isSystemApp = isSystemApp
        self.iconData = iconData
    }
}

// MARK: - App Categorization
public struct AppCategorization: Identifiable, Codable, Equatable {
    public let id: String
    public let appBundleID: String
    public let category: AppCategory
    public let childProfileID: String
    public let pointsPerHour: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String,
        appBundleID: String,
        category: AppCategory,
        childProfileID: String,
        pointsPerHour: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.appBundleID = appBundleID
        self.category = category
        self.childProfileID = childProfileID
        self.pointsPerHour = pointsPerHour
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - UsageSession Model
public struct UsageSession: Codable, Identifiable {
    public let id: String
    public let childProfileID: String
    public let appBundleID: String
    public let category: AppCategory
    public let startTime: Date
    public let endTime: Date
    public let duration: TimeInterval
    // Validation fields (removed to avoid circular dependency)
    public let isValidated: Bool
    
    public init(id: String, childProfileID: String, appBundleID: String, category: AppCategory, startTime: Date, endTime: Date, duration: TimeInterval, isValidated: Bool = false) {
        self.id = id
        self.childProfileID = childProfileID
        self.appBundleID = appBundleID
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.isValidated = isValidated
    }
}

// Add ScreenTimeSession model
public struct ScreenTimeSession: Codable, Identifiable {
    public let id: String
    public let childProfileID: String
    public let appBundleID: String
    public let category: AppCategory
    public let startTime: Date
    public let endTime: Date
    public let duration: TimeInterval
    public var pointsEarned: Int
    
    public init(id: String, childProfileID: String, appBundleID: String, category: AppCategory, startTime: Date, endTime: Date, duration: TimeInterval, pointsEarned: Int = 0) {
        self.id = id
        self.childProfileID = childProfileID
        self.appBundleID = appBundleID
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.pointsEarned = pointsEarned
    }
}

// MARK: - Reward Models

public struct Reward: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let pointCost: Int
    public let imageURL: String?
    public let isActive: Bool
    public let createdAt: Date
    
    public init(id: String, name: String, description: String, pointCost: Int, imageURL: String?, isActive: Bool, createdAt: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.pointCost = pointCost
        self.imageURL = imageURL
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

public enum RedemptionValidationResult: Codable {
    case valid
    case insufficientPoints(required: Int, available: Int)
    case rewardInactive
    case otherError(String)
}

public enum RedemptionResult: Codable {
    case success(transactionID: String)
    case failure(reason: String)
}

// MARK: - Achievement Models

public struct Achievement: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let criteria: String
    public let pointReward: Int
    public let imageURL: String?
    public let isUnlocked: Bool
    public let unlockedAt: Date?
    
    public init(id: String, name: String, description: String, criteria: String, pointReward: Int, imageURL: String?, isUnlocked: Bool, unlockedAt: Date?) {
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

// MARK: - Additional Models for CloudKitService

public struct PointTransaction: Codable, Identifiable {
    public let id: String
    public let childProfileID: String
    public let points: Int
    public let reason: String
    public let timestamp: Date
    
    public init(id: String, childProfileID: String, points: Int, reason: String, timestamp: Date) {
        self.id = id
        self.childProfileID = childProfileID
        self.points = points
        self.reason = reason
        self.timestamp = timestamp
    }
}

// MARK: - Point-to-Time Redemption Model (for app screen time rewards)
public struct PointToTimeRedemption: Codable, Identifiable {
    public let id: String
    public let childProfileID: String
    public let appCategorizationID: String
    public let pointsSpent: Int
    public let timeGrantedMinutes: Int
    public let conversionRate: Double // points per minute
    public let redeemedAt: Date
    public let expiresAt: Date
    public var timeUsedMinutes: Int
    public let status: RedemptionStatus

    public init(id: String, childProfileID: String, appCategorizationID: String, pointsSpent: Int, timeGrantedMinutes: Int, conversionRate: Double, redeemedAt: Date, expiresAt: Date, timeUsedMinutes: Int = 0, status: RedemptionStatus = .active) {
        self.id = id
        self.childProfileID = childProfileID
        self.appCategorizationID = appCategorizationID
        self.pointsSpent = pointsSpent
        self.timeGrantedMinutes = timeGrantedMinutes
        self.conversionRate = conversionRate
        self.redeemedAt = redeemedAt
        self.expiresAt = expiresAt
        self.timeUsedMinutes = timeUsedMinutes
        self.status = status
    }
}

public enum RedemptionStatus: String, Codable, CaseIterable {
    case active = "active"
    case expired = "expired"
    case used = "used"
}

public struct RewardRedemption: Codable, Identifiable {
    public let id: String
    public let childProfileID: String
    public let rewardID: String
    public let pointsSpent: Int
    public let timestamp: Date
    public let transactionID: String

    public init(id: String, childProfileID: String, rewardID: String, pointsSpent: Int, timestamp: Date, transactionID: String) {
        self.id = id
        self.childProfileID = childProfileID
        self.rewardID = rewardID
        self.pointsSpent = pointsSpent
        self.timestamp = timestamp
        self.transactionID = transactionID
    }
}

public struct FamilySettings: Codable, Identifiable {
    public let id: String
    public let familyID: String
    public var dailyTimeLimit: Int? // In minutes
    public var bedtimeStart: Date?
    public var bedtimeEnd: Date?
    public var contentRestrictions: [String: Bool] // App bundle ID to restriction status
    
    public init(id: String, familyID: String, dailyTimeLimit: Int? = nil, bedtimeStart: Date? = nil, bedtimeEnd: Date? = nil, contentRestrictions: [String: Bool] = [:]) {
        self.id = id
        self.familyID = familyID
        self.dailyTimeLimit = dailyTimeLimit
        self.bedtimeStart = bedtimeStart
        self.bedtimeEnd = bedtimeEnd
        self.contentRestrictions = contentRestrictions
    }
}

public struct SubscriptionMetadata: Codable {
    public var trialStartDate: Date?
    public var trialEndDate: Date?
    public var hasUsedTrial: Bool
    public var subscriptionStartDate: Date?
    public var subscriptionEndDate: Date?
    public var isActive: Bool

    public init(
        trialStartDate: Date? = nil,
        trialEndDate: Date? = nil,
        hasUsedTrial: Bool = false,
        subscriptionStartDate: Date? = nil,
        subscriptionEndDate: Date? = nil,
        isActive: Bool = false
    ) {
        self.trialStartDate = trialStartDate
        self.trialEndDate = trialEndDate
        self.hasUsedTrial = hasUsedTrial
        self.subscriptionStartDate = subscriptionStartDate
        self.subscriptionEndDate = subscriptionEndDate
        self.isActive = isActive
    }
}

public struct SubscriptionEntitlement: Codable, Identifiable {
    public let id: String
    public let familyID: String
    public let subscriptionType: String
    public let startDate: Date
    public let endDate: Date
    public let isActive: Bool

    public init(id: String, familyID: String, subscriptionType: String, startDate: Date, endDate: Date, isActive: Bool) {
        self.id = id
        self.familyID = familyID
        self.subscriptionType = subscriptionType
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
    }
}

// MARK: - Educational Goals Models

public enum GoalType: Codable, Equatable {
    case timeBased(hours: Int)
    case pointBased(points: Int)
    case appSpecific(bundleID: String, hours: Int)
    case streak(days: Int)
}

public enum GoalFrequency: String, Codable, Equatable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"
}

public enum GoalStatus: String, Codable, Equatable {
    case notStarted = "notStarted"
    case inProgress = "inProgress"
    case completed = "completed"
    case failed = "failed"
}

public struct GoalMetadata: Codable, Equatable {
    public var createdBy: String  // Parent user ID
    public var lastModifiedAt: Date
    public var lastModifiedBy: String
    public var completedAt: Date?
    public var failedAt: Date?

    public init(
        createdBy: String,
        lastModifiedAt: Date = Date(),
        lastModifiedBy: String,
        completedAt: Date? = nil,
        failedAt: Date? = nil
    ) {
        self.createdBy = createdBy
        self.lastModifiedAt = lastModifiedAt
        self.lastModifiedBy = lastModifiedBy
        self.completedAt = completedAt
        self.failedAt = failedAt
    }
}

public struct EducationalGoal: Codable, Equatable, Identifiable {
    public let id: UUID
    public let childProfileID: String
    public var title: String
    public var description: String
    public var type: GoalType
    public var frequency: GoalFrequency
    public var targetValue: Double
    public var currentValue: Double
    public var startDate: Date
    public var endDate: Date
    public var createdAt: Date
    public var status: GoalStatus
    public var isRecurring: Bool
    public var metadata: GoalMetadata

    public init(
        id: UUID = UUID(),
        childProfileID: String,
        title: String,
        description: String,
        type: GoalType,
        frequency: GoalFrequency,
        targetValue: Double,
        currentValue: Double,
        startDate: Date,
        endDate: Date,
        createdAt: Date = Date(),
        status: GoalStatus,
        isRecurring: Bool,
        metadata: GoalMetadata
    ) {
        self.id = id
        self.childProfileID = childProfileID
        self.title = title
        self.description = description
        self.type = type
        self.frequency = frequency
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.status = status
        self.isRecurring = isRecurring
        self.metadata = metadata
    }
}

// MARK: - Achievement Badge Models

public enum BadgeType: String, Codable, Equatable {
    case streak = "streak"
    case points = "points"
    case time = "time"
    case appSpecific = "appSpecific"
    case milestone = "milestone"
    case custom = "custom"
}

public enum MilestoneType: String, Codable, Equatable {
    case firstGoalCompleted = "firstGoalCompleted"
    case hundredPoints = "hundredPoints"
    case tenHoursLearning = "tenHoursLearning"
    case oneWeekStreak = "oneWeekStreak"
    case fiveGoalsCompleted = "fiveGoalsCompleted"
    case custom = "custom"
}

public struct BadgeMetadata: Codable, Equatable {
    public var relatedGoalID: UUID?
    public var relatedSessionIDs: [UUID]?
    public var pointsAwarded: Int?  // Optional bonus points for earning badge

    public init(
        relatedGoalID: UUID? = nil,
        relatedSessionIDs: [UUID]? = nil,
        pointsAwarded: Int? = nil
    ) {
        self.relatedGoalID = relatedGoalID
        self.relatedSessionIDs = relatedSessionIDs
        self.pointsAwarded = pointsAwarded
    }
}

public struct AchievementBadge: Codable, Equatable, Identifiable {
    public let id: UUID
    public let childProfileID: String
    public var type: BadgeType
    public var title: String
    public var description: String
    public var earnedAt: Date
    public var icon: String  // SF Symbol name or asset name
    public var isRare: Bool
    public var metadata: BadgeMetadata

    public init(
        id: UUID = UUID(),
        childProfileID: String,
        type: BadgeType,
        title: String,
        description: String,
        earnedAt: Date,
        icon: String,
        isRare: Bool,
        metadata: BadgeMetadata
    ) {
        self.id = id
        self.childProfileID = childProfileID
        self.type = type
        self.title = title
        self.description = description
        self.earnedAt = earnedAt
        self.icon = icon
        self.isRare = isRare
        self.metadata = metadata
    }
}

// MARK: - Repository Protocols

@available(iOS 15.0, macOS 10.15, *)
public protocol ChildProfileRepository {
    func createChild(_ child: ChildProfile) async throws -> ChildProfile
    func fetchChild(id: String) async throws -> ChildProfile?
    func fetchChildren(for familyID: String) async throws -> [ChildProfile]
    func updateChild(_ child: ChildProfile) async throws -> ChildProfile
    func deleteChild(id: String) async throws
}

@available(iOS 15.0, macOS 10.15, *)
public protocol AppCategorizationRepository {
    func createAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization
    func fetchAppCategorization(id: String) async throws -> AppCategorization?
    func fetchAppCategorizations(for childID: String) async throws -> [AppCategorization]
    func updateAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization
    func deleteAppCategorization(id: String) async throws
}

@available(iOS 15.0, macOS 10.15, *)
public protocol UsageSessionRepository {
    func createSession(_ session: UsageSession) async throws -> UsageSession
    func fetchSession(id: String) async throws -> UsageSession?
    func fetchSessions(for childID: String, dateRange: DateRange?) async throws -> [UsageSession]
    func updateSession(_ session: UsageSession) async throws -> UsageSession
    func deleteSession(id: String) async throws
}

@available(iOS 15.0, macOS 10.15, *)
public protocol PointTransactionRepository {
    func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction
    func fetchTransaction(id: String) async throws -> PointTransaction?
    func fetchTransactions(for childID: String, limit: Int?) async throws -> [PointTransaction]
    func fetchTransactions(for childID: String, dateRange: DateRange?) async throws -> [PointTransaction]
    func deleteTransaction(id: String) async throws
}

@available(iOS 15.0, macOS 10.15, *)
public protocol PointToTimeRedemptionRepository {
    func createPointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption
    func fetchPointToTimeRedemption(id: String) async throws -> PointToTimeRedemption?
    func fetchPointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption]
    func fetchActivePointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption]
    func updatePointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption
    func deletePointToTimeRedemption(id: String) async throws
}

@available(iOS 15.0, macOS 10.15, *)
public protocol FamilyRepository {
    func createFamily(_ family: Family) async throws -> Family
    func fetchFamily(id: String) async throws -> Family?
    func fetchFamilies(for userID: String) async throws -> [Family]
    func updateFamily(_ family: Family) async throws -> Family
    func deleteFamily(id: String) async throws
}

@available(iOS 15.0, macOS 10.15, *)
public protocol FamilySettingsRepository {
    func createSettings(_ settings: FamilySettings) async throws -> FamilySettings
    func fetchSettings(for familyID: String) async throws -> FamilySettings?
    func updateSettings(_ settings: FamilySettings) async throws -> FamilySettings
    func deleteSettings(id: String) async throws
}

@available(iOS 15.0, macOS 10.15, *)
public protocol SubscriptionEntitlementRepository {
    func createEntitlement(_ entitlement: SubscriptionEntitlement) async throws -> SubscriptionEntitlement
    func fetchEntitlement(id: String) async throws -> SubscriptionEntitlement?
    func fetchEntitlements(for familyID: String) async throws -> [SubscriptionEntitlement]
    func updateEntitlement(_ entitlement: SubscriptionEntitlement) async throws -> SubscriptionEntitlement
    func deleteEntitlement(id: String) async throws
}

// MARK: - Helper Types

public struct DateRange: Codable {
    public let start: Date
    public let end: Date
    
    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

public struct NotificationPreferences: Codable {
    public var enabledNotifications: Set<NotificationEvent>
    public var quietHoursStart: Date?
    public var quietHoursEnd: Date?
    public var digestMode: Bool
    public var lastNotificationSent: Date?
    public var notificationsEnabled: Bool
    
    public init(
        enabledNotifications: Set<NotificationEvent> = Set(NotificationEvent.allCases),
        quietHoursStart: Date? = nil,
        quietHoursEnd: Date? = nil,
        digestMode: Bool = false,
        lastNotificationSent: Date? = nil,
        notificationsEnabled: Bool = true
    ) {
        self.enabledNotifications = enabledNotifications
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        self.digestMode = digestMode
        self.lastNotificationSent = lastNotificationSent
        self.notificationsEnabled = notificationsEnabled
    }
}

public enum NotificationEvent: String, CaseIterable, Codable {
    case pointsEarned = "points_earned"
    case goalAchieved = "goal_achieved"
    case weeklyMilestone = "weekly_milestone"
    case streakAchieved = "streak_achieved"
}

// MARK: - Application Usage Models

public enum ApplicationCategory: String, Codable, Equatable {
    case educational = "educational"
    case entertainment = "entertainment"
    case social = "social"
    case productivity = "productivity"
    case game = "game"
    case other = "other"
}

public struct ApplicationUsage: Codable, Equatable {
    public let token: String
    public let displayName: String
    public let category: ApplicationCategory
    public let timeSpent: TimeInterval
    public let pointsEarned: Int

    public init(
        token: String,
        displayName: String,
        category: ApplicationCategory,
        timeSpent: TimeInterval,
        pointsEarned: Int
    ) {
        self.token = token
        self.displayName = displayName
        self.category = category
        self.timeSpent = timeSpent
        self.pointsEarned = pointsEarned
    }
}

public struct UsageReport: Codable, Equatable {
    public let childID: String
    public let date: Date
    public let applications: [ApplicationUsage]
    public let totalScreenTime: TimeInterval

    public init(
        childID: String,
        date: Date,
        applications: [ApplicationUsage],
        totalScreenTime: TimeInterval
    ) {
        self.childID = childID
        self.date = date
        self.applications = applications
        self.totalScreenTime = totalScreenTime
    }
}

// MARK: - Device Activity Schedule

public struct DeviceActivitySchedule: Codable, Equatable {
    public let intervalStart: DateComponents
    public let intervalEnd: DateComponents
    public let repeats: Bool

    public init(
        intervalStart: DateComponents,
        intervalEnd: DateComponents,
        repeats: Bool = true
    ) {
        self.intervalStart = intervalStart
        self.intervalEnd = intervalEnd
        self.repeats = repeats
    }

    public static func dailySchedule(from startTime: DateComponents, to endTime: DateComponents) -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: startTime,
            intervalEnd: endTime,
            repeats: true
        )
    }

    public static func allDay() -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
    }
}

// MARK: - Notification Models
// NotificationEvent enum has been moved to RewardCore module to avoid circular dependency

// MARK: - Validation Models (Moved from RewardCore to avoid circular dependency)

// MARK: - Validation Models (Removed from here to avoid circular dependency)
// These models have been moved back to RewardCore module

// MARK: - Validation Models (Removed from here to avoid circular dependency)
// These models have been moved back to RewardCore module
