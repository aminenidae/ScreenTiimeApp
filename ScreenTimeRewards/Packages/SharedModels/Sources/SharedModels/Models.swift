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
    
    public init(id: String, name: String, createdAt: Date, ownerUserID: String, sharedWithUserIDs: [String], childProfileIDs: [String], parentalConsentGiven: Bool = false, parentalConsentDate: Date? = nil, parentalConsentMethod: String? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.ownerUserID = ownerUserID
        self.sharedWithUserIDs = sharedWithUserIDs
        self.childProfileIDs = childProfileIDs
        self.parentalConsentGiven = parentalConsentGiven
        self.parentalConsentDate = parentalConsentDate
        self.parentalConsentMethod = parentalConsentMethod
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
    
    public init(id: String, familyID: String, name: String, avatarAssetURL: String?, birthDate: Date, pointBalance: Int, totalPointsEarned: Int = 0, deviceID: String? = nil, cloudKitZoneID: String? = nil, createdAt: Date = Date(), ageVerified: Bool = false, verificationMethod: String? = nil, dataRetentionPeriod: Int? = nil) {
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

// MARK: - App Category and Session Models

public enum AppCategory: String, Codable, CaseIterable {
    case educational = "educational"
    case entertainment = "entertainment"
    case social = "social"
    case gaming = "gaming"
    case productivity = "productivity"
    case other = "other"
}

public struct AppCategorization: Codable, Identifiable {
    public let id: String
    public let appBundleID: String
    public let category: AppCategory
    public let childProfileID: String
    public let createdAt: Date
    
    public init(id: String, appBundleID: String, category: AppCategory, childProfileID: String, createdAt: Date) {
        self.id = id
        self.appBundleID = appBundleID
        self.category = category
        self.childProfileID = childProfileID
        self.createdAt = createdAt
    }
}

public struct UsageSession: Codable, Identifiable {
    public let id: String
    public let childProfileID: String
    public let appBundleID: String
    public let category: AppCategory
    public let startTime: Date
    public let endTime: Date
    public let duration: TimeInterval
    
    public init(id: String, childProfileID: String, appBundleID: String, category: AppCategory, startTime: Date, endTime: Date, duration: TimeInterval) {
        self.id = id
        self.childProfileID = childProfileID
        self.appBundleID = appBundleID
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
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

// MARK: - Repository Protocols

public protocol FamilyRepository {
    func createFamily(_ family: Family) async throws -> Family
    func fetchFamily(id: String) async throws -> Family?
    func updateFamily(_ family: Family) async throws -> Family
    func deleteFamily(id: String) async throws
    func fetchFamilies(for userID: String) async throws -> [Family]
}

public protocol ChildProfileRepository {
    func createChild(_ child: ChildProfile) async throws -> ChildProfile
    func fetchChild(id: String) async throws -> ChildProfile?
    func fetchChildren(for familyID: String) async throws -> [ChildProfile]
    func updateChild(_ child: ChildProfile) async throws -> ChildProfile
    func deleteChild(id: String) async throws
}

public protocol AppCategorizationRepository {
    func createAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization
    func fetchAppCategorization(id: String) async throws -> AppCategorization?
    func fetchAppCategorizations(for childID: String) async throws -> [AppCategorization]
    func updateAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization
    func deleteAppCategorization(id: String) async throws
}

public protocol UsageSessionRepository {
    func createSession(_ session: UsageSession) async throws -> UsageSession
    func fetchSession(id: String) async throws -> UsageSession?
    func fetchSessions(for childID: String, dateRange: DateRange?) async throws -> [UsageSession]
    func updateSession(_ session: UsageSession) async throws -> UsageSession
    func deleteSession(id: String) async throws
}

public protocol PointTransactionRepository {
    func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction
    func fetchTransaction(id: String) async throws -> PointTransaction?
    func fetchTransactions(for childID: String, limit: Int?) async throws -> [PointTransaction]
    func fetchTransactions(for childID: String, dateRange: DateRange?) async throws -> [PointTransaction]
    func deleteTransaction(id: String) async throws
}

public protocol RewardRedemptionRepository {
    func createRedemption(_ redemption: RewardRedemption) async throws -> RewardRedemption
    func fetchRedemption(id: String) async throws -> RewardRedemption?
    func fetchRedemptions(for childID: String) async throws -> [RewardRedemption]
    func updateRedemption(_ redemption: RewardRedemption) async throws -> RewardRedemption
    func deleteRedemption(id: String) async throws
}

public protocol FamilySettingsRepository {
    func createSettings(_ settings: FamilySettings) async throws -> FamilySettings
    func fetchSettings(for familyID: String) async throws -> FamilySettings?
    func updateSettings(_ settings: FamilySettings) async throws -> FamilySettings
    func deleteSettings(id: String) async throws
}

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