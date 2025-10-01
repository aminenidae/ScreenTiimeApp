import Foundation
import SwiftUI
import Combine
import SharedModels
import CloudKitService

@MainActor
class RewardRedemptionViewModel: ObservableObject {
    @Published var currentPoints: Int = 0
    @Published var rewardApps: [AppCategorization] = []
    @Published var selectedRewardApp: AppCategorization?
    @Published var conversionAmount: Int = 0
    @Published var selectedCategory: AppCategory?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var isProcessingRedemption: Bool = false
    @Published var showingRedemptionAlert: Bool = false
    @Published var redemptionMessage: String = ""
    @Published var redemptionSuccess: Bool = false

    private let childProfileRepository: ChildProfileRepository
    private let appCategorizationRepository: AppCategorizationRepository
    private let pointRedemptionService: PointRedemptionService
    private var cancellables = Set<AnyCancellable>()

    // For this demo, we'll use a mock child profile ID
    // In a real app, this would come from authentication/app state
    private let currentChildID = "mock-child-id"
    private let pointsPerMinute = 10 // 10 points = 1 minute conversion rate

    var filteredRewardApps: [AppCategorization] {
        var filtered = rewardApps

        // Filter by category
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        } else {
            // Only show reward apps
            filtered = filtered.filter { $0.category == .reward }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { categorization in
                let appName = categorization.appBundleID.components(separatedBy: ".").last ?? ""
                return appName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered.sorted { $0.pointsPerHour > $1.pointsPerHour }
    }

    var canRedeem: Bool {
        selectedRewardApp != nil && conversionAmount >= pointsPerMinute && conversionAmount <= currentPoints
    }

    init(childProfileRepository: ChildProfileRepository = CloudKitService.shared,
         appCategorizationRepository: AppCategorizationRepository = CloudKitService.shared,
         pointRedemptionService: PointRedemptionService = PointRedemptionService.shared) {
        self.childProfileRepository = childProfileRepository
        self.appCategorizationRepository = appCategorizationRepository
        self.pointRedemptionService = pointRedemptionService

        setupSubscriptions()
    }

    func loadRewardApps() async {
        isLoading = true

        do {
            async let childProfile = loadChildProfile()
            async let appCategorizations = loadAppCategorizations()

            let (profile, categorizations) = try await (childProfile, appCategorizations)

            if let profile = profile {
                currentPoints = profile.pointBalance
            }

            rewardApps = categorizations

        } catch {
            print("Failed to load reward apps: \(error)")
            redemptionMessage = "Failed to load reward apps: \(error.localizedDescription)"
            showingRedemptionAlert = true
        }

        isLoading = false
    }

    func selectRewardApp(_ app: AppCategorization) {
        selectedRewardApp = app
        // Start with a reasonable default amount (enough for 1 minute)
        if conversionAmount == 0 {
            conversionAmount = min(pointsPerMinute, currentPoints)
        }
    }

    func adjustConversionAmount(_ delta: Int) {
        let newAmount = conversionAmount + delta
        conversionAmount = max(pointsPerMinute, min(newAmount, currentPoints))
    }

    func redeemPoints() async {
        guard let selectedApp = selectedRewardApp,
              canRedeem else {
            return
        }

        isProcessingRedemption = true

        do {
            let timeMinutes = conversionAmount / pointsPerMinute
            let result = try await pointRedemptionService.redeemPointsForScreenTime(
                childID: currentChildID,
                appCategorizationID: selectedApp.id,
                pointsToSpend: conversionAmount,
                timeMinutes: timeMinutes
            )

            switch result {
            case .success:
                redemptionSuccess = true
                redemptionMessage = "Successfully redeemed \(conversionAmount) points for \(timeMinutes) minutes of screen time!"
                currentPoints -= conversionAmount
                conversionAmount = 0
                selectedRewardApp = nil

            case .insufficientPoints(let required, let available):
                redemptionSuccess = false
                redemptionMessage = "Insufficient points. Required: \(required), Available: \(available)"

            case .invalidApp:
                redemptionSuccess = false
                redemptionMessage = "The selected app is no longer available for redemption."

            case .systemError(let message):
                redemptionSuccess = false
                redemptionMessage = "System error: \(message)"
            }

        } catch {
            redemptionSuccess = false
            redemptionMessage = "Failed to redeem points: \(error.localizedDescription)"
        }

        isProcessingRedemption = false
        showingRedemptionAlert = true
    }

    // MARK: - Private Methods

    private func setupSubscriptions() {
        // Reset conversion amount when app selection changes
        $selectedRewardApp
            .sink { [weak self] app in
                if app == nil {
                    self?.conversionAmount = 0
                }
            }
            .store(in: &cancellables)
    }

    private func loadChildProfile() async throws -> ChildProfile? {
        return try await childProfileRepository.fetchChild(id: currentChildID)
    }

    private func loadAppCategorizations() async throws -> [AppCategorization] {
        return try await appCategorizationRepository.fetchAppCategorizations(for: currentChildID)
    }
}

// MARK: - Point Redemption Service

class PointRedemptionService {
    static let shared = PointRedemptionService()

    enum RedemptionResult {
        case success
        case insufficientPoints(required: Int, available: Int)
        case invalidApp
        case systemError(String)
    }

    private let childProfileRepository: ChildProfileRepository
    private let pointToTimeRedemptionRepository: PointToTimeRedemptionRepository
    private let pointTransactionRepository: PointTransactionRepository

    init(childProfileRepository: ChildProfileRepository = CloudKitService.shared,
         pointToTimeRedemptionRepository: PointToTimeRedemptionRepository = CloudKitService.shared,
         pointTransactionRepository: PointTransactionRepository = CloudKitService.shared) {
        self.childProfileRepository = childProfileRepository
        self.pointToTimeRedemptionRepository = pointToTimeRedemptionRepository
        self.pointTransactionRepository = pointTransactionRepository
    }

    func redeemPointsForScreenTime(
        childID: String,
        appCategorizationID: String,
        pointsToSpend: Int,
        timeMinutes: Int
    ) async throws -> RedemptionResult {
        // Validate child has enough points
        guard let childProfile = try await childProfileRepository.fetchChild(id: childID) else {
            return .systemError("Child profile not found")
        }

        if childProfile.pointBalance < pointsToSpend {
            return .insufficientPoints(required: pointsToSpend, available: childProfile.pointBalance)
        }

        // Create redemption record
        let redemption = PointToTimeRedemption(
            id: UUID().uuidString,
            childProfileID: childID,
            appCategorizationID: appCategorizationID,
            pointsSpent: pointsToSpend,
            timeGrantedMinutes: timeMinutes,
            conversionRate: Double(pointsToSpend) / Double(timeMinutes),
            redeemedAt: Date(),
            expiresAt: Date().addingTimeInterval(24 * 3600), // 24 hours
            timeUsedMinutes: 0,
            status: .active
        )

        // Save redemption
        let _ = try await pointToTimeRedemptionRepository.createPointToTimeRedemption(redemption)

        // Create transaction record
        let transaction = PointTransaction(
            id: UUID().uuidString,
            childProfileID: childID,
            points: -pointsToSpend,
            reason: "Redeemed for \(timeMinutes) minutes of screen time",
            timestamp: Date()
        )
        let _ = try await pointTransactionRepository.createTransaction(transaction)

        // Update child's point balance
        let updatedChild = ChildProfile(
            id: childProfile.id,
            familyID: childProfile.familyID,
            name: childProfile.name,
            avatarAssetURL: childProfile.avatarAssetURL,
            birthDate: childProfile.birthDate,
            pointBalance: childProfile.pointBalance - pointsToSpend,
            totalPointsEarned: childProfile.totalPointsEarned,
            deviceID: childProfile.deviceID,
            cloudKitZoneID: childProfile.cloudKitZoneID,
            createdAt: childProfile.createdAt,
            ageVerified: childProfile.ageVerified,
            verificationMethod: childProfile.verificationMethod,
            dataRetentionPeriod: childProfile.dataRetentionPeriod
        )
        let _ = try await childProfileRepository.updateChild(updatedChild)

        return .success
    }
}

// MARK: - Mock Data for Preview/Testing
extension RewardRedemptionViewModel {
    static func mockViewModel() -> RewardRedemptionViewModel {
        let viewModel = RewardRedemptionViewModel()
        viewModel.currentPoints = 450
        viewModel.rewardApps = [
            AppCategorization(
                id: "1",
                appBundleID: "com.supercell.clashofclans",
                category: .reward,
                childProfileID: "mock-child-id",
                pointsPerHour: 120
            ),
            AppCategorization(
                id: "2",
                appBundleID: "com.king.candycrushsaga",
                category: .reward,
                childProfileID: "mock-child-id",
                pointsPerHour: 100
            ),
            AppCategorization(
                id: "3",
                appBundleID: "com.roblox.robloxmobile",
                category: .reward,
                childProfileID: "mock-child-id",
                pointsPerHour: 90
            )
        ]
        return viewModel
    }
}