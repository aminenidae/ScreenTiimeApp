import SwiftUI

struct TrendAnalysisView: View {
    let trends: TrendAnalysis

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Trend Analysis")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            // Daily usage chart
            DailyUsageChartView(dailyUsage: trends.dailyUsage)

            // Peak usage hours
            PeakUsageHoursView(peakHours: trends.peakUsageHours)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct DailyUsageChartView: View {
    let dailyUsage: [DailyUsageData]

    private let maxValue: Int
    private let dateFormatter: DateFormatter

    init(dailyUsage: [DailyUsageData]) {
        self.dailyUsage = dailyUsage
        self.maxValue = dailyUsage.map { $0.totalMinutes }.max() ?? 1

        self.dateFormatter = DateFormatter()
        if dailyUsage.count <= 7 {
            dateFormatter.dateFormat = "E" // Short day name
        } else {
            dateFormatter.dateFormat = "M/d" // Month/day
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Daily Usage")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }

            if dailyUsage.isEmpty {
                Text("No usage data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(dailyUsage, id: \.date) { data in
                            DailyBarView(
                                data: data,
                                maxValue: maxValue,
                                dateLabel: dateFormatter.string(from: data.date)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
        }
    }
}

struct DailyBarView: View {
    let data: DailyUsageData
    let maxValue: Int
    let dateLabel: String

    private var learningHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(data.learningMinutes) / CGFloat(maxValue) * 80
    }

    private var rewardHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(data.rewardMinutes) / CGFloat(maxValue) * 80
    }

    var body: some View {
        VStack(spacing: 4) {
            VStack(spacing: 2) {
                // Reward time (top)
                Rectangle()
                    .fill(Color.purple)
                    .frame(width: 24, height: rewardHeight)

                // Learning time (bottom)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 24, height: learningHeight)
            }
            .frame(height: 80, alignment: .bottom)

            Text(dateLabel)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            // TODO: Show detailed breakdown for this day
        }
    }
}

struct PeakUsageHoursView: View {
    let peakHours: [Int]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Peak Usage Hours")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }

            if peakHours.isEmpty {
                Text("No peak hours identified")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                HStack(spacing: 12) {
                    ForEach(peakHours, id: \.self) { hour in
                        PeakHourBadge(hour: hour)
                    }
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
        )
    }
}

struct PeakHourBadge: View {
    let hour: Int

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }

    var body: some View {
        Text(timeString)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
            )
    }
}

// Weekly comparison view
struct WeeklyComparisonView: View {
    let comparison: WeeklyComparison

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Weekly Comparison")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 16) {
                WeeklyMetricView(
                    title: "This Week",
                    value: formatDuration(comparison.currentWeekMinutes),
                    color: .blue
                )

                WeeklyMetricView(
                    title: "Last Week",
                    value: formatDuration(comparison.previousWeekMinutes),
                    color: .gray
                )

                TrendIndicatorView(
                    change: comparison.percentageChange,
                    direction: comparison.trendDirection
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
}

struct WeeklyMetricView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TrendIndicatorView: View {
    let change: Double
    let direction: TrendDirection

    private var iconName: String {
        switch direction {
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }

    private var color: Color {
        switch direction {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(color)

            Text("\(String(format: "%.1f", abs(change)))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)

            Text("change")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Streak view
struct StreakView: View {
    let streakData: StreakData

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Streaks & Habits")
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StreakCard(
                    title: "Learning Streak",
                    current: streakData.currentLearningStreak,
                    longest: streakData.longestLearningStreak,
                    icon: "book.fill",
                    color: .green
                )

                StreakCard(
                    title: "Balanced Usage",
                    current: streakData.currentBalancedStreak,
                    longest: streakData.longestBalancedStreak,
                    icon: "scale.3d",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct StreakCard: View {
    let title: String
    let current: Int
    let longest: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text("\(current)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)

                Text("current")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 2) {
                Text("Best: \(longest)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// Quick view for overview tab
struct TrendQuickView: View {
    let trends: TrendAnalysis

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Trends")
                    .font(.headline)
                Spacer()
                NavigationLink("View All") {
                    // TODO: Navigate to detailed trend view
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            WeeklyComparisonView(comparison: trends.weeklyComparison)
        }
    }
}

#Preview {
    let mockTrends = TrendAnalysis(
        dailyUsage: [
            DailyUsageData(date: Date().addingTimeInterval(-6*24*60*60), totalMinutes: 45, learningMinutes: 30, rewardMinutes: 15, pointsEarned: 75),
            DailyUsageData(date: Date().addingTimeInterval(-5*24*60*60), totalMinutes: 60, learningMinutes: 40, rewardMinutes: 20, pointsEarned: 100),
            DailyUsageData(date: Date().addingTimeInterval(-4*24*60*60), totalMinutes: 30, learningMinutes: 25, rewardMinutes: 5, pointsEarned: 55),
            DailyUsageData(date: Date().addingTimeInterval(-3*24*60*60), totalMinutes: 75, learningMinutes: 50, rewardMinutes: 25, pointsEarned: 125),
            DailyUsageData(date: Date().addingTimeInterval(-2*24*60*60), totalMinutes: 40, learningMinutes: 30, rewardMinutes: 10, pointsEarned: 70),
            DailyUsageData(date: Date().addingTimeInterval(-1*24*60*60), totalMinutes: 55, learningMinutes: 35, rewardMinutes: 20, pointsEarned: 90),
            DailyUsageData(date: Date(), totalMinutes: 65, learningMinutes: 45, rewardMinutes: 20, pointsEarned: 110)
        ],
        weeklyComparison: WeeklyComparison(
            currentWeekMinutes: 370,
            previousWeekMinutes: 320,
            percentageChange: 15.6,
            trendDirection: .up
        ),
        streakData: StreakData(
            currentLearningStreak: 5,
            longestLearningStreak: 12,
            currentBalancedStreak: 3,
            longestBalancedStreak: 8
        ),
        peakUsageHours: [16, 19, 20]
    )

    return TrendAnalysisView(trends: mockTrends)
        .padding()
}