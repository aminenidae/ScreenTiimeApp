# StoreKit 2 Implementation Specification

## Overview

This document provides detailed technical specifications for implementing StoreKit 2 subscription infrastructure (Epic 7) which is critical for the monetization of the ScreenTimeRewards app. The implementation includes tiered subscription management, 14-day free trial, server-side receipt validation, and feature gating.

## Architecture Components

### 1. Subscription Data Models

#### SubscriptionTier Enum
```swift
enum SubscriptionTier: String, CaseIterable, Codable {
    case oneChild = "1child"
    case twoChild = "2child"
    case threeChild = "3child" // Future expansion
    
    var maxChildren: Int {
        switch self {
        case .oneChild: return 1
        case .twoChild: return 2
        case .threeChild: return 5 // Future expansion
        }
    }
    
    var displayName: String {
        switch self {
        case .oneChild: return "1 Child Plan"
        case .twoChild: return "2 Child Plan"
        case .threeChild: return "Family Plan"
        }
    }
}
```

#### SubscriptionPeriod Enum
```swift
enum SubscriptionPeriod: String, CaseIterable, Codable {
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}
```

#### SubscriptionProduct Model
```swift
struct SubscriptionProduct: Identifiable, Codable {
    let id: String
    let productID: String
    let tier: SubscriptionTier
    let period: SubscriptionPeriod
    let displayName: String
    let description: String
    let price: Decimal
    let currencyCode: String
    let localizedPrice: String
    let hasFreeTrial: Bool
    let trialPeriodDays: Int?
    
    // Computed properties
    var isYearly: Bool {
        period == .yearly
    }
    
    var savingsPercentage: Int? {
        guard isYearly else { return nil }
        // Calculate savings based on monthly equivalent
        let monthlyEquivalent = price * 12
        let monthlyPrice = getMonthlyPriceForSameTier()
        guard monthlyPrice > 0, monthlyEquivalent > 0 else { return nil }
        let savings = ((monthlyPrice * 12) - price) / (monthlyPrice * 12) * 100
        return Int(savings)
    }
    
    private func getMonthlyPriceForSameTier() -> Decimal {
        // Logic to fetch monthly price for the same tier
        // This would typically come from a pricing service
        switch tier {
        case .oneChild: return 9.99
        case .twoChild: return 13.98
        case .threeChild: return 18.97 // Future expansion
        }
    }
}
```

#### SubscriptionStatus Model
```swift
struct SubscriptionStatus: Codable {
    let isActive: Bool
    let tier: SubscriptionTier?
    let period: SubscriptionPeriod?
    let expirationDate: Date?
    let isInGracePeriod: Bool
    let isInBillingRetryPeriod: Bool
    let isTrialPeriod: Bool
    let trialExpirationDate: Date?
    let originalTransactionID: String?
    let latestTransactionID: String?
    let productID: String?
    let willRenew: Bool
    
    var canAccessPremiumFeatures: Bool {
        isActive || isInGracePeriod
    }
    
    var daysRemainingInTrial: Int? {
        guard let trialExpirationDate = trialExpirationDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: trialExpirationDate)
        return components.day
    }
}
```

### 2. StoreKit 2 Integration Layer

#### SubscriptionService
```swift
import StoreKit

@MainActor
class SubscriptionService: ObservableObject {
    @Published var products: [SubscriptionProduct] = []
    @Published var subscriptionStatus: SubscriptionStatus?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Fetching
    
    func fetchProducts() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Define product identifiers
        let productIDs = [
            "screentime.1child.monthly",
            "screentime.2child.monthly",
            "screentime.1child.yearly",
            "screentime.2child.yearly"
        ]
        
        // Fetch products from App Store
        let storeProducts = try await Product.products(for: productIDs)
        
        // Convert to our model
        self.products = storeProducts.map { storeProduct in
            SubscriptionProduct(
                id: storeProduct.id,
                productID: storeProduct.id,
                tier: self.extractTier(from: storeProduct.id),
                period: self.extractPeriod(from: storeProduct.id),
                displayName: storeProduct.displayName,
                description: storeProduct.description,
                price: storeProduct.price,
                currencyCode: storeProduct.priceFormatStyle.currencyCode,
                localizedPrice: storeProduct.displayPrice,
                hasFreeTrial: storeProduct.subscription?.isEligibleForIntroOffer ?? false,
                trialPeriodDays: storeProduct.subscription?.introductoryOffer?.period.value
            )
        }
    }
    
    // MARK: - Purchase Flow
    
    func purchase(_ product: SubscriptionProduct) async throws -> PurchaseResult {
        guard let storeProduct = try? await Product.products(for: [product.productID]).first else {
            throw SubscriptionError.productNotFound
        }
        
        let result = try await storeProduct.purchase()
        
        switch result {
        case .success(let verificationResult):
            // Handle successful purchase
            let transaction = try checkVerified(verificationResult)
            
            // Update subscription status
            await updateSubscriptionStatus()
            
            // Send transaction to server for validation
            await validateTransaction(transaction)
            
            return .success(transaction)
            
        case .pending:
            return .pending
            
        case .userCancelled:
            throw SubscriptionError.userCancelled
        }
    }
    
    // MARK: - Subscription Status Management
    
    func updateSubscriptionStatus() async {
        // Get the most recent transaction
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Update subscription status
                self.subscriptionStatus = SubscriptionStatus(
                    isActive: true,
                    tier: extractTier(from: transaction.productID),
                    period: extractPeriod(from: transaction.productID),
                    expirationDate: transaction.expirationDate,
                    isInGracePeriod: transaction.inGracePeriod,
                    isInBillingRetryPeriod: transaction.inBillingRetryPeriod,
                    isTrialPeriod: transaction.isInIntroOfferPeriod,
                    trialExpirationDate: transaction.expirationDate, // If in trial
                    originalTransactionID: transaction.originalID,
                    latestTransactionID: transaction.id.description,
                    productID: transaction.productID,
                    willRenew: transaction.isUpgraded == false // Simplified
                )
                
                return
            } catch {
                // Handle verification error
                continue
            }
        }
        
        // No active subscription found
        self.subscriptionStatus = SubscriptionStatus(
            isActive: false,
            tier: nil,
            period: nil,
            expirationDate: nil,
            isInGracePeriod: false,
            isInBillingRetryPeriod: false,
            isTrialPeriod: false,
            trialExpirationDate: nil,
            originalTransactionID: nil,
            latestTransactionID: nil,
            productID: nil,
            willRenew: false
        )
    }
    
    // MARK: - Server-Side Validation
    
    func validateTransaction(_ transaction: VerificationResult<Transaction>) async {
        // Send transaction to CloudKit Function for validation
        // This would be implemented in CloudKitFunctions/validateSubscriptionReceipt.js
        do {
            try await CloudKitService.shared.validateSubscriptionReceipt(transaction)
        } catch {
            print("Failed to validate transaction: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for transactions in the background
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Update subscription status
                    await MainActor.run {
                        self.updateSubscriptionStatus()
                    }
                    
                    // Always finish transactions
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private func extractTier(from productID: String) -> SubscriptionTier {
        if productID.contains("1child") {
            return .oneChild
        } else if productID.contains("2child") {
            return .twoChild
        } else {
            return .oneChild // Default fallback
        }
    }
    
    private func extractPeriod(from productID: String) -> SubscriptionPeriod {
        if productID.contains("yearly") {
            return .yearly
        } else {
            return .monthly
        }
    }
}

enum PurchaseResult {
    case success(Transaction)
    case pending
}

enum SubscriptionError: Error, LocalizedError {
    case productNotFound
    case userCancelled
    case verificationFailed
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Subscription product not found"
        case .userCancelled:
            return "Purchase was cancelled"
        case .verificationFailed:
            return "Purchase verification failed"
        }
    }
}
```

### 3. CloudKit Function for Receipt Validation

#### validateSubscriptionReceipt.js
```javascript
// CloudKitFunctions/validateSubscriptionReceipt.js
const crypto = require('crypto');

exports.handler = async function (db, params) {
    try {
        // Extract transaction data from params
        const { transactionData, jwsRepresentation } = params;
        
        // Verify JWS signature using Apple's root certificates
        const isValid = await verifyJWSSignature(jwsRepresentation);
        
        if (!isValid) {
            throw new Error('Invalid transaction signature');
        }
        
        // Parse the transaction data
        const transaction = JSON.parse(Buffer.from(jwsRepresentation.split('.')[1], 'base64').toString());
        
        // Validate transaction against Apple's servers (optional for enhanced security)
        // const appleValidation = await validateWithApple(transaction);
        
        // Create or update subscription entitlement record
        const subscriptionEntitlement = {
            recordName: `subscription-${transaction.originalTransactionId}`,
            fields: {
                familyID: { value: transaction.appAccountToken },
                productID: { value: transaction.productId },
                expirationDate: { value: new Date(transaction.expirationDate * 1000) },
                isActive: { value: transaction.expirationDate > Date.now() / 1000 },
                transactionID: { value: transaction.transactionId },
                originalTransactionID: { value: transaction.originalTransactionId },
                lastVerifiedAt: { value: new Date() }
            }
        };
        
        // Save to CloudKit
        await db.saveRecord('SubscriptionEntitlement', subscriptionEntitlement);
        
        return {
            success: true,
            entitlement: subscriptionEntitlement
        };
    } catch (error) {
        console.error('Subscription validation error:', error);
        return {
            success: false,
            error: error.message
        };
    }
};

async function verifyJWSSignature(jwsRepresentation) {
    // Implementation for verifying JWS signature using Apple's root certificates
    // This is a simplified version - in production, you would use Apple's verification libraries
    
    try {
        // Split JWS into components
        const [header, payload, signature] = jwsRepresentation.split('.');
        
        // Create the data that was signed
        const data = `${header}.${payload}`;
        
        // Get Apple's root certificate (this would be loaded from a secure source)
        const appleRootCert = getAppleRootCertificate();
        
        // Verify signature (simplified - use proper crypto libraries in production)
        const verifier = crypto.createVerify('RSA-SHA256');
        verifier.update(data);
        
        return verifier.verify(appleRootCert, signature, 'base64');
    } catch (error) {
        console.error('Signature verification failed:', error);
        return false;
    }
}

function getAppleRootCertificate() {
    // Return Apple's root certificate for signature verification
    // In production, this should be securely loaded from environment variables or secure storage
    return `-----BEGIN CERTIFICATE-----
MIICQzCCAcmgAwIBAgIILcANtzAqFk0wCgYIKoZIzj0EAwMwZzEbMBkGA1UEAwwSQXBwbGUg
Um9vdCBDQSAtIEczMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTET
MBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwHhcNMTQwNDMwMTgxOTA2WhcNMzAw
NDMwMTgxOTA2WjBnMRswGQYDVQQDDBJBcHBsZSBSb290IENBIC0gRzMxJjAkBgNVBAsMHUFw
cGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYD
VQQGEwJVUzB2MBAGByqGSM49AgEGBSuBBAAiA2IABJjpLz1AcqTtkyJygRMc3RCV8cWjTnHc
FBbZDuWmBSp3ZHtfTjjTuxxEtX/1H7YyYl3J6YRbTzBPEVoA/VhYDKX1DyxNB0cTddqXl5dv
oV7lVbD7jKcVj53U7ux666vovGJjMGEwHQYDVR0OBBYEFCvQaU0f5k/LvLzOU9dWvW+s1qDx
MB8GA1UdIwQYMBaAFCvQaU0f5k/LvLzOU9dWvW+s1qDxMA8GA1UdEwEB/wQFMAMBAf8wDgYD
VR0PAQH/BAQDAgEGMAoGCCqGSM49BAMDA2gAMGUCMQC7rKXFcce6O9647R83r0v7etG8sYMv
uoN9XfJInWtNWY4vyJbn4A3qRo+8jhc9LwIxAJdENJ1XJWUGJAkJnKNYI0dEiA2lpfOmXcj8
fjxjCg==
-----END CERTIFICATE-----`;
}
```

### 4. Feature Gating Implementation

#### FeatureGateService
```swift
class FeatureGateService {
    private let subscriptionService: SubscriptionService
    private let familyService: FamilyService
    
    init(subscriptionService: SubscriptionService, familyService: FamilyService) {
        self.subscriptionService = subscriptionService
        self.familyService = familyService
    }
    
    func canAccessFeature(_ feature: AppFeature) -> FeatureAccessResult {
        guard let subscriptionStatus = subscriptionService.subscriptionStatus else {
            return .denied(reason: .noSubscription)
        }
        
        // Check if subscription is active or in grace period
        guard subscriptionStatus.canAccessPremiumFeatures else {
            return .denied(reason: .subscriptionExpired)
        }
        
        // Check specific feature requirements
        switch feature {
        case .basic:
            // All users can access basic features
            return .allowed
            
        case .premiumAnalytics:
            // Premium features available to all paid subscribers
            return .allowed
            
        case .multiParent:
            // Multi-parent features available to all paid subscribers
            return .allowed
            
        case .childProfile(let childCount):
            // Check if user can create requested number of child profiles
            guard let tier = subscriptionStatus.tier else {
                return .denied(reason: .noSubscription)
            }
            
            if childCount <= tier.maxChildren {
                return .allowed
            } else {
                return .denied(reason: .childLimitExceeded(maxAllowed: tier.maxChildren))
            }
            
        case .exportReports:
            // Export features available to all paid subscribers
            return .allowed
        }
    }
    
    func getPaywallTrigger(for feature: AppFeature) -> PaywallTrigger? {
        let accessResult = canAccessFeature(feature)
        
        switch accessResult {
        case .allowed:
            return nil // No paywall needed
            
        case .denied(let reason):
            switch reason {
            case .noSubscription:
                return .subscribeToAccess(feature)
                
            case .subscriptionExpired:
                return .renewSubscription(feature)
                
            case .childLimitExceeded(let maxAllowed):
                return .upgradeForMoreChildren(currentMax: maxAllowed)
                
            case .trialExpired:
                return .convertTrial(feature)
            }
        }
    }
}

enum AppFeature {
    case basic
    case premiumAnalytics
    case multiParent
    case childProfile(childCount: Int)
    case exportReports
}

enum FeatureAccessResult {
    case allowed
    case denied(reason: FeatureDenialReason)
}

enum FeatureDenialReason {
    case noSubscription
    case subscriptionExpired
    case trialExpired
    case childLimitExceeded(maxAllowed: Int)
}

enum PaywallTrigger {
    case subscribeToAccess(AppFeature)
    case renewSubscription(AppFeature)
    case upgradeForMoreChildren(currentMax: Int)
    case convertTrial(AppFeature)
}
```

### 5. UI Components

#### PaywallViewModel
```swift
@MainActor
class PaywallViewModel: ObservableObject {
    @Published var products: [SubscriptionProduct] = []
    @Published var selectedProduct: SubscriptionProduct?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let subscriptionService: SubscriptionService
    
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
        loadProducts()
    }
    
    func loadProducts() {
        Task {
            do {
                try await subscriptionService.fetchProducts()
                DispatchQueue.main.async {
                    self.products = self.subscriptionService.products
                    self.selectedProduct = self.products.first { $0.isYearly } ?? self.products.first
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }
    
    func purchaseSelectedProduct() async throws {
        guard let product = selectedProduct else {
            throw SubscriptionError.productNotFound
        }
        
        try await subscriptionService.purchase(product)
    }
    
    func restorePurchases() async {
        // Trigger a refresh of subscription status
        await subscriptionService.updateSubscriptionStatus()
    }
}
```

## Implementation Sequence

### Phase 1: Core Subscription Foundation (Weeks 8-9)
1. **StoreKit 2 Integration**
   - Implement SubscriptionService with product fetching
   - Add transaction listening and verification
   - Create subscription status management

2. **Free Trial Implementation**
   - Implement trial eligibility detection
   - Create trial activation flow
   - Add trial expiration handling

### Phase 2: Advanced Subscription Features (Week 14)
1. **Subscription Management**
   - Implement subscription details screen
   - Add plan upgrade/downgrade functionality
   - Create subscription renewal monitoring

2. **Server-Side Receipt Validation**
   - Deploy CloudKit Function for receipt validation
   - Implement entitlement storage in CloudKit
   - Add fraud prevention measures

3. **Feature Gating**
   - Implement FeatureGateService
   - Add paywall trigger points
   - Create graceful degradation for expired subscriptions

4. **Subscription Analytics**
   - Implement conversion funnel tracking
   - Add key metrics dashboard
   - Create A/B testing framework

## Performance Requirements

1. **Receipt Validation Latency**: <1 second
2. **StoreKit Purchase Success Rate**: >95%
3. **Entitlement Sync Reliability**: >99.9%
4. **Payment Failure Rate**: <2%

## Security Considerations

1. **Receipt Validation**
   - Server-side validation via CloudKit Functions
   - JWS signature verification using Apple's root certificates
   - Protection against receipt tampering

2. **Data Privacy**
   - Compliance with App Store Review Guidelines 3.1
   - Secure handling of payment information
   - No external payment links

3. **Fraud Prevention**
   - Duplicate transaction detection
   - Jailbreak detection (non-blocking)
   - Anomalous usage pattern flagging

## Testing Strategy

### Unit Tests
- Test subscription product parsing
- Validate subscription status calculations
- Test feature gating logic
- Verify receipt validation

### Integration Tests
- End-to-end purchase flow
- Subscription management workflows
- CloudKit Function validation
- Feature access control

### Performance Tests
- Receipt validation latency
- Purchase success rates
- Entitlement sync reliability

### StoreKit Testing
- Free trial scenarios
- Billing retry handling
- Subscription expiration
- Plan upgrades/downgrades

## Dependencies

1. **CloudKit Infrastructure**: Existing CloudKit integration from Epic 1
2. **Family Data Model**: Existing family model with subscription metadata
3. **App Store Connect**: Properly configured subscription products
4. **StoreKit Configuration**: Local .storekit file for testing

## Success Metrics

### Business Metrics
- Trial-to-paid conversion rate >30%
- Monthly churn rate <5%
- Average LTV >$150 per family
- Payment failure rate <2%

### Technical Metrics
- Receipt validation latency <1 second
- StoreKit purchase success rate >95%
- Entitlement sync reliability >99.9%

### User Experience
- Paywall-to-purchase completion >60%
- Subscription management task success >90%
- Payment error resolution time <2 minutes

## App Store Review Considerations

1. **Compliance Requirements**
   - All payments via Apple In-App Purchase
   - Clear pricing and subscription terms displayed
   - Subscription management via iOS Settings
   - Privacy policy updated with payment data handling

2. **Guideline Compliance**
   - App Store Review Guideline 3.1 (In-App Purchase)
   - Guideline 3.1.1 (Subscription transparency)
   - Guideline 3.1.2 (Subscription management)

## Future Extensibility

1. **Additional Tiers**: Support for 3+ child plans
2. **Family Sharing**: Enable subscription sharing via Apple Family Sharing
3. **Promotional Offers**: Implementation of promotional offers and discounts
4. **Referral Program**: Integration with referral/affiliate systems