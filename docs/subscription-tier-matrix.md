# Subscription Tier Matrix

This document outlines the complete subscription tier structure for ScreenTimeRewards, including features, pricing, and access levels.

## Tier Overview

| Tier | Max Children | Monthly Price | Yearly Price | Annual Savings | Free Trial |
|------|--------------|---------------|--------------|----------------|------------|
| **1 Child** | 1 | $9.99 | $89.99 | 25% ($29.89) | 14 days |
| **2 Child** | 2 | $13.98 | $125.99 | 25% ($41.77) | 14 days |

## Feature Matrix

### Core Features (All Tiers)

| Feature | Description | 1 Child | 2 Child |
|---------|-------------|---------|---------|
| **Screen Time Monitoring** | Real-time app usage tracking | ✅ | ✅ |
| **App Categorization** | Educational vs entertainment apps | ✅ | ✅ |
| **Point System** | Reward system for educational app usage | ✅ | ✅ |
| **Reward Redemption** | Convert points to screen time rewards | ✅ | ✅ |
| **Parent Dashboard** | Overview of all child activities | ✅ | ✅ |
| **CloudKit Sync** | Cross-device synchronization | ✅ | ✅ |
| **Family Sharing** | iCloud Family integration | ✅ | ✅ |

### Child-Specific Limits

| Feature | 1 Child Tier | 2 Child Tier |
|---------|--------------|--------------|
| **Maximum Child Profiles** | 1 | 2 |
| **Individual Dashboards** | 1 child dashboard | 2 child dashboards |
| **Separate Point Tracking** | Single child | Per-child tracking |
| **Independent Rewards** | Single reward pool | Individual reward pools |
| **Custom App Categories** | Per single child | Per each child |

### Advanced Features

| Feature | Description | 1 Child | 2 Child |
|---------|-------------|---------|---------|
| **Usage Analytics** | Detailed usage reports and trends | ✅ | ✅ |
| **Educational Goals** | Set and track learning objectives | ✅ | ✅ |
| **Custom Rewards** | Parent-defined reward options | ✅ | ✅ |
| **Notification Settings** | Customizable alerts and reminders | ✅ | ✅ |
| **Data Export** | Export usage data and reports | ✅ | ✅ |
| **Offline Mode** | Limited functionality without internet | ✅ | ✅ |

## Pricing Strategy Analysis

### Cost Per Child Calculation

**1 Child Tier:**
- Monthly: $9.99 per child
- Yearly: $89.99 per child

**2 Child Tier:**
- Monthly: $6.99 per child ($13.98 ÷ 2)
- Yearly: $62.995 per child ($125.99 ÷ 2)

### Value Proposition

1. **Multi-child discount:** 30% savings per additional child
2. **Annual commitment bonus:** 25% savings for yearly subscriptions
3. **All-inclusive features:** No feature restrictions between tiers
4. **Family-friendly pricing:** Significant savings for larger families

## Implementation Guidelines

### Subscription Validation

```swift
import SubscriptionService

func validateChildLimit(currentChildCount: Int, subscribedTier: SubscriptionTier) -> Bool {
    switch subscribedTier {
    case .oneChild:
        return currentChildCount <= 1
    case .twoChild:
        return currentChildCount <= 2
    }
}
```

### Feature Gating

```swift
// Example feature gate implementation
func canAddChild(currentChildren: [ChildProfile], subscription: SubscriptionTier) -> Bool {
    let currentCount = currentChildren.count

    switch subscription {
    case .oneChild:
        return currentCount < 1
    case .twoChild:
        return currentCount < 2
    }
}
```

### Upgrade Flow

When users exceed their tier limits:

1. **Soft limit warning:** Notify when approaching child limit
2. **Upgrade prompt:** Direct to subscription management
3. **Graceful degradation:** Temporary access with upgrade reminder
4. **Feature preview:** Show benefits of higher tier

## Competitive Positioning

### Market Comparison

| Competitor | 1 Child Price | 2 Child Price | Annual Option |
|------------|---------------|---------------|---------------|
| **ScreenTimeRewards** | $9.99/month | $13.98/month | ✅ (25% off) |
| Screen Time Labs | $12.99/month | $19.99/month | ❌ |
| Family Time | $8.99/month | $15.99/month | ✅ (15% off) |
| Qustodio | $10.95/month | $16.95/month | ✅ (20% off) |

### Competitive Advantages

1. **Better multi-child pricing:** 30% per-child discount vs competitors' 20-25%
2. **Larger annual savings:** 25% vs industry average of 15-20%
3. **Educational focus:** Unique point-based reward system
4. **Native iOS integration:** Deep Family Controls and iCloud integration

## Future Tier Expansion

### Planned Additions

**3+ Child Tier (Future Release):**
- Price: $18.97/month, $169.99/year
- Max children: 5
- Additional features: Family analytics dashboard, advanced reporting

**Educational Institution Tier (Future Release):**
- Bulk pricing for schools
- Classroom management features
- Administrative controls

### Scalability Considerations

- **Database design:** Supports unlimited children per subscription
- **CloudKit limits:** Configured for family-scale data
- **Performance optimization:** Efficient queries for multi-child families
- **Storage costs:** Minimal per-child overhead

## Subscription Lifecycle

### Trial Period (14 Days)

1. **Full feature access** for tier subscribed
2. **No payment required** during trial
3. **Automatic conversion** unless cancelled
4. **Trial status tracking** in CloudKit

### Active Subscription

1. **Monthly/yearly billing** via App Store
2. **Automatic renewal** unless cancelled
3. **Feature gate enforcement** based on tier
4. **Grace period handling** for payment issues

### Expired/Cancelled Subscription

1. **Immediate feature restriction** to child limits
2. **Data retention** for 30 days
3. **Reactivation flow** available
4. **Export options** before data deletion

## Analytics and Metrics

### Key Performance Indicators

- **Tier distribution:** Percentage of users in each tier
- **Upgrade conversion:** 1-child to 2-child tier upgrades
- **Annual conversion:** Monthly to yearly subscription rate
- **Churn by tier:** Retention rates per subscription level

### Success Metrics

- **Target tier distribution:** 70% single child, 30% multiple children
- **Annual conversion rate:** >40% of monthly subscribers
- **Upgrade rate:** >15% of 1-child subscribers upgrade when adding second child
- **Overall churn:** <5% monthly, <8% annually

## Support and Documentation

### Customer Support by Tier

All tiers receive equal support:
- **In-app help** and tutorials
- **Email support** within 24 hours
- **FAQ and documentation** access
- **Community forum** participation

### Documentation Requirements

- **Feature tutorials** for each tier
- **Upgrade guides** between tiers
- **Billing and cancellation** instructions
- **Data privacy** and export information