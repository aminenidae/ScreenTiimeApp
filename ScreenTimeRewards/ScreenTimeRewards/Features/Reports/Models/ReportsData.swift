import Foundation
import SharedModels

// MARK: - Report Data Models

public struct ReportsData {
    public let period: ReportPeriod
    public let dateRange: DateRange
    public let summary: ReportSummary
    public let categoryBreakdown: CategoryBreakdown
    public let trends: TrendAnalysis
    public let appDetails: [AppUsageDetail]

    public init(
        period: ReportPeriod,
        dateRange: DateRange,
        summary: ReportSummary,
        categoryBreakdown: CategoryBreakdown,
        trends: TrendAnalysis,
        appDetails: [AppUsageDetail]
    ) {
        self.period = period
        self.dateRange = dateRange
        self.summary = summary
        self.categoryBreakdown = categoryBreakdown
        self.trends = trends
        self.appDetails = appDetails
    }
}

public enum ReportPeriod: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
    case custom = "Custom Range"

    public var dateRange: DateRange {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return DateRange(start: start, end: end)

        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? now
            return DateRange(start: start, end: end)

        case .month:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
            return DateRange(start: start, end: end)

        case .custom:
            return DateRange(start: now, end: now)
        }
    }
}

public struct ReportSummary {
    public let totalTimeMinutes: Int
    public let totalPointsEarned: Int
    public let learningTimeMinutes: Int
    public let rewardTimeMinutes: Int
    public let averageSessionMinutes: Int
    public let totalSessions: Int
    public let pointsPerMinute: Double

    public init(
        totalTimeMinutes: Int,
        totalPointsEarned: Int,
        learningTimeMinutes: Int,
        rewardTimeMinutes: Int,
        averageSessionMinutes: Int,
        totalSessions: Int,
        pointsPerMinute: Double
    ) {
        self.totalTimeMinutes = totalTimeMinutes
        self.totalPointsEarned = totalPointsEarned
        self.learningTimeMinutes = learningTimeMinutes
        self.rewardTimeMinutes = rewardTimeMinutes
        self.averageSessionMinutes = averageSessionMinutes
        self.totalSessions = totalSessions
        self.pointsPerMinute = pointsPerMinute
    }
}

public struct CategoryBreakdown {
    public let learningApps: [CategoryAppData]
    public let rewardApps: [CategoryAppData]
    public let learningPercentage: Double
    public let rewardPercentage: Double

    public init(
        learningApps: [CategoryAppData],
        rewardApps: [CategoryAppData],
        learningPercentage: Double,
        rewardPercentage: Double
    ) {
        self.learningApps = learningApps
        self.rewardApps = rewardApps
        self.learningPercentage = learningPercentage
        self.rewardPercentage = rewardPercentage
    }
}

public struct CategoryAppData {
    public let appBundleID: String
    public let appName: String
    public let totalMinutes: Int
    public let percentage: Double
    public let pointsEarned: Int

    public init(
        appBundleID: String,
        appName: String,
        totalMinutes: Int,
        percentage: Double,
        pointsEarned: Int
    ) {
        self.appBundleID = appBundleID
        self.appName = appName
        self.totalMinutes = totalMinutes
        self.percentage = percentage
        self.pointsEarned = pointsEarned
    }
}

public struct TrendAnalysis {
    public let dailyUsage: [DailyUsageData]
    public let weeklyComparison: WeeklyComparison
    public let streakData: StreakData
    public let peakUsageHours: [Int]

    public init(
        dailyUsage: [DailyUsageData],
        weeklyComparison: WeeklyComparison,
        streakData: StreakData,
        peakUsageHours: [Int]
    ) {
        self.dailyUsage = dailyUsage
        self.weeklyComparison = weeklyComparison
        self.streakData = streakData
        self.peakUsageHours = peakUsageHours
    }
}

public struct DailyUsageData {
    public let date: Date
    public let totalMinutes: Int
    public let learningMinutes: Int
    public let rewardMinutes: Int
    public let pointsEarned: Int

    public init(
        date: Date,
        totalMinutes: Int,
        learningMinutes: Int,
        rewardMinutes: Int,
        pointsEarned: Int
    ) {
        self.date = date
        self.totalMinutes = totalMinutes
        self.learningMinutes = learningMinutes
        self.rewardMinutes = rewardMinutes
        self.pointsEarned = pointsEarned
    }
}

public struct WeeklyComparison {
    public let currentWeekMinutes: Int
    public let previousWeekMinutes: Int
    public let percentageChange: Double
    public let trendDirection: TrendDirection

    public init(
        currentWeekMinutes: Int,
        previousWeekMinutes: Int,
        percentageChange: Double,
        trendDirection: TrendDirection
    ) {
        self.currentWeekMinutes = currentWeekMinutes
        self.previousWeekMinutes = previousWeekMinutes
        self.percentageChange = percentageChange
        self.trendDirection = trendDirection
    }
}

public enum TrendDirection {
    case up
    case down
    case stable
}

public struct StreakData {
    public let currentLearningStreak: Int
    public let longestLearningStreak: Int
    public let currentBalancedStreak: Int
    public let longestBalancedStreak: Int

    public init(
        currentLearningStreak: Int,
        longestLearningStreak: Int,
        currentBalancedStreak: Int,
        longestBalancedStreak: Int
    ) {
        self.currentLearningStreak = currentLearningStreak
        self.longestLearningStreak = longestLearningStreak
        self.currentBalancedStreak = currentBalancedStreak
        self.longestBalancedStreak = longestBalancedStreak
    }
}

public struct AppUsageDetail {
    public let appBundleID: String
    public let appName: String
    public let category: AppCategory
    public let totalMinutes: Int
    public let averageSessionMinutes: Int
    public let totalSessions: Int
    public let pointsEarned: Int
    public let pointsPerHour: Int
    public let lastUsed: Date?

    public init(
        appBundleID: String,
        appName: String,
        category: AppCategory,
        totalMinutes: Int,
        averageSessionMinutes: Int,
        totalSessions: Int,
        pointsEarned: Int,
        pointsPerHour: Int,
        lastUsed: Date?
    ) {
        self.appBundleID = appBundleID
        self.appName = appName
        self.category = category
        self.totalMinutes = totalMinutes
        self.averageSessionMinutes = averageSessionMinutes
        self.totalSessions = totalSessions
        self.pointsEarned = pointsEarned
        self.pointsPerHour = pointsPerHour
        self.lastUsed = lastUsed
    }
}

// MARK: - Export Data Models

public struct ExportData {
    public let reportType: ExportType
    public let child: ChildProfile
    public let dateRange: DateRange
    public let summary: ReportSummary
    public let detailedData: [AppUsageDetail]
    public let exportDate: Date

    public init(
        reportType: ExportType,
        child: ChildProfile,
        dateRange: DateRange,
        summary: ReportSummary,
        detailedData: [AppUsageDetail],
        exportDate: Date = Date()
    ) {
        self.reportType = reportType
        self.child = child
        self.dateRange = dateRange
        self.summary = summary
        self.detailedData = detailedData
        self.exportDate = exportDate
    }
}

public enum ExportType: String, CaseIterable {
    case text = "Text Report"
    case csv = "CSV Data"
    case summary = "Summary Report"
}