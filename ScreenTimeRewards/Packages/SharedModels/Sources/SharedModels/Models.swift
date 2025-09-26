import Foundation

// MARK: - User Models

public struct ChildProfile {
    public let id: UUID
    public let name: String
    public let parentID: UUID
    public let pointBalance: Int
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        parentID: UUID,
        pointBalance: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.parentID = parentID
        self.pointBalance = pointBalance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct ParentProfile {
    public let id: UUID
    public let name: String
    public let email: String
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        email: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Reward Models

public struct Reward {
    public let id: UUID
    public let title: String
    public let description: String
    public let pointCost: Int
    public let isActive: Bool
    public let parentID: UUID
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        pointCost: Int,
        isActive: Bool = true,
        parentID: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.pointCost = pointCost
        self.isActive = isActive
        self.parentID = parentID
        self.createdAt = createdAt
    }
}

// MARK: - Screen Time Models

public struct ScreenTimeSession {
    public let id: UUID
    public let childID: UUID
    public let appName: String
    public let duration: TimeInterval
    public let pointsEarned: Int
    public let sessionDate: Date

    public init(
        id: UUID = UUID(),
        childID: UUID,
        appName: String,
        duration: TimeInterval,
        pointsEarned: Int,
        sessionDate: Date = Date()
    ) {
        self.id = id
        self.childID = childID
        self.appName = appName
        self.duration = duration
        self.pointsEarned = pointsEarned
        self.sessionDate = sessionDate
    }
}

// MARK: - App Category Models

public enum AppCategory: String, CaseIterable {
    case educational = "educational"
    case creative = "creative"
    case reading = "reading"
    case productivity = "productivity"
    case entertainment = "entertainment"
    case games = "games"
    case social = "social"
    case other = "other"

    public var displayName: String {
        switch self {
        case .educational: return "Educational"
        case .creative: return "Creative"
        case .reading: return "Reading"
        case .productivity: return "Productivity"
        case .entertainment: return "Entertainment"
        case .games: return "Games"
        case .social: return "Social"
        case .other: return "Other"
        }
    }

    public var pointsPerMinute: Int {
        switch self {
        case .educational: return 2
        case .creative: return 2
        case .reading: return 3
        case .productivity: return 1
        case .entertainment: return 0
        case .games: return 0
        case .social: return 0
        case .other: return 0
        }
    }
}