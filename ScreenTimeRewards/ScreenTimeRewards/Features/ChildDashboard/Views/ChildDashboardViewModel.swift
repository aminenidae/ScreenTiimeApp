import Foundation
import SwiftUI
import Combine
import SharedModels
import CloudKitService
import RewardCore
import OSLog

@MainActor
class ChildDashboardViewModel: ObservableObject {
    @Published var currentPoints: Int = 0
    @Published var totalPointsEarned: Int = 0
    @Published var recentTransactions: [PointTransaction] = []
    @Published var recentSessions: [ScreenTimeSession] = []
    @Published var pointsAnimationScale: CGFloat = 1.0
    @Published var isLoading: Bool = false

    // Enhanced error handling properties
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var currentError: AppError?
    @Published var canRetry: Bool = false

    @Published var dailyGoal: Int = 100
    @Published var availableRewards: [Reward] = []
    @Published var floatingPointsNotification: Int = 0
    @Published var showFloatingNotification: Bool = false

    private let childProfileRepository: ChildProfileRepository
    private let pointTransactionRepository: PointTransactionRepository
    private let usageSessionRepository: UsageSessionRepository
    private let errorHandler = ErrorHandlingService.shared
    private let logger = Logger(subsystem: "com.screentime.rewards", category: "child-dashboard")
    private var cancellables = Set<AnyCancellable>()

    // For this demo, we'll use a mock child profile ID
    // In a real app, this would come from authentication/app state
    private let currentChildID = "mock-child-id"

    init(childProfileRepository: ChildProfileRepository = CloudKitService.shared,
         pointTransactionRepository: PointTransactionRepository = CloudKitService.shared,
         usageSessionRepository: UsageSessionRepository = CloudKitService.shared) {
        self.childProfileRepository = childProfileRepository
        self.pointTransactionRepository = pointTransactionRepository
        self.usageSessionRepository = usageSessionRepository
        setupErrorHandling()
    }

    // MARK: - Error Handling Setup

    private func setupErrorHandling() {
        // Clear errors when starting new operations
        Publishers.CombineLatest($isLoading, $showError)
            .filter { isLoading, _ in isLoading }
            .sink { [weak self] _, _ in
                self?.clearError()
            }
            .store(in: &cancellables)
    }

    func loadInitialData() async {
        isLoading = true
        clearError()

        do {
            logger.info("Loading dashboard data for child: \(self.currentChildID)")

            async let childProfile = loadChildProfile()
            async let transactions = loadRecentTransactions()
            async let sessions = loadRecentSessions()
            async let rewards = loadAvailableRewards()

            let (profile, transactionList, sessionList, rewardList) = try await (childProfile, transactions, sessions, rewards)

            if let profile = profile {
                currentPoints = profile.pointBalance
                totalPointsEarned = profile.totalPointsEarned
                logger.debug("Loaded child profile with \(profile.pointBalance) points")
            }

            recentTransactions = transactionList
            recentSessions = sessionList
            availableRewards = rewardList

            logger.info("Successfully loaded dashboard data")

        } catch {
            handleError(error, context: "loadInitialData")
        }

        isLoading = false
    }

    func refreshData() async {
        await loadInitialData()
    }

    func animatePointsEarned(points: Int) {
        // Show floating notification
        floatingPointsNotification = points
        showFloatingNotification = true
        
        // Animate points display
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            pointsAnimationScale = 1.2
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.pointsAnimationScale = 1.0
            }
        }
    }

    func redeemReward(_ reward: Reward) async {
        // Validate points before attempting redemption
        guard currentPoints >= reward.pointCost else {
            handleError(AppError.insufficientPoints, context: "redeemReward")
            return
        }

        do {
            logger.info("Redeeming reward: \(reward.name) for \(reward.pointCost) points")

            // In a real implementation, this would call the PointRedemptionService
            // For now, we'll simulate the redemption with proper error handling
            currentPoints -= reward.pointCost

            // Animate the point deduction
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                pointsAnimationScale = 0.8
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.pointsAnimationScale = 1.0
                }
            }

            logger.info("Successfully redeemed reward: \(reward.name)")

        } catch {
            handleError(error, context: "redeemReward")
            // Reset points if redemption failed
            currentPoints += reward.pointCost
        }
    }

    // MARK: - Error Handling Methods

    /// Handle an error by converting it to AppError and updating UI state
    private func handleError(_ error: Error, context: String) {
        let appError = errorHandler.convertToAppError(error)
        errorHandler.processError(appError, context: context)

        currentError = appError
        errorMessage = appError.localizedDescription
        showError = true
        canRetry = shouldAllowRetry(appError)

        logger.error("Error in \(context): \(appError.localizedDescription)")
    }

    /// Clear current error state
    func clearError() {
        currentError = nil
        errorMessage = nil
        showError = false
        canRetry = false
    }

    /// Retry the last failed operation
    func retryLastOperation() async {
        guard canRetry else { return }

        clearError()

        // Try to recover from the error if possible
        if let error = currentError,
           await errorHandler.attemptRecovery(from: error) {
            logger.info("Successfully recovered from error, retrying operation")
            await refreshData()
        } else {
            // If recovery failed, just retry the data load
            await refreshData()
        }
    }

    /// Determine if retry should be allowed for an error
    private func shouldAllowRetry(_ error: AppError) -> Bool {
        switch error {
        case .networkUnavailable, .networkTimeout, .cloudKitNotAvailable:
            return true
        case .cloudKitSaveError, .cloudKitFetchError:
            return true
        case .systemError:
            return true
        default:
            return false
        }
    }

    // MARK: - Private Methods

    private func loadChildProfile() async throws -> ChildProfile? {
        return try await childProfileRepository.fetchChild(id: currentChildID)
    }

    private func loadRecentTransactions() async throws -> [PointTransaction] {
        return try await pointTransactionRepository.fetchTransactions(for: currentChildID, limit: 10)
    }

    private func loadRecentSessions() async throws -> [ScreenTimeSession] {
        // For now, return empty since UsageSessionRepository doesn't handle ScreenTimeSession
        // This would need to be extended in the actual implementation
        return []
    }
    
    private func loadAvailableRewards() async throws -> [Reward] {
        // In a real implementation, this would fetch rewards from a repository
        // For now, we'll return mock rewards
        return [
            Reward(id: "1", name: "Game Time", description: "30 minutes of game time", pointCost: 50, imageURL: nil, isActive: true, createdAt: Date()),
            Reward(id: "2", name: "Extra Video", description: "Watch one extra video", pointCost: 30, imageURL: nil, isActive: true, createdAt: Date()),
            Reward(id: "3", name: "Music Time", description: "30 minutes of music apps", pointCost: 40, imageURL: nil, isActive: true, createdAt: Date()),
            Reward(id: "4", name: "Social Time", description: "15 minutes of social apps", pointCost: 75, imageURL: nil, isActive: true, createdAt: Date())
        ]
    }
}

// MARK: - Mock Data for Preview/Testing
extension ChildDashboardViewModel {
    static func mockViewModel() -> ChildDashboardViewModel {
        let viewModel = ChildDashboardViewModel()
        viewModel.currentPoints = 450
        viewModel.totalPointsEarned = 1250
        viewModel.recentTransactions = [
            PointTransaction(
                id: "1",
                childProfileID: "mock-child-id",
                points: 30,
                reason: "Math App - 30 minutes",
                timestamp: Date().addingTimeInterval(-3600)
            ),
            PointTransaction(
                id: "2",
                childProfileID: "mock-child-id",
                points: 45,
                reason: "Reading App - 45 minutes",
                timestamp: Date().addingTimeInterval(-7200)
            ),
            PointTransaction(
                id: "3",
                childProfileID: "mock-child-id",
                points: -100,
                reason: "Redeemed for Game Time",
                timestamp: Date().addingTimeInterval(-10800)
            )
        ]
        viewModel.recentSessions = [
            ScreenTimeSession(
                id: "1",
                childProfileID: "mock-child-id",
                appBundleID: "com.khanacademy.khanacademykids",
                category: .learning,
                startTime: Date().addingTimeInterval(-3600),
                endTime: Date().addingTimeInterval(-1800),
                duration: 1800,
                pointsEarned: 30
            ),
            ScreenTimeSession(
                id: "2",
                childProfileID: "mock-child-id",
                appBundleID: "com.epic.kidsteacher",
                category: .learning,
                startTime: Date().addingTimeInterval(-7200),
                endTime: Date().addingTimeInterval(-4500),
                duration: 2700,
                pointsEarned: 45
            )
        ]
        viewModel.availableRewards = [
            Reward(id: "1", name: "Game Time", description: "30 minutes of game time", pointCost: 50, imageURL: nil, isActive: true, createdAt: Date()),
            Reward(id: "2", name: "Extra Video", description: "Watch one extra video", pointCost: 30, imageURL: nil, isActive: true, createdAt: Date()),
            Reward(id: "3", name: "Music Time", description: "30 minutes of music apps", pointCost: 40, imageURL: nil, isActive: true, createdAt: Date()),
            Reward(id: "4", name: "Social Time", description: "15 minutes of social apps", pointCost: 75, imageURL: nil, isActive: true, createdAt: Date())
        ]
        return viewModel
    }
}