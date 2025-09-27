import SwiftUI
import SharedModels

struct AppUsageListView: View {
    let appDetails: [AppUsageDetail]
    @State private var selectedCategory: AppCategory?
    @State private var sortOption: SortOption = .totalTime

    enum SortOption: String, CaseIterable {
        case totalTime = "Total Time"
        case pointsEarned = "Points Earned"
        case sessions = "Sessions"
        case lastUsed = "Last Used"
    }

    private var filteredAndSortedApps: [AppUsageDetail] {
        let filtered = selectedCategory == nil ? appDetails : appDetails.filter { $0.category == selectedCategory }

        return filtered.sorted { first, second in
            switch sortOption {
            case .totalTime:
                return first.totalMinutes > second.totalMinutes
            case .pointsEarned:
                return first.pointsEarned > second.pointsEarned
            case .sessions:
                return first.totalSessions > second.totalSessions
            case .lastUsed:
                guard let firstDate = first.lastUsed, let secondDate = second.lastUsed else {
                    return first.lastUsed != nil
                }
                return firstDate > secondDate
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("App Usage Details")
                    .font(.headline)
                Spacer()
            }

            // Filters and Sort
            VStack(spacing: 12) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryFilterButton(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )

                        CategoryFilterButton(
                            title: "Learning",
                            isSelected: selectedCategory == .learning,
                            action: { selectedCategory = .learning }
                        )

                        CategoryFilterButton(
                            title: "Reward",
                            isSelected: selectedCategory == .reward,
                            action: { selectedCategory = .reward }
                        )
                    }
                    .padding(.horizontal)
                }

                // Sort options
                HStack {
                    Text("Sort by:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.caption)

                    Spacer()
                }
            }

            // App list
            if filteredAndSortedApps.isEmpty {
                EmptyAppListView(category: selectedCategory)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(filteredAndSortedApps, id: \.appBundleID) { app in
                        AppUsageDetailRow(app: app)
                    }
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
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AppUsageDetailRow: View {
    let app: AppUsageDetail

    private var categoryColor: Color {
        app.category == .learning ? .green : .purple
    }

    private var categoryIcon: String {
        app.category == .learning ? "book.fill" : "gamecontroller.fill"
    }

    var body: some View {
        HStack(spacing: 12) {
            // App icon placeholder and category indicator
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundColor(categoryColor)
            }

            // App details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(app.appName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Spacer()

                    CategoryBadge(category: app.category)
                }

                HStack(spacing: 16) {
                    StatView(
                        icon: "clock.fill",
                        value: formatDuration(app.totalMinutes),
                        color: .blue
                    )

                    if app.pointsEarned > 0 {
                        StatView(
                            icon: "star.fill",
                            value: "\(app.pointsEarned) pts",
                            color: .orange
                        )
                    }

                    StatView(
                        icon: "app.fill",
                        value: "\(app.totalSessions) sessions",
                        color: .gray
                    )
                }

                if let lastUsed = app.lastUsed {
                    Text("Last used: \(formatRelativeDate(lastUsed))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Efficiency indicator
            VStack(alignment: .trailing, spacing: 2) {
                if app.pointsPerHour > 0 {
                    Text("\(app.pointsPerHour) pts/hr")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(categoryColor)
                }

                Text("Avg: \(app.averageSessionMinutes)m")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(categoryColor.opacity(0.05))
        )
        .onTapGesture {
            // TODO: Navigate to detailed app view
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

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CategoryBadge: View {
    let category: AppCategory

    private var color: Color {
        category == .learning ? .green : .purple
    }

    private var icon: String {
        category == .learning ? "book.fill" : "gamecontroller.fill"
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)

            Text(category.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
        )
    }
}

struct StatView: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)

            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

struct EmptyAppListView: View {
    let category: AppCategory?

    private var message: String {
        if let category = category {
            return "No \(category.rawValue.lowercased()) apps found for this period"
        } else {
            return "No app usage data available for this period"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "app.dashed")
                .font(.system(size: 32))
                .foregroundColor(.gray)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
}

// Detailed app view (for navigation)
struct DetailedAppView: View {
    let app: AppUsageDetail
    let sessions: [UsageSession] // Would be passed from parent

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App header
                AppHeaderView(app: app)

                // Usage metrics
                AppMetricsView(app: app)

                // Session history
                if !sessions.isEmpty {
                    SessionHistoryView(sessions: sessions)
                }
            }
            .padding()
        }
        .navigationTitle(app.appName)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AppHeaderView: View {
    let app: AppUsageDetail

    var body: some View {
        VStack(spacing: 16) {
            // App icon and basic info
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(app.category == .learning ? Color.green.opacity(0.2) : Color.purple.opacity(0.2))
                        .frame(width: 64, height: 64)

                    Image(systemName: app.category == .learning ? "book.fill" : "gamecontroller.fill")
                        .font(.title)
                        .foregroundColor(app.category == .learning ? .green : .purple)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(app.appName)
                        .font(.title2)
                        .fontWeight(.bold)

                    CategoryBadge(category: app.category)

                    if let lastUsed = app.lastUsed {
                        Text("Last used: \(formatRelativeDate(lastUsed))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct AppMetricsView: View {
    let app: AppUsageDetail

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Usage Metrics")
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total Time",
                    value: formatDuration(app.totalMinutes),
                    icon: "clock.fill",
                    color: .blue
                )

                MetricCard(
                    title: "Sessions",
                    value: "\(app.totalSessions)",
                    icon: "app.fill",
                    color: .indigo
                )

                MetricCard(
                    title: "Avg Session",
                    value: "\(app.averageSessionMinutes)m",
                    icon: "timer",
                    color: .teal
                )

                if app.pointsEarned > 0 {
                    MetricCard(
                        title: "Points Earned",
                        value: "\(app.pointsEarned)",
                        icon: "star.fill",
                        color: .orange
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
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct SessionHistoryView: View {
    let sessions: [UsageSession]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Sessions")
                    .font(.headline)
                Spacer()
            }

            ForEach(sessions.prefix(10), id: \.id) { session in
                SessionRowView(session: session)
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

struct SessionRowView: View {
    let session: UsageSession

    private var duration: String {
        let minutes = Int(session.duration / 60)
        return "\(minutes)m"
    }

    private var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: session.startTime)) - \(formatter.string(from: session.endTime))"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(timeRange)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(formatDate(session.startTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(duration)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    let mockApps = [
        AppUsageDetail(
            appBundleID: "com.apple.books",
            appName: "Books",
            category: .learning,
            totalMinutes: 120,
            averageSessionMinutes: 30,
            totalSessions: 4,
            pointsEarned: 240,
            pointsPerHour: 120,
            lastUsed: Date().addingTimeInterval(-3600)
        ),
        AppUsageDetail(
            appBundleID: "com.duolingo.DuolingoMobile",
            appName: "Duolingo",
            category: .learning,
            totalMinutes: 45,
            averageSessionMinutes: 15,
            totalSessions: 3,
            pointsEarned: 135,
            pointsPerHour: 180,
            lastUsed: Date().addingTimeInterval(-7200)
        ),
        AppUsageDetail(
            appBundleID: "com.supercell.clash",
            appName: "Clash Royale",
            category: .reward,
            totalMinutes: 60,
            averageSessionMinutes: 20,
            totalSessions: 3,
            pointsEarned: 0,
            pointsPerHour: 0,
            lastUsed: Date().addingTimeInterval(-1800)
        )
    ]

    return AppUsageListView(appDetails: mockApps)
        .padding()
}