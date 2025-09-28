import Foundation

// MARK: - Analytics Event Types

public enum AnalyticsEventType: Codable, Equatable {
    case featureUsage(feature: String)
    case userFlow(flow: String, step: String)
    case performance(metric: String, value: Double)
    case error(category: String, code: String)
    case engagement(type: String, duration: TimeInterval)
}

// MARK: - Analytics Event

public struct AnalyticsEvent: Codable, Equatable, Identifiable {
    public let id: UUID
    public let eventType: AnalyticsEventType
    public let timestamp: Date
    public let anonymizedUserID: String     // Hashed family ID
    public let sessionID: String           // Analytics session identifier
    public let appVersion: String
    public let osVersion: String
    public let deviceModel: String         // Anonymized device type
    public let metadata: [String: String]  // Additional event-specific data
    
    public init(
        id: UUID = UUID(),
        eventType: AnalyticsEventType,
        timestamp: Date = Date(),
        anonymizedUserID: String,
        sessionID: String,
        appVersion: String,
        osVersion: String,
        deviceModel: String,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.eventType = eventType
        self.timestamp = timestamp
        self.anonymizedUserID = anonymizedUserID
        self.sessionID = sessionID
        self.appVersion = appVersion
        self.osVersion = osVersion
        self.deviceModel = deviceModel
        self.metadata = metadata
    }
}

// MARK: - Analytics Aggregation Types

public enum AggregationType: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
}

// MARK: - Retention Metrics

public struct RetentionMetrics: Codable, Equatable {
    public let dayOneRetention: Double     // Percentage
    public let daySevenRetention: Double
    public let dayThirtyRetention: Double
    public let cohortSize: Int
    
    public init(
        dayOneRetention: Double,
        daySevenRetention: Double,
        dayThirtyRetention: Double,
        cohortSize: Int
    ) {
        self.dayOneRetention = dayOneRetention
        self.daySevenRetention = daySevenRetention
        self.dayThirtyRetention = dayThirtyRetention
        self.cohortSize = cohortSize
    }
}

// MARK: - Memory Usage Metrics

public struct MemoryUsageMetrics: Codable, Equatable {
    public let averageMemory: Double       // MB
    public let peakMemory: Double          // MB
    public let memoryGrowthRate: Double    // MB/minute
    
    public init(
        averageMemory: Double,
        peakMemory: Double,
        memoryGrowthRate: Double
    ) {
        self.averageMemory = averageMemory
        self.peakMemory = peakMemory
        self.memoryGrowthRate = memoryGrowthRate
    }
}

// MARK: - Performance Metrics

public struct PerformanceMetrics: Codable, Equatable {
    public let averageAppLaunchTime: TimeInterval
    public let crashRate: Double           // Percentage
    public let averageBatteryImpact: Double
    public let memoryUsage: MemoryUsageMetrics
    
    public init(
        averageAppLaunchTime: TimeInterval,
        crashRate: Double,
        averageBatteryImpact: Double,
        memoryUsage: MemoryUsageMetrics
    ) {
        self.averageAppLaunchTime = averageAppLaunchTime
        self.crashRate = crashRate
        self.averageBatteryImpact = averageBatteryImpact
        self.memoryUsage = memoryUsage
    }
}

// MARK: - Analytics Aggregation

public struct AnalyticsAggregation: Codable, Equatable, Identifiable {
    public let id: UUID
    public let aggregationType: AggregationType
    public let startDate: Date
    public let endDate: Date
    public let totalUsers: Int             // Anonymous count
    public let totalSessions: Int
    public let averageSessionDuration: TimeInterval
    public let featureUsageCounts: [String: Int]
    public let retentionMetrics: RetentionMetrics
    public let performanceMetrics: PerformanceMetrics
    
    public init(
        id: UUID = UUID(),
        aggregationType: AggregationType,
        startDate: Date,
        endDate: Date,
        totalUsers: Int,
        totalSessions: Int,
        averageSessionDuration: TimeInterval,
        featureUsageCounts: [String: Int],
        retentionMetrics: RetentionMetrics,
        performanceMetrics: PerformanceMetrics
    ) {
        self.id = id
        self.aggregationType = aggregationType
        self.startDate = startDate
        self.endDate = endDate
        self.totalUsers = totalUsers
        self.totalSessions = totalSessions
        self.averageSessionDuration = averageSessionDuration
        self.featureUsageCounts = featureUsageCounts
        self.retentionMetrics = retentionMetrics
        self.performanceMetrics = performanceMetrics
    }
}

// MARK: - Analytics Consent Level

public enum AnalyticsConsentLevel: String, Codable, CaseIterable, Sendable {
    case none                       // No analytics collection
    case essential                  // Crash reports and critical metrics only
    case standard                   // Feature usage and performance
    case detailed                   // Comprehensive analytics (default)
}

// MARK: - Analytics Consent

/// Model representing a family's analytics consent
public struct AnalyticsConsent: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let familyID: String
    public let consentLevel: AnalyticsConsentLevel
    public let consentDate: Date
    public let consentVersion: String
    public let ipAddress: String?
    public let userAgent: String?
    public let lastUpdated: Date
    
    public init(
        id: UUID = UUID(),
        familyID: String,
        consentLevel: AnalyticsConsentLevel,
        consentDate: Date,
        consentVersion: String,
        ipAddress: String? = nil,
        userAgent: String? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.familyID = familyID
        self.consentLevel = consentLevel
        self.consentDate = consentDate
        self.consentVersion = consentVersion
        self.ipAddress = ipAddress
        self.userAgent = userAgent
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Analytics Event Collector Protocol

@available(iOS 15.0, macOS 10.15, *)
public protocol AnalyticsEventCollector {
    func trackEvent(_ event: AnalyticsEvent) async
    func trackFeatureUsage(feature: String, metadata: [String: String]?) async
    func trackUserFlow(flow: String, step: String) async
    func trackPerformance(metric: String, value: Double) async
    func trackError(category: String, code: String) async
    func trackEngagement(type: String, duration: TimeInterval) async
}