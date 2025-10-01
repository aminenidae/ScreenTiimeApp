import SwiftUI

struct ReportsSummaryCard: View {
    let summary: ReportSummary

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SummaryMetricView(
                    title: "Total Time",
                    value: formatDuration(summary.totalTimeMinutes),
                    icon: "clock.fill",
                    color: .blue
                )

                SummaryMetricView(
                    title: "Points Earned",
                    value: formatPoints(summary.totalPointsEarned),
                    icon: "star.fill",
                    color: .orange
                )

                SummaryMetricView(
                    title: "Learning Time",
                    value: formatDuration(summary.learningTimeMinutes),
                    icon: "book.fill",
                    color: .green
                )

                SummaryMetricView(
                    title: "Reward Time",
                    value: formatDuration(summary.rewardTimeMinutes),
                    icon: "gamecontroller.fill",
                    color: .purple
                )

                SummaryMetricView(
                    title: "Sessions",
                    value: "\(summary.totalSessions)",
                    icon: "app.fill",
                    color: .indigo
                )

                SummaryMetricView(
                    title: "Efficiency",
                    value: String(format: "%.1f pts/min", summary.pointsPerMinute),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .mint
                )
            }

            // Progress indicators
            if summary.totalTimeMinutes > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text("Time Breakdown")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }

                    ProgressBarView(
                        learningTime: summary.learningTimeMinutes,
                        rewardTime: summary.rewardTimeMinutes
                    )
                }
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

    private func formatPoints(_ points: Int) -> String {
        if points >= 1000 {
            let thousands = Double(points) / 1000.0
            return String(format: "%.1fK", thousands)
        } else {
            return "\(points)"
        }
    }
}

struct SummaryMetricView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }

                HStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct ProgressBarView: View {
    let learningTime: Int
    let rewardTime: Int

    private var totalTime: Int {
        learningTime + rewardTime
    }

    private var learningPercentage: Double {
        guard totalTime > 0 else { return 0 }
        return Double(learningTime) / Double(totalTime)
    }

    private var rewardPercentage: Double {
        guard totalTime > 0 else { return 0 }
        return Double(rewardTime) / Double(totalTime)
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * learningPercentage)

                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: geometry.size.width * rewardPercentage)

                    Spacer(minLength: 0)
                }
            }
            .frame(height: 8)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 4))

            HStack {
                Label(
                    "\(formatDuration(learningTime)) (\(formatPercentage(learningPercentage * 100)))",
                    systemImage: "book.fill"
                )
                .font(.caption)
                .foregroundColor(.green)

                Spacer()

                Label(
                    "\(formatDuration(rewardTime)) (\(formatPercentage(rewardPercentage * 100)))",
                    systemImage: "gamecontroller.fill"
                )
                .font(.caption)
                .foregroundColor(.purple)
            }
        }
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

    private func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.0f%%", percentage)
    }
}

#Preview {
    ReportsSummaryCard(
        summary: ReportSummary(
            totalTimeMinutes: 180,
            totalPointsEarned: 450,
            learningTimeMinutes: 120,
            rewardTimeMinutes: 60,
            averageSessionMinutes: 30,
            totalSessions: 6,
            pointsPerMinute: 2.5
        )
    )
    .padding()
}