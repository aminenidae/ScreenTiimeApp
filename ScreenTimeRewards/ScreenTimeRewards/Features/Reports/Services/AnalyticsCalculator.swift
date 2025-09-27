import Foundation
import SharedModels

public class AnalyticsCalculator {

    // MARK: - Report Summary Calculations

    public static func calculateReportSummary(
        sessions: [UsageSession],
        transactions: [PointTransaction]
    ) -> ReportSummary {
        let totalTimeMinutes = Int(sessions.reduce(0) { $0 + $1.duration } / 60)
        let totalPointsEarned = transactions.filter { $0.points > 0 }.reduce(0) { $0 + $1.points }

        let learningTimeMinutes = Int(sessions
            .filter { $0.category == .learning }
            .reduce(0) { $0 + $1.duration } / 60)

        let rewardTimeMinutes = Int(sessions
            .filter { $0.category == .reward }
            .reduce(0) { $0 + $1.duration } / 60)

        let totalSessions = sessions.count
        let averageSessionMinutes = totalSessions > 0 ? totalTimeMinutes / totalSessions : 0
        let pointsPerMinute = totalTimeMinutes > 0 ? Double(totalPointsEarned) / Double(totalTimeMinutes) : 0.0

        return ReportSummary(
            totalTimeMinutes: totalTimeMinutes,
            totalPointsEarned: totalPointsEarned,
            learningTimeMinutes: learningTimeMinutes,
            rewardTimeMinutes: rewardTimeMinutes,
            averageSessionMinutes: averageSessionMinutes,
            totalSessions: totalSessions,
            pointsPerMinute: pointsPerMinute
        )
    }

    // MARK: - Category Breakdown Calculations

    public static func calculateCategoryBreakdown(
        sessions: [UsageSession],
        transactions: [PointTransaction],
        categorizations: [AppCategorization]
    ) -> CategoryBreakdown {
        let totalTimeMinutes = sessions.reduce(0) { $0 + $1.duration } / 60

        let learningApps = calculateCategoryAppData(
            sessions: sessions.filter { $0.category == .learning },
            transactions: transactions,
            categorizations: categorizations,
            totalTime: totalTimeMinutes
        )

        let rewardApps = calculateCategoryAppData(
            sessions: sessions.filter { $0.category == .reward },
            transactions: transactions,
            categorizations: categorizations,
            totalTime: totalTimeMinutes
        )

        let learningTime = learningApps.reduce(0) { $0 + $1.totalMinutes }
        let rewardTime = rewardApps.reduce(0) { $0 + $1.totalMinutes }
        let total = learningTime + rewardTime

        let learningPercentage = total > 0 ? Double(learningTime) / Double(total) * 100 : 0
        let rewardPercentage = total > 0 ? Double(rewardTime) / Double(total) * 100 : 0

        return CategoryBreakdown(
            learningApps: learningApps,
            rewardApps: rewardApps,
            learningPercentage: learningPercentage,
            rewardPercentage: rewardPercentage
        )
    }

    private static func calculateCategoryAppData(
        sessions: [UsageSession],
        transactions: [PointTransaction],
        categorizations: [AppCategorization],
        totalTime: TimeInterval
    ) -> [CategoryAppData] {
        let groupedSessions = Dictionary(grouping: sessions) { $0.appBundleID }

        return groupedSessions.map { (bundleID, appSessions) in
            let appTotalMinutes = Int(appSessions.reduce(0) { $0 + $1.duration } / 60)
            let percentage = totalTime > 0 ? Double(appTotalMinutes) / (totalTime / 60) * 100 : 0

            // Find points earned for this app by looking at transactions that occurred during app usage
            let pointsEarned = calculatePointsForApp(
                bundleID: bundleID,
                sessions: appSessions,
                transactions: transactions
            )

            // Get app name from sessions or use bundle ID as fallback
            let appName = appSessions.first?.appBundleID.split(separator: ".").last.map(String.init) ?? bundleID

            return CategoryAppData(
                appBundleID: bundleID,
                appName: appName,
                totalMinutes: appTotalMinutes,
                percentage: percentage,
                pointsEarned: pointsEarned
            )
        }.sorted { $0.totalMinutes > $1.totalMinutes }
    }

    private static func calculatePointsForApp(
        bundleID: String,
        sessions: [UsageSession],
        transactions: [PointTransaction]
    ) -> Int {
        // Estimate points earned for this app based on session times and point transactions
        var totalPoints = 0

        for session in sessions {
            // Find transactions that occurred during this session
            let sessionPoints = transactions.filter { transaction in
                transaction.points > 0 &&
                transaction.timestamp >= session.startTime &&
                transaction.timestamp <= session.endTime
            }.reduce(0) { $0 + $1.points }

            totalPoints += sessionPoints
        }

        return totalPoints
    }

    // MARK: - Trend Analysis Calculations

    public static func calculateTrendAnalysis(
        sessions: [UsageSession],
        transactions: [PointTransaction],
        dateRange: DateRange
    ) -> TrendAnalysis {
        let dailyUsage = calculateDailyUsage(sessions: sessions, transactions: transactions, dateRange: dateRange)
        let weeklyComparison = calculateWeeklyComparison(sessions: sessions)
        let streakData = calculateStreakData(sessions: sessions)
        let peakUsageHours = calculatePeakUsageHours(sessions: sessions)

        return TrendAnalysis(
            dailyUsage: dailyUsage,
            weeklyComparison: weeklyComparison,
            streakData: streakData,
            peakUsageHours: peakUsageHours
        )
    }

    private static func calculateDailyUsage(
        sessions: [UsageSession],
        transactions: [PointTransaction],
        dateRange: DateRange
    ) -> [DailyUsageData] {
        let calendar = Calendar.current
        var dailyData: [DailyUsageData] = []

        var currentDate = calendar.startOfDay(for: dateRange.start)
        let endDate = calendar.startOfDay(for: dateRange.end)

        while currentDate < endDate {
            let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!

            let daySessions = sessions.filter { session in
                session.startTime >= currentDate && session.startTime < nextDate
            }

            let dayTransactions = transactions.filter { transaction in
                transaction.timestamp >= currentDate && transaction.timestamp < nextDate && transaction.points > 0
            }

            let totalMinutes = Int(daySessions.reduce(0) { $0 + $1.duration } / 60)
            let learningMinutes = Int(daySessions.filter { $0.category == .learning }.reduce(0) { $0 + $1.duration } / 60)
            let rewardMinutes = Int(daySessions.filter { $0.category == .reward }.reduce(0) { $0 + $1.duration } / 60)
            let pointsEarned = dayTransactions.reduce(0) { $0 + $1.points }

            dailyData.append(DailyUsageData(
                date: currentDate,
                totalMinutes: totalMinutes,
                learningMinutes: learningMinutes,
                rewardMinutes: rewardMinutes,
                pointsEarned: pointsEarned
            ))

            currentDate = nextDate
        }

        return dailyData
    }

    private static func calculateWeeklyComparison(sessions: [UsageSession]) -> WeeklyComparison {
        let calendar = Calendar.current
        let now = Date()

        // Current week
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let currentWeekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) ?? now

        // Previous week
        let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? currentWeekStart
        let previousWeekEnd = currentWeekStart

        let currentWeekSessions = sessions.filter { session in
            session.startTime >= currentWeekStart && session.startTime < currentWeekEnd
        }

        let previousWeekSessions = sessions.filter { session in
            session.startTime >= previousWeekStart && session.startTime < previousWeekEnd
        }

        let currentWeekMinutes = Int(currentWeekSessions.reduce(0) { $0 + $1.duration } / 60)
        let previousWeekMinutes = Int(previousWeekSessions.reduce(0) { $0 + $1.duration } / 60)

        let percentageChange: Double
        let trendDirection: TrendDirection

        if previousWeekMinutes > 0 {
            percentageChange = Double(currentWeekMinutes - previousWeekMinutes) / Double(previousWeekMinutes) * 100

            if percentageChange > 5 {
                trendDirection = .up
            } else if percentageChange < -5 {
                trendDirection = .down
            } else {
                trendDirection = .stable
            }
        } else {
            percentageChange = currentWeekMinutes > 0 ? 100 : 0
            trendDirection = currentWeekMinutes > 0 ? .up : .stable
        }

        return WeeklyComparison(
            currentWeekMinutes: currentWeekMinutes,
            previousWeekMinutes: previousWeekMinutes,
            percentageChange: percentageChange,
            trendDirection: trendDirection
        )
    }

    private static func calculateStreakData(sessions: [UsageSession]) -> StreakData {
        let calendar = Calendar.current
        let sortedDays = getSortedUniqueDays(from: sessions)

        let learningStreak = calculateStreak(days: sortedDays) { day in
            let daySessions = sessions.filter { session in
                calendar.isDate(session.startTime, inSameDayAs: day)
            }
            return daySessions.contains { $0.category == .learning }
        }

        let balancedStreak = calculateStreak(days: sortedDays) { day in
            let daySessions = sessions.filter { session in
                calendar.isDate(session.startTime, inSameDayAs: day)
            }
            let hasLearning = daySessions.contains { $0.category == .learning }
            let hasReward = daySessions.contains { $0.category == .reward }
            return hasLearning && hasReward
        }

        return StreakData(
            currentLearningStreak: learningStreak.current,
            longestLearningStreak: learningStreak.longest,
            currentBalancedStreak: balancedStreak.current,
            longestBalancedStreak: balancedStreak.longest
        )
    }

    private static func getSortedUniqueDays(from sessions: [UsageSession]) -> [Date] {
        let calendar = Calendar.current
        let uniqueDays = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        return uniqueDays.sorted()
    }

    private static func calculateStreak(days: [Date], condition: (Date) -> Bool) -> (current: Int, longest: Int) {
        guard !days.isEmpty else { return (0, 0) }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0

        // Calculate current streak (must include today or yesterday for continuity)
        for day in days.reversed() {
            if condition(day) {
                if day == today || calendar.dateInterval(of: .day, for: day)?.end == calendar.dateInterval(of: .day, for: today)?.start {
                    currentStreak += 1
                } else if currentStreak == 0 {
                    break
                } else {
                    currentStreak += 1
                }
            } else if currentStreak > 0 {
                break
            }
        }

        // Calculate longest streak
        for day in days {
            if condition(day) {
                tempStreak += 1
                longestStreak = max(longestStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }

        return (currentStreak, longestStreak)
    }

    private static func calculatePeakUsageHours(sessions: [UsageSession]) -> [Int] {
        let calendar = Calendar.current
        var hourUsage: [Int: Int] = [:]

        for session in sessions {
            let hour = calendar.component(.hour, from: session.startTime)
            hourUsage[hour, default: 0] += Int(session.duration / 60)
        }

        let averageUsage = hourUsage.values.reduce(0, +) / max(hourUsage.count, 1)

        return hourUsage
            .filter { $0.value > averageUsage }
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
            .sorted()
    }

    // MARK: - App Usage Details

    public static func calculateAppUsageDetails(
        sessions: [UsageSession],
        transactions: [PointTransaction],
        categorizations: [AppCategorization]
    ) -> [AppUsageDetail] {
        let groupedSessions = Dictionary(grouping: sessions) { $0.appBundleID }

        return groupedSessions.map { (bundleID, appSessions) in
            let totalMinutes = Int(appSessions.reduce(0) { $0 + $1.duration } / 60)
            let averageSessionMinutes = appSessions.count > 0 ? totalMinutes / appSessions.count : 0
            let totalSessions = appSessions.count
            let lastUsed = appSessions.map { $0.endTime }.max()
            let category = appSessions.first?.category ?? .learning

            let pointsEarned = calculatePointsForApp(
                bundleID: bundleID,
                sessions: appSessions,
                transactions: transactions
            )

            let pointsPerHour = categorizations
                .first { $0.appBundleID == bundleID }?.pointsPerHour ?? 0

            let appName = bundleID.split(separator: ".").last.map(String.init) ?? bundleID

            return AppUsageDetail(
                appBundleID: bundleID,
                appName: appName,
                category: category,
                totalMinutes: totalMinutes,
                averageSessionMinutes: averageSessionMinutes,
                totalSessions: totalSessions,
                pointsEarned: pointsEarned,
                pointsPerHour: pointsPerHour,
                lastUsed: lastUsed
            )
        }.sorted { $0.totalMinutes > $1.totalMinutes }
    }

    // MARK: - Date Range Utilities

    public static func createCustomDateRange(start: Date, end: Date) -> DateRange {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) ?? end
        return DateRange(start: startOfDay, end: endOfDay)
    }

    public static func isDateInRange(_ date: Date, range: DateRange) -> Bool {
        return date >= range.start && date < range.end
    }
}