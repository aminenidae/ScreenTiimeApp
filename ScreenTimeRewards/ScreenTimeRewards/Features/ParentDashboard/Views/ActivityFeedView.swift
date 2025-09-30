import SwiftUI
import SharedModels
import DesignSystem
import RewardCore
import Combine

struct ActivityFeedView: View {
    @StateObject private var viewModel = ActivityFeedViewModel()
    @AppStorage("currentFamilyID") private var currentFamilyID = "default-family"
    @State private var selectedActivity: ParentActivity?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.activities.isEmpty {
                    loadingView
                } else if viewModel.activities.isEmpty {
                    emptyStateView
                } else {
                    activityList
                }
            }
            .navigationTitle("Activity Feed")
            .refreshable {
                await viewModel.refreshActivities()
            }
            .task {
                await viewModel.loadActivities()
            }
            .onReceive(viewModel.activitiesPublisher) { activities in
                // Handle real-time activity updates
            }
            .sheet(item: $selectedActivity) { activity in
                ActivityDetailView(activity: activity)
            }
        }
        .badge(viewModel.unreadActivityCount)
    }

    private var activityList: some View {
        List {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.activities.prefix(50)) { activity in // Limit to 50 for memory efficiency
                    ActivityRowView(activity: activity)
                        .onTapGesture {
                            viewModel.markActivityAsRead(activity)
                            selectedActivity = activity
                        }
                        .onAppear {
                            // Load more activities when approaching the end
                            if activity == viewModel.activities.dropFirst(45).first {
                                Task {
                                    await viewModel.loadMoreActivities()
                                }
                            }
                        }

                    Divider()
                        .padding(.leading, 60) // Align with activity content
                }

                // Load more indicator
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            // Cleanup old activities from memory when view appears
            viewModel.cleanupOldActivitiesFromMemory()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading activities...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Activity Yet")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("When your co-parent makes changes to the family settings, you'll see them here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Refresh") {
                Task {
                    await viewModel.refreshActivities()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ActivityRowView: View {
    let activity: ParentActivity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Activity Icon
            Image(systemName: activity.activityType.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                // Activity Type and Time
                HStack {
                    Text(activity.activityType.displayName)
                        .font(.headline)
                        .fontWeight(.medium)

                    Spacer()

                    Text(activity.relativeTimestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Activity Description
                Text(activity.detailedDescription)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(3)

                // Triggering Parent
                Text("by \(parentName(for: activity.triggeringUserID))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.activityType.displayName): \(activity.detailedDescription)")
        .accessibilityHint("Tap for more details")
    }

    private func parentName(for userID: String) -> String {
        // TODO: Implement user name lookup
        return "Parent"
    }
}

// MARK: - ActivityFeedViewModel

@MainActor
class ActivityFeedViewModel: ObservableObject {
    @Published var activities: [ParentActivity] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var unreadActivityCount = 0

    private let activityService: ParentActivityService
    private var hasMoreActivities = true
    private let maxActivitiesInMemory = 100
    @AppStorage("currentFamilyID") private var currentFamilyID = "default-family"

    var activitiesPublisher: Published<[ParentActivity]>.Publisher {
        $activities
    }

    init(activityService: ParentActivityService? = nil) {
        self.activityService = activityService ?? ParentActivityService()
        setupRealTimeUpdates()
    }

    private func setupRealTimeUpdates() {
        // Listen for new activities
        activityService.newActivityPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { newActivity in
                    // Update activities list (already handled in service)
                    self.activities = self.activityService.activities

                    // Update unread count
                    self.unreadActivityCount += 1

                    // Trigger haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            )
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func loadActivities() async {
        guard let familyUUID = UUID(uuidString: currentFamilyID) else {
            errorMessage = "Invalid family ID"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            await activityService.loadRecentActivities(for: familyUUID)
            activities = activityService.activities
            updateUnreadCount()
            errorMessage = nil

            // Set up real-time updates if not already done
            try await activityService.startRealTimeUpdates(for: familyUUID, userID: getCurrentUserID())
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshActivities() async {
        guard let familyUUID = UUID(uuidString: currentFamilyID) else {
            errorMessage = "Invalid family ID"
            return
        }

        do {
            await activityService.refreshActivities(for: familyUUID)
            activities = activityService.activities
            updateUnreadCount()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markActivityAsRead(_ activity: ParentActivity) {
        // TODO: Implement read status tracking
        updateUnreadCount()
    }

    private func updateUnreadCount() {
        // For now, assume no activities are read
        // In a real implementation, we'd track read status
        unreadActivityCount = 0
    }

    private func getCurrentUserID() -> String {
        // In a real implementation, this would get the actual user ID from auth service
        return "current-user-\(UUID().uuidString)"
    }

    func loadMoreActivities() async {
        guard hasMoreActivities && !isLoadingMore else { return }

        guard let familyUUID = UUID(uuidString: currentFamilyID) else {
            errorMessage = "Invalid family ID"
            return
        }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let oldestActivity = activities.last
            let loadLimit = 20 // Load 20 more activities at a time

            let moreActivities = try await activityService.repository.fetchActivities(
                for: familyUUID,
                limit: loadLimit
            )

            // Filter out activities we already have and check for end of data
            let newActivities = moreActivities.filter { newActivity in
                !activities.contains { $0.id == newActivity.id }
            }

            if newActivities.count < loadLimit {
                hasMoreActivities = false
            }

            activities.append(contentsOf: newActivities)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cleanupOldActivitiesFromMemory() {
        // Keep only the most recent activities in memory for performance
        if activities.count > maxActivitiesInMemory {
            let activitiesToKeep = activities.prefix(maxActivitiesInMemory)
            activities = Array(activitiesToKeep)
        }
    }
}

#Preview {
    ActivityFeedView()
}

#Preview("Empty State") {
    let view = ActivityFeedView()
    view.viewModel.activities = []
    return view
}