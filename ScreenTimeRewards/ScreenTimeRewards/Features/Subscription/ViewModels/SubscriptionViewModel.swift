import Foundation
import SwiftUI
import StoreKit
import SharedModels
import SubscriptionService
import RewardCore

@MainActor
final class SubscriptionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var availableProducts: [SubscriptionProduct] = []
    @Published var isLoading: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var error: AppError?
    @Published var purchaseSuccess: Bool = false
    @Published var showingSuccessView: Bool = false

    // MARK: - Private Properties
    private let subscriptionService: SubscriptionService
    private let analyticsService: AnalyticsService?

    // MARK: - Initialization
    init(subscriptionService: SubscriptionService = SubscriptionService(),
         analyticsService: AnalyticsService? = nil) {
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService

        // Track paywall impression
        Task {
            await trackPaywallImpression()
        }
    }

    // MARK: - Public Methods

    /// Fetch available subscription products
    func fetchProducts() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        do {
            await subscriptionService.fetchProducts()

            await MainActor.run {
                availableProducts = subscriptionService.availableProducts
                isLoading = false
            }
        } catch {
            await handleProductFetchError(error)
        }
    }

    /// Handle product fetch errors with retry logic
    private func handleProductFetchError(_ error: Error) async {
        let appError = error as? AppError ?? AppError.unknownError(error.localizedDescription)

        // Track error for analytics
        await analyticsService?.trackError(category: "subscription", code: "product_fetch_failed")

        await MainActor.run {
            self.error = appError
            isLoading = false
        }

        // For network errors, provide automatic retry capability
        if case .networkError = appError {
            await scheduleProductFetchRetry()
        }
    }

    /// Schedule automatic retry for product fetching in case of network errors
    private func scheduleProductFetchRetry() async {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            // Only retry if there's still a network error and no new fetch in progress
            if case .networkError = error, !isLoading {
                await fetchProducts()
            }
        }
    }

    /// Start purchase process for selected product
    func startPurchase(for productId: String) async {
        guard !isPurchasing else { return }

        await MainActor.run {
            isPurchasing = true
            error = nil
        }

        do {
            // Track purchase attempt
            await trackPurchaseAttempt(productId: productId)

            let result = try await subscriptionService.purchase(productId)
            await handlePurchaseResult(result, productId: productId)

        } catch {
            await MainActor.run {
                self.error = error as? AppError ?? AppError.purchaseFailed(error.localizedDescription)
                isPurchasing = false
            }

            // Track purchase failure
            await trackPurchaseFailure(productId: productId, error: error)
        }
    }

    /// Restore previous purchases
    func restorePurchases() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        do {
            try await subscriptionService.restorePurchases()

            // Check for current entitlements
            await checkCurrentEntitlements()

            await MainActor.run {
                isLoading = false
            }

            // Track restore attempt
            await trackRestorePurchases()

        } catch {
            await MainActor.run {
                self.error = error as? AppError ?? AppError.unknownError(error.localizedDescription)
                isLoading = false
            }
        }
    }

    /// Clear current error state
    func clearError() {
        error = nil
    }

    /// Dismiss success view
    func dismissSuccessView() {
        showingSuccessView = false
        purchaseSuccess = false
    }

    // MARK: - Private Methods

    /// Handle purchase result from StoreKit
    private func handlePurchaseResult(_ result: Product.PurchaseResult, productId: String) async {
        switch result {
        case .success(let verification):
            await handleSuccessfulPurchase(verification, productId: productId)

        case .userCancelled:
            await MainActor.run {
                isPurchasing = false
            }
            await trackPurchaseCancellation(productId: productId)

        case .pending:
            await MainActor.run {
                isPurchasing = false
                error = AppError.operationNotAllowed("Purchase is pending approval")
            }
            await trackPurchasePending(productId: productId)

        @unknown default:
            await MainActor.run {
                isPurchasing = false
                error = AppError.unknownError("Unknown purchase result")
            }
        }
    }

    /// Handle successful purchase verification
    private func handleSuccessfulPurchase(_ verification: VerificationResult<Transaction>, productId: String) async {
        switch verification {
        case .verified(let transaction):
            // Process successful transaction
            await processSuccessfulTransaction(transaction, productId: productId)

        case .unverified(let transaction, let error):
            await MainActor.run {
                isPurchasing = false
                self.error = AppError.systemError("Transaction verification failed: \(error)")
            }

            // Still finish the transaction to avoid issues
            await transaction.finish()

            await trackPurchaseVerificationFailure(productId: productId, error: error)
        }
    }

    /// Process verified successful transaction
    private func processSuccessfulTransaction(_ transaction: Transaction, productId: String) async {
        // Finish the transaction
        await transaction.finish()

        await MainActor.run {
            isPurchasing = false
            purchaseSuccess = true
            showingSuccessView = true
        }

        // Track successful purchase
        await trackPurchaseSuccess(productId: productId, transaction: transaction)

        // Update subscription entitlements
        await updateSubscriptionEntitlements()
    }

    /// Check current subscription entitlements
    private func checkCurrentEntitlements() async {
        for await verification in Transaction.currentEntitlements {
            switch verification {
            case .verified(let transaction):
                // Process current entitlement
                print("Active subscription: \(transaction.productID)")

            case .unverified(_, let error):
                print("Unverified entitlement: \(error)")
            }
        }
    }

    /// Update subscription entitlements after successful purchase
    private func updateSubscriptionEntitlements() async {
        do {
            try await subscriptionService.updateEntitlements()
        } catch {
            // Log error but don't fail the purchase flow - entitlements will be updated on next app launch
            await analyticsService?.trackError(category: "subscription", code: "entitlement_update_failed")
            print("Warning: Failed to update entitlements immediately: \(error.localizedDescription)")

            // Schedule retry in background
            await scheduleEntitlementRetry()
        }
    }

    /// Schedule a background retry for entitlement updates
    private func scheduleEntitlementRetry() async {
        // In a production app, this would use BackgroundTasks framework
        // For now, we'll schedule a delayed retry
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            do {
                try await subscriptionService.updateEntitlements()
            } catch {
                print("Entitlement retry failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Analytics Methods

    /// Track paywall impression
    private func trackPaywallImpression() async {
        await analyticsService?.trackFeatureUsage(
            feature: "paywall_impression",
            metadata: [
                "source": "subscription_paywall",
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }

    /// Track purchase attempt
    private func trackPurchaseAttempt(productId: String) async {
        await analyticsService?.trackFeatureUsage(
            feature: "purchase_attempted",
            metadata: [
                "product_id": productId,
                "source": "paywall",
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }

    /// Track successful purchase
    private func trackPurchaseSuccess(productId: String, transaction: Transaction) async {
        await analyticsService?.trackFeatureUsage(
            feature: "purchase_completed",
            metadata: [
                "product_id": productId,
                "transaction_id": String(transaction.id),
                "purchase_date": "\(transaction.purchaseDate.timeIntervalSince1970)",
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }

    /// Track purchase failure
    private func trackPurchaseFailure(productId: String, error: Error) async {
        await analyticsService?.trackError(
            category: "purchase",
            code: "purchase_failed"
        )

        await analyticsService?.trackFeatureUsage(
            feature: "purchase_failed",
            metadata: [
                "product_id": productId,
                "error_description": error.localizedDescription,
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }

    /// Track purchase cancellation
    private func trackPurchaseCancellation(productId: String) async {
        await analyticsService?.trackFeatureUsage(
            feature: "purchase_cancelled",
            metadata: [
                "product_id": productId,
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }

    /// Track purchase pending
    private func trackPurchasePending(productId: String) async {
        await analyticsService?.trackFeatureUsage(
            feature: "purchase_pending",
            metadata: [
                "product_id": productId,
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }

    /// Track verification failure
    private func trackPurchaseVerificationFailure(productId: String, error: VerificationResult<Transaction>.VerificationError) async {
        await analyticsService?.trackError(
            category: "purchase",
            code: "verification_failed"
        )

        await analyticsService?.trackFeatureUsage(
            feature: "purchase_verification_failed",
            metadata: [
                "product_id": productId,
                "verification_error": String(describing: error),
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }

    /// Track restore purchases
    private func trackRestorePurchases() async {
        await analyticsService?.trackFeatureUsage(
            feature: "purchase_restored",
            metadata: [
                "source": "paywall",
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
        )
    }
}