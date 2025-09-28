import Foundation
import Combine
import SharedModels

// MARK: - Goal Tracking View Model

@MainActor
public class GoalTrackingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var goals: [EducationalGoal] = []
    @Published public var badges: [AchievementBadge] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var selectedChild: ChildProfile?
    @Published public var hasActiveSubscription = false
    @Published public var showUpgradePrompt = false
    
    // MARK: - Private Properties
    
    private let goalRepository: EducationalGoalRepository
    private let badgeRepository: AchievementBadgeRepository
    private let usageSessionRepository: UsageSessionRepository
    private let pointTransactionRepository: PointTransactionRepository
    private let childProfileRepository: ChildProfileRepository
    private let subscriptionRepository: SubscriptionEntitlementRepository?
    private let goalTrackingService: GoalTrackingServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        goalRepository: EducationalGoalRepository,
        badgeRepository: AchievementBadgeRepository,
        usageSessionRepository: UsageSessionRepository,
        pointTransactionRepository: PointTransactionRepository,
        childProfileRepository: ChildProfileRepository,
        subscriptionRepository: SubscriptionEntitlementRepository? = nil,
        goalTrackingService: GoalTrackingServiceProtocol = GoalTrackingService(),
        notificationService: NotificationServiceProtocol = NotificationService()
    ) {
        self.goalRepository = goalRepository
        self.badgeRepository = badgeRepository
        self.usageSessionRepository = usageSessionRepository
        self.pointTransactionRepository = pointTransactionRepository
        self.childProfileRepository = childProfileRepository
        self.subscriptionRepository = subscriptionRepository
        self.goalTrackingService = goalTrackingService
        self.notificationService = notificationService
    }
    
    // MARK: - Public Methods
    
    public func loadGoalsAndBadges() {
        guard let selectedChild = selectedChild else {
            errorMessage = "No child profile selected"
            return
        }
        
        Task {
            await loadGoalsAndBadges(for: selectedChild)
        }
    }
    
    public func selectChild(_ child: ChildProfile) {
        selectedChild = child
        loadGoalsAndBadges()
    }
    
    public func refreshData() {
        loadGoalsAndBadges()
    }
    
    public func createGoal(_ goal: EducationalGoal) async throws {
        try await goalRepository.save(goal)
        await loadGoalsAndBadges()
    }
    
    public func updateGoal(_ goal: EducationalGoal) async throws {
        try await goalRepository.save(goal)
        await loadGoalsAndBadges()
    }
    
    public func deleteGoal(_ goal: EducationalGoal) async throws {
        try await goalRepository.delete(goal.id)
        await loadGoalsAndBadges()
    }
    
    public func requestPremiumFeature() {
        if !hasActiveSubscription {
            showUpgradePrompt = true
        }
    }
    
    public func dismissUpgradePrompt() {
        showUpgradePrompt = false
    }
    
    // MARK: - Private Methods
    
    private func loadGoalsAndBadges(for child: ChildProfile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check subscription status for premium features
            let hasAdvancedFeatures = await checkAdvancedFeaturesAccess(for: child.familyID)
            await MainActor.run {
                self.hasActiveSubscription = hasAdvancedFeatures
            }
            
            // Fetch goals and badges
            async let fetchedGoals = fetchGoals(for: child.id)
            async let fetchedBadges = fetchBadges(for: child.id)
            
            let (goals, badges) = try await (fetchedGoals, fetchedBadges)
            
            // Update goals with current progress
            let updatedGoals = await updateGoalsWithProgress(goals, for: child)
            
            await MainActor.run {
                self.goals = updatedGoals
                self.badges = badges
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load goals and badges: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func fetchGoals(for childID: String) async throws -> [EducationalGoal] {
        // For basic users, limit to 3 active goals
        let allGoals = try await goalRepository.fetchGoals(for: childID)
        
        if hasActiveSubscription {
            return allGoals
        } else {
            // Filter to only 3 active goals for basic users
            let activeGoals = allGoals.filter { goal in
                if case .completed = goal.status {
                    return false
                }
                if case .failed = goal.status {
                    return false
                }
                return true
            }
            
            return Array(activeGoals.prefix(3))
        }
    }
    
    private func fetchBadges(for childID: String) async throws -> [AchievementBadge] {
        return try await badgeRepository.fetchBadges(for: childID)
    }
    
    private func updateGoalsWithProgress(_ goals: [EducationalGoal], for child: ChildProfile) async -> [EducationalGoal] {
        // Fetch usage data for progress calculation
        do {
            async let sessions = usageSessionRepository.fetchSessions(for: child.id, dateRange: DateRange(start: Date.distantPast, end: Date()))
            async let transactions = pointTransactionRepository.fetchTransactions(for: child.id, dateRange: DateRange(start: Date.distantPast, end: Date()))
            
            let (usageSessions, pointTransactions) = try await (sessions, transactions)
            
            var updatedGoals: [EducationalGoal] = []
            
            for goal in goals {
                let progress = goalTrackingService.calculateGoalProgress(
                    goal: goal,
                    sessions: usageSessions,
                    transactions: pointTransactions
                )
                
                let updatedStatus = goalTrackingService.updateGoalStatus(goal: goal, progress: progress)
                
                var updatedGoal = goal
                updatedGoal.currentValue = progress * goal.targetValue
                
                // Only update status if it has changed
                if updatedGoal.status != updatedStatus {
                    updatedGoal.status = updatedStatus
                    
                    // If goal was just completed, schedule notification
                    if case .completed = updatedStatus {
                        updatedGoal.metadata.completedAt = Date()
                        try? await notificationService.scheduleGoalCompletionNotification(for: updatedGoal)
                    }
                }
                
                updatedGoals.append(updatedGoal)
            }
            
            return updatedGoals
            
        } catch {
            print("Error updating goals with progress: \(error)")
            return goals
        }
    }
    
    private func checkAdvancedFeaturesAccess(for familyID: String) async -> Bool {
        guard let subscriptionRepository = subscriptionRepository else {
            return false // No subscription service means basic features only
        }
        
        do {
            let entitlements = try await subscriptionRepository.fetchEntitlements(for: familyID)
            return entitlements.contains { $0.isActive }
        } catch {
            return false // Error accessing subscription = basic features only
        }
    }
}