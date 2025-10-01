import SwiftUI
import SharedModels

struct CategoryBreakdownView: View {
    let breakdown: CategoryBreakdown

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Category Breakdown")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            // Pie chart style visualization
            CategoryPieChartView(
                learningPercentage: breakdown.learningPercentage,
                rewardPercentage: breakdown.rewardPercentage
            )

            // Category details
            VStack(spacing: 12) {
                CategorySectionView(
                    title: "Learning Apps",
                    apps: breakdown.learningApps,
                    color: .green,
                    icon: "book.fill"
                )

                CategorySectionView(
                    title: "Reward Apps",
                    apps: breakdown.rewardApps,
                    color: .purple,
                    icon: "gamecontroller.fill"
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

struct CategoryPieChartView: View {
    let learningPercentage: Double
    let rewardPercentage: Double

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 120, height: 120)

                // Learning arc
                Circle()
                    .trim(from: 0, to: learningPercentage / 100)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                // Reward arc
                Circle()
                    .trim(from: learningPercentage / 100, to: (learningPercentage + rewardPercentage) / 100)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                // Center content
                VStack(spacing: 2) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(learningPercentage + rewardPercentage))%")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

            // Legend
            HStack(spacing: 24) {
                LegendItem(
                    color: .green,
                    label: "Learning",
                    percentage: learningPercentage
                )

                LegendItem(
                    color: .purple,
                    label: "Reward",
                    percentage: rewardPercentage
                )
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    let percentage: Double

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.primary)
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CategorySectionView: View {
    let title: String
    let apps: [CategoryAppData]
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                Spacer()
            }

            if apps.isEmpty {
                Text("No apps in this category")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(apps.prefix(3), id: \.appBundleID) { app in
                    CategoryAppRowView(app: app, color: color)
                }

                if apps.count > 3 {
                    Button("Show all \(apps.count) apps") {
                        // TODO: Navigate to detailed view
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
        )
    }
}

struct CategoryAppRowView: View {
    let app: CategoryAppData
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(app.appName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(formatDuration(app.totalMinutes))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(app.pointsEarned) pts")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)

                Text("\(String(format: "%.1f", app.percentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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

// Quick view for overview tab
struct CategoryQuickView: View {
    let breakdown: CategoryBreakdown

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Category Breakdown")
                    .font(.headline)
                Spacer()
                NavigationLink("View All") {
                    // TODO: Navigate to detailed category view
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            CategoryPieChartView(
                learningPercentage: breakdown.learningPercentage,
                rewardPercentage: breakdown.rewardPercentage
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    let mockBreakdown = CategoryBreakdown(
        learningApps: [
            CategoryAppData(
                appBundleID: "com.apple.books",
                appName: "Books",
                totalMinutes: 45,
                percentage: 25.0,
                pointsEarned: 90
            ),
            CategoryAppData(
                appBundleID: "com.duolingo.DuolingoMobile",
                appName: "Duolingo",
                totalMinutes: 30,
                percentage: 16.7,
                pointsEarned: 75
            )
        ],
        rewardApps: [
            CategoryAppData(
                appBundleID: "com.supercell.clash",
                appName: "Clash Royale",
                totalMinutes: 25,
                percentage: 13.9,
                pointsEarned: 0
            )
        ],
        learningPercentage: 75.0,
        rewardPercentage: 25.0
    )

    return CategoryBreakdownView(breakdown: mockBreakdown)
        .padding()
}