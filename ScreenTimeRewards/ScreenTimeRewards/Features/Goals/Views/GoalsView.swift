import SwiftUI
import SharedModels

public struct GoalsView: View {
    @StateObject private var viewModel: GoalTrackingViewModel
    @State private var showingGoalCreation = false
    @State private var showingAchievementCelebration = false
    @State private var celebratedBadge: AchievementBadge?

    public init(viewModel: GoalTrackingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.refreshData()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Goal Summary Header
                            GoalSummaryHeaderView(goals: viewModel.goals)
                            
                            // Active Goals List
                            if !viewModel.goals.isEmpty {
                                ActiveGoalsListView(
                                    goals: viewModel.goals,
                                    hasActiveSubscription: viewModel.hasActiveSubscription
                                ) { goal in
                                    // Handle goal selection
                                    print("Selected goal: \(goal.title)")
                                }
                            } else {
                                EmptyStateView(
                                    title: "No Goals Yet",
                                    message: "Create your first educational goal to start tracking progress!",
                                    imageName: "target"
                                )
                            }
                            
                            // Achievement Badges
                            if !viewModel.badges.isEmpty {
                                AchievementBadgesView(badges: viewModel.badges) { badge in
                                    celebratedBadge = badge
                                    showingAchievementCelebration = true
                                }
                            }
                            
                            // Goal History (Completed/Failed)
                            GoalHistoryView(goals: viewModel.goals)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Goals & Badges")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingGoalCreation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingGoalCreation) {
                GoalCreationView { goal in
                    Task {
                        try? await viewModel.createGoal(goal)
                        showingGoalCreation = false
                    }
                }
            }
            .sheet(isPresented: $showingAchievementCelebration) {
                if let badge = celebratedBadge {
                    AchievementCelebrationView(badge: badge) {
                        showingAchievementCelebration = false
                        celebratedBadge = nil
                    }
                }
            }
            .sheet(isPresented: $viewModel.showUpgradePrompt) {
                UpgradePromptView(
                    onUpgrade: {
                        // In a real app, this would navigate to subscription flow
                        print("Navigate to subscription upgrade")
                        viewModel.dismissUpgradePrompt()
                    },
                    onCancel: {
                        viewModel.dismissUpgradePrompt()
                    }
                )
            }
        }
        .onAppear {
            if viewModel.selectedChild != nil {
                viewModel.loadGoalsAndBadges()
            }
        }
    }
}

// MARK: - Preview

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView(viewModel: GoalTrackingViewModel(
            goalRepository: MockEducationalGoalRepository(),
            badgeRepository: MockAchievementBadgeRepository(),
            usageSessionRepository: MockUsageSessionRepository(),
            pointTransactionRepository: MockPointTransactionRepository(),
            childProfileRepository: MockChildProfileRepository()
        ))
    }
}