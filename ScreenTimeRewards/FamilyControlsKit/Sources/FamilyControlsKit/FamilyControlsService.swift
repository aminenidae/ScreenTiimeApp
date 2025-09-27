#if canImport(FamilyControls) && !os(macOS)
import Foundation
import FamilyControls
import ManagedSettings
import SharedModels

/// Service responsible for managing Family Controls and ManagedSettings for reward time allocation
@available(iOS 15.0, *)
public class FamilyControlsService: ObservableObject {
    public static let shared = FamilyControlsService()

    @Published public var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published public var isAuthorized: Bool = false

    private let store = ManagedSettingsStore()
    private let authorizationCenter = AuthorizationCenter.shared

    public init() {
        checkAuthorizationStatus()
        setupAuthorizationObserver()
    }

    // MARK: - Authorization

    /// Requests Family Controls authorization from the parent
    @available(iOS 16.0, *)
    public func requestAuthorization() async throws {
        try await authorizationCenter.requestAuthorization(for: .child)
        await MainActor.run {
            checkAuthorizationStatus()
        }
    }

    /// Checks current authorization status
    private func checkAuthorizationStatus() {
        authorizationStatus = authorizationCenter.authorizationStatus
        isAuthorized = authorizationStatus == .approved
    }

    private func setupAuthorizationObserver() {
        // Note: AuthorizationStatus.values is available in iOS 16.0+
        // For iOS 15.0 compatibility, we'll use a simpler approach
        if #available(iOS 16.0, *) {
            Task {
                for await authStatus in authorizationCenter.$authorizationStatus.values {
                    await MainActor.run {
                        self.authorizationStatus = authStatus
                        self.isAuthorized = authStatus == .approved
                    }
                }
            }
        } else {
            // For iOS 15.0, we'll check status periodically or on app foreground
            // This is a simplified implementation for compatibility
            checkAuthorizationStatus()
        }
    }

    // MARK: - Reward Time Allocation

    /// Allocates reward screen time for a specific app based on a redemption
    public func allocateRewardTime(
        for redemption: PointToTimeRedemption,
        appBundleID: String
    ) async throws -> RewardTimeAllocationResult {
        guard isAuthorized else {
            return .authorizationRequired
        }

        // Validate redemption is active and not expired
        guard redemption.status == .active,
              redemption.expiresAt > Date() else {
            return .redemptionExpired
        }

        // Calculate remaining time
        let remainingMinutes = redemption.timeGrantedMinutes - redemption.timeUsedMinutes
        guard remainingMinutes > 0 else {
            return .noTimeRemaining
        }

        do {
            // Create application token for the specific app
            let appToken = try await createApplicationToken(bundleID: appBundleID)

            // Apply managed settings for reward time
            try await applyRewardTimeSettings(
                appToken: appToken,
                timeMinutes: remainingMinutes,
                redemptionID: redemption.id
            )

            return .success(allocatedMinutes: remainingMinutes)

        } catch {
            return .systemError(error.localizedDescription)
        }
    }

    /// Revokes reward time allocation for a specific redemption
    public func revokeRewardTime(redemptionID: String, appBundleID: String) async throws -> RewardTimeAllocationResult {
        guard isAuthorized else {
            return .authorizationRequired
        }

        do {
            // Remove managed settings for this specific redemption
            try await removeRewardTimeSettings(redemptionID: redemptionID, appBundleID: appBundleID)
            return .success(allocatedMinutes: 0)

        } catch {
            return .systemError(error.localizedDescription)
        }
    }

    /// Updates time usage for a redemption (called when time is actually used)
    public func updateTimeUsage(
        redemptionID: String,
        appBundleID: String,
        usedMinutes: Int
    ) async throws -> RewardTimeAllocationResult {
        guard isAuthorized else {
            return .authorizationRequired
        }

        // In a real implementation, this would track actual usage and update ManagedSettings accordingly
        // For now, we'll simulate the update
        return .success(allocatedMinutes: usedMinutes)
    }

    /// Gets all active reward time allocations for a child
    public func getActiveRewardAllocations(for childID: String) async throws -> [RewardTimeAllocation] {
        guard isAuthorized else {
            throw FamilyControlsError.authorizationRequired
        }

        // In a real implementation, this would query the actual ManagedSettings store
        // For now, return empty array as this is primarily handled by the PointRedemptionService
        return []
    }

    // MARK: - Private Methods

    private func createApplicationToken(bundleID: String) async throws -> ApplicationToken {
        // In a real implementation, this would use the Family Controls framework
        // to create an application token for the specific bundle ID
        // For now, we'll simulate this functionality

        #if targetEnvironment(simulator)
        // Simulator doesn't support Family Controls, return a mock token
        throw FamilyControlsError.simulatorNotSupported
        #else
        // On device, this would use the actual Family Controls API
        // This is a placeholder implementation
        throw FamilyControlsError.notImplemented("ApplicationToken creation not implemented in demo")
        #endif
    }

    private func applyRewardTimeSettings(
        appToken: ApplicationToken,
        timeMinutes: Int,
        redemptionID: String
    ) async throws {
        // In a real implementation, this would:
        // 1. Configure ManagedSettingsStore with specific time allowances
        // 2. Set up application restrictions that expire after the allocated time
        // 3. Store metadata linking the settings to the redemption ID

        #if targetEnvironment(simulator)
        // Simulator implementation - log the operation
        print("SIMULATOR: Would allocate \(timeMinutes) minutes for redemption \(redemptionID)")
        #else
        // Device implementation would use actual ManagedSettings APIs
        let settings = store

        // Example of how this might work with real Family Controls:
        // let timeLimit = TimeInterval(timeMinutes * 60)
        // settings.application.blockedApplications = Set([appToken])
        // settings.dateAndTime.bedtime = DateComponents(hour: 22, minute: 0) // Example

        throw FamilyControlsError.notImplemented("ManagedSettings configuration not implemented in demo")
        #endif
    }

    private func removeRewardTimeSettings(redemptionID: String, appBundleID: String) async throws {
        // In a real implementation, this would:
        // 1. Remove or modify ManagedSettingsStore entries for this redemption
        // 2. Clear application restrictions
        // 3. Clean up metadata

        #if targetEnvironment(simulator)
        print("SIMULATOR: Would remove reward time settings for redemption \(redemptionID)")
        #else
        // Device implementation would use actual ManagedSettings APIs
        throw FamilyControlsError.notImplemented("ManagedSettings removal not implemented in demo")
        #endif
    }
}

// MARK: - Result Types

public enum RewardTimeAllocationResult {
    case success(allocatedMinutes: Int)
    case authorizationRequired
    case redemptionExpired
    case noTimeRemaining
    case systemError(String)
}

public struct RewardTimeAllocation {
    public let redemptionID: String
    public let appBundleID: String
    public let allocatedMinutes: Int
    public let usedMinutes: Int
    public let expiresAt: Date
    public let isActive: Bool

    public init(redemptionID: String, appBundleID: String, allocatedMinutes: Int, usedMinutes: Int, expiresAt: Date, isActive: Bool) {
        self.redemptionID = redemptionID
        self.appBundleID = appBundleID
        self.allocatedMinutes = allocatedMinutes
        self.usedMinutes = usedMinutes
        self.expiresAt = expiresAt
        self.isActive = isActive
    }
}

// MARK: - Error Types

public enum FamilyControlsError: Error, LocalizedError {
    case authorizationRequired
    case simulatorNotSupported
    case notImplemented(String)
    case invalidRedemption
    case managedSettingsError(String)

    public var errorDescription: String? {
        switch self {
        case .authorizationRequired:
            return "Family Controls authorization is required"
        case .simulatorNotSupported:
            return "Family Controls is not supported in the simulator"
        case .notImplemented(let message):
            return "Feature not implemented: \(message)"
        case .invalidRedemption:
            return "Invalid or expired redemption"
        case .managedSettingsError(let message):
            return "Managed Settings error: \(message)"
        }
    }
}

// MARK: - Extension for PointToTimeRedemption Integration

extension FamilyControlsService {
    /// Convenience method to allocate reward time from a PointToTimeRedemption
    public func allocateRewardTime(
        for redemption: PointToTimeRedemption,
        using appCategorization: AppCategorization
    ) async throws -> RewardTimeAllocationResult {
        return try await allocateRewardTime(
            for: redemption,
            appBundleID: appCategorization.appBundleID
        )
    }

    /// Validates that Family Controls can handle the requested time allocation
    public func validateTimeAllocation(timeMinutes: Int) -> Bool {
        // Basic validation - in a real app this might check:
        // - Parent-set daily limits
        // - Current active restrictions
        // - System limitations
        return timeMinutes > 0 && timeMinutes <= 240 // Max 4 hours per redemption
    }
}

// MARK: - Result Extension

extension RewardTimeAllocationResult {
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    public var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .authorizationRequired:
            return "Parent authorization is required to manage screen time"
        case .redemptionExpired:
            return "This redemption has expired"
        case .noTimeRemaining:
            return "No time remaining in this redemption"
        case .systemError(let message):
            return "System error: \(message)"
        }
    }
}

#endif