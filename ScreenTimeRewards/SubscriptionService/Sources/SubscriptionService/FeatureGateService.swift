import Foundation
import SharedModels

/// Service responsible for controlling access to premium features based on subscription and trial status
@available(iOS 15.0, macOS 12.0, *)
@MainActor
public final class FeatureGateService: ObservableObject {
    @Published public private(set) var hasAccess = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: AppError?

    private let familyRepository: FamilyRepository
    private let trialService: TrialEligibilityService

    public init(familyRepository: FamilyRepository) {
        self.familyRepository = familyRepository
        self.trialService = TrialEligibilityService(familyRepository: familyRepository)
    }

    /// Check if a family has access to premium features
    /// - Parameter familyID: The family ID to check access for
    /// - Returns: True if family has access (active subscription or trial)
    public func checkAccess(for familyID: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        defer {
            Task { @MainActor in
                isLoading = false
            }
        }

        do {
            guard let family = try await familyRepository.fetchFamily(id: familyID) else {
                await updateAccessStatus(false, error: .familyAccessDenied)
                return false
            }

            // Check for active subscription first
            if let metadata = family.subscriptionMetadata,
               metadata.isActive,
               let subscriptionEndDate = metadata.subscriptionEndDate,
               subscriptionEndDate > Date() {
                await updateAccessStatus(true)
                return true
            }

            // Check for active trial
            let trialStatus = await trialService.getTrialStatus(for: familyID)
            switch trialStatus {
            case .active:
                await updateAccessStatus(true)
                return true
            case .notStarted, .expired:
                await updateAccessStatus(false)
                return false
            }

        } catch {
            let appError = error as? AppError ?? .unknownError(error.localizedDescription)
            await updateAccessStatus(false, error: appError)
            return false
        }
    }

    /// Check access for specific premium features
    public func hasFeatureAccess(_ feature: PremiumFeature, for familyID: String) async -> Bool {
        let hasBasicAccess = await checkAccess(for: familyID)

        switch feature {
        case .unlimitedFamilyMembers:
            return hasBasicAccess
        case .advancedAnalytics:
            return hasBasicAccess
        case .smartNotifications:
            return hasBasicAccess
        case .enhancedParentalControls:
            return hasBasicAccess
        case .cloudSync:
            return hasBasicAccess
        case .prioritySupport:
            return hasBasicAccess
        }
    }

    /// Refresh access status for a family
    public func refreshAccess(for familyID: String) async {
        _ = await checkAccess(for: familyID)
    }

    /// Get feature access status for multiple features
    public func getFeatureAccessStatus(for familyID: String) async -> FeatureAccessStatus {
        let hasAccess = await checkAccess(for: familyID)

        if !hasAccess {
            return FeatureAccessStatus(
                unlimitedFamilyMembers: false,
                advancedAnalytics: false,
                smartNotifications: false,
                enhancedParentalControls: false,
                cloudSync: false,
                prioritySupport: false
            )
        }

        return FeatureAccessStatus(
            unlimitedFamilyMembers: true,
            advancedAnalytics: true,
            smartNotifications: true,
            enhancedParentalControls: true,
            cloudSync: true,
            prioritySupport: true
        )
    }

    /// Get user-friendly access status message
    public func getAccessStatusMessage(for familyID: String) async -> String {
        do {
            guard let family = try await familyRepository.fetchFamily(id: familyID) else {
                return "Family not found"
            }

            // Check subscription status
            if let metadata = family.subscriptionMetadata,
               metadata.isActive,
               let subscriptionEndDate = metadata.subscriptionEndDate,
               subscriptionEndDate > Date() {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Premium subscription active until \(formatter.string(from: subscriptionEndDate))"
            }

            // Check trial status
            let trialStatus = await trialService.getTrialStatus(for: familyID)
            switch trialStatus {
            case .active(let daysRemaining):
                return "Free trial active - \(daysRemaining) days remaining"
            case .expired:
                return "Free trial expired - Subscribe to continue using premium features"
            case .notStarted:
                return "Start your free trial to access premium features"
            }

        } catch {
            return "Unable to determine access status"
        }
    }

    // MARK: - Private Methods

    private func updateAccessStatus(_ hasAccess: Bool, error: AppError? = nil) async {
        await MainActor.run {
            self.hasAccess = hasAccess
            self.error = error
        }
    }
}

// MARK: - Supporting Types

public enum PremiumFeature {
    case unlimitedFamilyMembers
    case advancedAnalytics
    case smartNotifications
    case enhancedParentalControls
    case cloudSync
    case prioritySupport
}

public struct FeatureAccessStatus {
    public let unlimitedFamilyMembers: Bool
    public let advancedAnalytics: Bool
    public let smartNotifications: Bool
    public let enhancedParentalControls: Bool
    public let cloudSync: Bool
    public let prioritySupport: Bool

    public init(
        unlimitedFamilyMembers: Bool,
        advancedAnalytics: Bool,
        smartNotifications: Bool,
        enhancedParentalControls: Bool,
        cloudSync: Bool,
        prioritySupport: Bool
    ) {
        self.unlimitedFamilyMembers = unlimitedFamilyMembers
        self.advancedAnalytics = advancedAnalytics
        self.smartNotifications = smartNotifications
        self.enhancedParentalControls = enhancedParentalControls
        self.cloudSync = cloudSync
        self.prioritySupport = prioritySupport
    }
}

/// Convenience extension for quick feature checks
@available(iOS 15.0, macOS 12.0, *)
public extension FeatureGateService {
    /// Check if family can add more members (premium feature)
    func canAddFamilyMember(for familyID: String, currentMemberCount: Int) async -> Bool {
        // Free tier allows up to 2 family members
        if currentMemberCount < 2 {
            return true
        }

        // Premium required for unlimited members
        return await hasFeatureAccess(.unlimitedFamilyMembers, for: familyID)
    }

    /// Check if family can access detailed analytics
    func canAccessAnalytics(for familyID: String) async -> Bool {
        return await hasFeatureAccess(.advancedAnalytics, for: familyID)
    }

    /// Check if family can use enhanced controls
    func canUseEnhancedControls(for familyID: String) async -> Bool {
        return await hasFeatureAccess(.enhancedParentalControls, for: familyID)
    }
}