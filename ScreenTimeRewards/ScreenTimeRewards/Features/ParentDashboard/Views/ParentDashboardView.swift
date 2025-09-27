import SwiftUI
import SharedModels
import DesignSystem

struct ParentDashboardView: View {
    @StateObject private var viewModel = ParentDashboardViewModel()
    @StateObject private var navigationCoordinator = ParentDashboardNavigationCoordinator()

    private var navigationActions: ParentDashboardNavigationActions {
        ParentDashboardNavigationActions(coordinator: navigationCoordinator)
    }

    var body: some View {
        NavigationStack(path: $navigationCoordinator.navigationPath) {
            ZStack {
                if viewModel.isLoading && viewModel.children.isEmpty {
                    loadingView
                } else if viewModel.children.isEmpty {
                    emptyStateView
                } else {
                    dashboardContent
                }
            }
            .navigationTitle("Family Dashboard")
            .refreshable {
                await viewModel.refreshData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    quickActionsMenu
                }
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onReceive(viewModel.childrenPublisher) { children in
            // Reactive updates when children data changes
        }
        .onReceive(viewModel.progressDataPublisher) { progressData in
            // Reactive updates when progress data changes
        }
        .navigationDestination(for: ParentDashboardDestination.self) { destination in
            destinationView(for: destination)
        }
        .sheet(item: $navigationCoordinator.presentedSheet) { destination in
            sheetView(for: destination)
        }
    }

    private var dashboardContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Family Overview Section
                familyOverviewSection

                // Children Progress Cards
                childrenProgressSection

                // Quick Actions Section
                quickActionsSection
            }
            .padding()
        }
    }

    private var familyOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Family Overview")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                OverviewCard(
                    title: "Total Children",
                    value: "\(viewModel.children.count)",
                    icon: "person.2.fill",
                    color: .blue
                )

                OverviewCard(
                    title: "Total Points",
                    value: "\(viewModel.children.reduce(0) { $0 + $1.pointBalance })",
                    icon: "star.fill",
                    color: .yellow
                )

                OverviewCard(
                    title: "Active Learners",
                    value: "\(activeLearnerCount)",
                    icon: "book.fill",
                    color: .green
                )
            }
        }
    }

    private var childrenProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Children's Progress")
                .font(.title2)
                .fontWeight(.bold)

            LazyVStack(spacing: 16) {
                ForEach(viewModel.children) { child in
                    ChildProgressCard(
                        child: child,
                        progressData: viewModel.getProgressData(for: child.id)
                    )
                }
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionButton(
                    title: "Categorize Apps",
                    icon: "apps.iphone",
                    action: { navigationActions.navigateToAppCategorization() }
                )

                QuickActionButton(
                    title: "Adjust Settings",
                    icon: "gearshape.fill",
                    action: { navigationActions.navigateToSettings() }
                )

                QuickActionButton(
                    title: "View Reports",
                    icon: "chart.bar.fill",
                    action: { navigationActions.navigateToDetailedReports() }
                )

                QuickActionButton(
                    title: "Add Child",
                    icon: "person.badge.plus.fill",
                    action: { navigationActions.presentAddChild() }
                )
            }
        }
    }

    private var quickActionsMenu: some View {
        Menu {
            Button("Categorize Apps") {
                navigationActions.navigateToAppCategorization()
            }

            Button("Adjust Settings") {
                navigationActions.navigateToSettings()
            }

            Button("View Detailed Reports") {
                navigationActions.navigateToDetailedReports()
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading family data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Children Added Yet")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Start by adding your first child to begin tracking their learning progress and rewards.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Add Your First Child") {
                navigationActions.presentAddChild()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var activeLearnerCount: Int {
        viewModel.children.filter { child in
            let progressData = viewModel.getProgressData(for: child.id)
            return progressData.learningStreak > 0
        }.count
    }

    // MARK: - Navigation Helpers

    @ViewBuilder
    private func destinationView(for destination: ParentDashboardDestination) -> some View {
        switch destination {
        case .appCategorization:
            AppCategorizationView()
        case .settings:
            SettingsView()
        case .detailedReports:
            DetailedReportsView()
        case .childDetail(let childID):
            ChildDetailView(childID: childID)
        case .addChild:
            // This should be presented as sheet, not pushed
            EmptyView()
        }
    }

    @ViewBuilder
    private func sheetView(for destination: ParentDashboardDestination) -> some View {
        switch destination {
        case .addChild:
            AddChildView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Supporting Views

struct OverviewCard: View {
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
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityHint("Overview information for \(title)")
        .accessibilityAddTraits(.isStaticText)
    }
}

struct ChildProgressCard: View {
    let child: ChildProfile
    let progressData: ChildProgressData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Child Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("\(child.pointBalance) points")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Learning Streak
                if progressData.learningStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)

                        Text("\(progressData.learningStreak) day streak")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.2))
                    )
                }
            }

            // Progress Rings and Today's Summary
            HStack(spacing: 20) {
                // Learning Progress Ring
                ProgressRingView(
                    progress: learningProgress,
                    color: .green,
                    label: "Learning",
                    value: "\(progressData.todaysLearningMinutes)m"
                )

                // Reward Time Ring
                ProgressRingView(
                    progress: rewardProgress,
                    color: .blue,
                    label: "Rewards",
                    value: "\(progressData.todaysRewardMinutes)m"
                )

                Spacer()

                // Weekly Points Chart
                WeeklyPointsChart(weeklyPoints: progressData.weeklyPoints)
            }

            // Recent Activity
            if !progressData.recentTransactions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Activity")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    LazyVStack(spacing: 4) {
                        ForEach(progressData.recentTransactions.prefix(3)) { transaction in
                            RecentActivityRow(transaction: transaction)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Progress for \(child.name)")
        .accessibilityHint("View detailed progress information for \(child.name)")
        .onTapGesture {
            // Navigate to child detail when tapped for accessibility
        }
    }

    private var learningProgress: Double {
        // Assume 60 minutes is 100% for daily learning goal
        return min(Double(progressData.todaysLearningMinutes) / 60.0, 1.0)
    }

    private var rewardProgress: Double {
        // Show reward time as a portion of total screen time
        let totalMinutes = progressData.todaysLearningMinutes + progressData.todaysRewardMinutes
        guard totalMinutes > 0 else { return 0 }
        return Double(progressData.todaysRewardMinutes) / Double(totalMinutes)
    }
}

struct ProgressRingView: View {
    let progress: Double
    let color: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))

                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
        .accessibilityValue("\(Int(progress * 100))% complete")
        .accessibilityAddTraits(.isStaticText)
    }
}

struct WeeklyPointsChart: View {
    let weeklyPoints: [DailyPointData]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("7-Day Points")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(weeklyPoints.suffix(7)) { dayData in
                    BarView(
                        height: barHeight(for: dayData.points),
                        color: .yellow
                    )
                }
            }
            .frame(height: 40)
        }
    }

    private func barHeight(for points: Int) -> CGFloat {
        guard let maxPoints = weeklyPoints.map(\.points).max(), maxPoints > 0 else {
            return 2
        }
        return CGFloat(points) / CGFloat(maxPoints) * 35 + 2
    }
}

struct BarView: View {
    let height: CGFloat
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: height)
    }
}

struct RecentActivityRow: View {
    let transaction: PointTransaction

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(transaction.points > 0 ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(transaction.reason)
                .font(.caption)
                .foregroundColor(.primary)

            Spacer()

            Text("\(transaction.points > 0 ? "+" : "")\(transaction.points)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(transaction.points > 0 ? .green : .red)
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("Navigate to \(title)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    ParentDashboardView()
}

#Preview("With Mock Data") {
    let mockView = ParentDashboardView()
    mockView.viewModel = ParentDashboardViewModel.mockViewModel()
    return mockView
}