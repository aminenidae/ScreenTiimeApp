# Subscription Product ID Reference

This document provides a comprehensive reference for all subscription product IDs used in the ScreenTimeRewards app.

## Product Overview

All subscription products follow the naming convention: `screentime.{children}.{period}`

### Product Identifiers

| Product ID | Display Name | Description | Price | Period |
|------------|--------------|-------------|-------|---------|
| `screentime.1child.monthly` | 1 Child Monthly Subscription | Monitor and manage screen time for 1 child | $9.99/month | Monthly |
| `screentime.2child.monthly` | 2 Child Monthly Subscription | Monitor and manage screen time for up to 2 children | $13.98/month | Monthly |
| `screentime.1child.yearly` | 1 Child Yearly Subscription | Monitor and manage screen time for 1 child (annual billing) | $89.99/year | Yearly |
| `screentime.2child.yearly` | 2 Child Yearly Subscription | Monitor and manage screen time for up to 2 children (annual billing) | $125.99/year | Yearly |

### Subscription Group

All products belong to the **"Family Screen Time Management"** subscription group in App Store Connect.

### Free Trial

All subscription products include a **14-day free trial** period.

## Implementation Details

### SubscriptionService Usage

```swift
import SubscriptionService

// Fetch all available products
let subscriptionService = SubscriptionService()
await subscriptionService.fetchProducts()

// Access products by type
let monthlyProducts = subscriptionService.monthlyProducts
let yearlyProducts = subscriptionService.yearlyProducts

// Access products by tier (number of children)
let productsByTier = subscriptionService.productsByTier
let oneChildProducts = productsByTier[1] // Products for 1 child
let twoChildProducts = productsByTier[2] // Products for 2 children

// Calculate savings for yearly vs monthly
if let monthly = monthlyProducts.first(where: { $0.id.contains("1child") }),
   let yearly = yearlyProducts.first(where: { $0.id.contains("1child") }) {
    let savingsPercent = subscriptionService.calculateYearlySavings(
        monthlyProduct: monthly,
        yearlyProduct: yearly
    )
    // savingsPercent ≈ 25% for 1 child products
}
```

### Product Constants

Use the `ProductIdentifiers` enum for type-safe access to product IDs:

```swift
import SubscriptionService

// Individual product IDs
ProductIdentifiers.oneChildMonthly    // "screentime.1child.monthly"
ProductIdentifiers.twoChildMonthly    // "screentime.2child.monthly"
ProductIdentifiers.oneChildYearly     // "screentime.1child.yearly"
ProductIdentifiers.twoChildYearly     // "screentime.2child.yearly"

// All product IDs
ProductIdentifiers.allProducts        // Array of all 4 product IDs
```

## Pricing Strategy

### Value Proposition by Tier

**1 Child Products:**
- Monthly: $9.99/month → $119.88/year
- Yearly: $89.99/year → **25% savings**

**2 Child Products:**
- Monthly: $13.98/month → $167.76/year
- Yearly: $125.99/year → **25% savings**

### Competitive Analysis

- **Per-child cost (monthly):** $9.99 for first child, $3.99 for second child
- **Per-child cost (yearly):** $89.99 for first child, $36.00 for second child
- **Family-friendly pricing** with significant multi-child discounts

## Testing

### StoreKit Configuration

The app includes a `.storekit` configuration file for local testing:
- **Location:** `ScreenTimeRewards/Resources/ScreenTimeRewards.storekit`
- **Test scenarios:** Free trial, active subscription, expired subscription, grace period

### Sandbox Testing

1. Use sandbox Apple ID for testing
2. All products configured with proper pricing tiers
3. 14-day trial periods enabled for testing subscription flows

## App Store Connect Configuration

### Required Setup

1. **Subscription Group:** "Family Screen Time Management"
2. **Product Metadata:** Localized descriptions in English
3. **Pricing Tiers:** Configured according to the pricing table above
4. **Free Trial:** 14-day trial enabled on all products
5. **Family Sharing:** Disabled (subscriptions are account-specific)

### Localization

All products require localized metadata for submission:
- **Display names:** User-friendly subscription names
- **Descriptions:** Clear explanation of features and child limits
- **Benefits:** Bullet points highlighting key features

## Error Handling

The SubscriptionService includes comprehensive error handling for:

- **Product not found:** `AppError.productNotFound(productId)`
- **Purchase failures:** `AppError.purchaseFailed(reason)`
- **Network issues:** `AppError.networkError(message)`
- **StoreKit unavailable:** `AppError.storeKitNotAvailable`
- **Subscription expired:** `AppError.subscriptionExpired`

## Security Considerations

- **Receipt validation** handled server-side via CloudKit
- **Product verification** through StoreKit 2 APIs
- **Offline grace period** for temporary network issues
- **Family access control** through iCloud Family Sharing detection

## Future Extensibility

The product ID structure supports future expansion:
- Additional child tiers (3child, 4child, etc.)
- Different subscription periods (weekly, quarterly)
- Feature-specific products (premium analytics, etc.)

Pattern: `screentime.{feature}.{period}` or `screentime.{children}.{period}.{variant}`