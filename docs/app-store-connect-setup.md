# App Store Connect Setup Guide

This document provides step-by-step instructions for configuring subscription products in App Store Connect for the ScreenTimeRewards app.

## Prerequisites

- App Store Connect account with admin access
- App ID created for ScreenTimeRewards
- Xcode project configured with proper bundle identifier
- StoreKit testing environment set up

## Step 1: Create Subscription Group

### Navigation
1. Log in to **App Store Connect**
2. Select your **ScreenTimeRewards** app
3. Go to **Features** → **In-App Purchases**
4. Click **Manage** next to "Subscription Groups"

### Group Configuration
1. Click **Create Subscription Group**
2. **Reference Name:** `Family Screen Time Management`
3. **Display Name:** `Family Screen Time Management`
4. **Description:** `Subscription group for family screen time monitoring and rewards`
5. Click **Save**

## Step 2: Configure Monthly Subscription Products

### Product 1: 1 Child Monthly

**Basic Information:**
- **Product ID:** `screentime.1child.monthly`
- **Reference Name:** `1 Child Monthly`
- **Display Name:** `1 Child Monthly Subscription`

**Subscription Details:**
- **Subscription Duration:** 1 Month
- **Subscription Group:** Family Screen Time Management
- **Pricing:**
  - Tier 1 ($9.99 USD)
  - Configure equivalent pricing for other regions

**Free Trial:**
- **Duration:** 14 Days
- **Enabled:** Yes

**Localizations (English - US):**
- **Display Name:** `1 Child Monthly Subscription`
- **Description:** `Monitor and manage screen time for 1 child with our comprehensive parental control system. Includes educational app tracking, point rewards, and detailed usage analytics.`
- **Benefits:**
  - ✅ Real-time screen time monitoring for 1 child
  - ✅ Educational vs entertainment app categorization
  - ✅ Point-based reward system for learning
  - ✅ Detailed usage analytics and reports
  - ✅ Custom parental controls and limits
  - ✅ CloudKit sync across all family devices

### Product 2: 2 Child Monthly

**Basic Information:**
- **Product ID:** `screentime.2child.monthly`
- **Reference Name:** `2 Child Monthly`
- **Display Name:** `2 Child Monthly Subscription`

**Subscription Details:**
- **Subscription Duration:** 1 Month
- **Subscription Group:** Family Screen Time Management
- **Pricing:**
  - Tier 2 ($13.98 USD)
  - Configure equivalent pricing for other regions

**Free Trial:**
- **Duration:** 14 Days
- **Enabled:** Yes

**Localizations (English - US):**
- **Display Name:** `2 Child Monthly Subscription`
- **Description:** `Monitor and manage screen time for up to 2 children with individual profiles and tracking. Perfect for families with multiple kids who need personalized screen time management.`
- **Benefits:**
  - ✅ Real-time screen time monitoring for up to 2 children
  - ✅ Individual profiles and dashboards per child
  - ✅ Separate point tracking and rewards for each child
  - ✅ Educational app categorization per child
  - ✅ Comprehensive family analytics dashboard
  - ✅ Multi-child parental controls and custom limits

## Step 3: Configure Yearly Subscription Products

### Product 3: 1 Child Yearly

**Basic Information:**
- **Product ID:** `screentime.1child.yearly`
- **Reference Name:** `1 Child Yearly`
- **Display Name:** `1 Child Yearly Subscription`

**Subscription Details:**
- **Subscription Duration:** 1 Year
- **Subscription Group:** Family Screen Time Management
- **Pricing:**
  - Tier 3 ($89.99 USD)
  - Configure equivalent pricing for other regions

**Free Trial:**
- **Duration:** 14 Days
- **Enabled:** Yes

**Localizations (English - US):**
- **Display Name:** `1 Child Yearly Subscription`
- **Description:** `Annual subscription for monitoring and managing screen time for 1 child. Save 25% compared to monthly billing while getting the same comprehensive features.`
- **Benefits:**
  - ✅ All features of monthly plan
  - ✅ 25% annual savings ($29.89 discount)
  - ✅ Uninterrupted service for full year
  - ✅ Priority customer support
  - ✅ Early access to new features

### Product 4: 2 Child Yearly

**Basic Information:**
- **Product ID:** `screentime.2child.yearly`
- **Reference Name:** `2 Child Yearly`
- **Display Name:** `2 Child Yearly Subscription`

**Subscription Details:**
- **Subscription Duration:** 1 Year
- **Subscription Group:** Family Screen Time Management
- **Pricing:**
  - Tier 4 ($125.99 USD)
  - Configure equivalent pricing for other regions

**Free Trial:**
- **Duration:** 14 Days
- **Enabled:** Yes

**Localizations (English - US):**
- **Display Name:** `2 Child Yearly Subscription`
- **Description:** `Annual subscription for up to 2 children with individual profiles and comprehensive family management tools. Maximum value for multi-child families.`
- **Benefits:**
  - ✅ All features of monthly 2-child plan
  - ✅ 25% annual savings ($41.77 discount)
  - ✅ Individual child profiles and dashboards
  - ✅ Family-wide analytics and insights
  - ✅ Priority customer support and early feature access

## Step 4: Pricing Configuration

### Price Tier Mapping

| Product | USD Price | Price Tier | Equivalent Regions |
|---------|-----------|------------|-------------------|
| 1 Child Monthly | $9.99 | Tier 1 | €9.99 EUR, £8.99 GBP, ¥1,500 JPY |
| 2 Child Monthly | $13.98 | Tier 2 | €13.99 EUR, £12.99 GBP, ¥2,200 JPY |
| 1 Child Yearly | $89.99 | Tier 3 | €89.99 EUR, £79.99 GBP, ¥13,800 JPY |
| 2 Child Yearly | $125.99 | Tier 4 | €125.99 EUR, £109.99 GBP, ¥19,800 JPY |

### Regional Considerations

1. **Tax Inclusive Pricing:** Enable where required by local regulations
2. **Currency Fluctuation:** Review quarterly and adjust if needed
3. **Local Competition:** Research regional competitors before launch
4. **Payment Methods:** Ensure supported methods per region

## Step 5: Review and Submission

### Pre-Submission Checklist

**Product Configuration:**
- [ ] All 4 products created with correct IDs
- [ ] Subscription group properly configured
- [ ] 14-day free trials enabled on all products
- [ ] Pricing tiers correctly set for all regions
- [ ] Localizations complete for primary markets

**Metadata Quality:**
- [ ] Display names are clear and descriptive
- [ ] Descriptions highlight key benefits
- [ ] Benefits lists are comprehensive and accurate
- [ ] No marketing superlatives or claims that can't be verified
- [ ] Consistent terminology across all products

**Legal Compliance:**
- [ ] Terms of Service updated to include subscription terms
- [ ] Privacy Policy covers subscription data handling
- [ ] COPPA compliance verified for child-focused features
- [ ] Auto-renewal disclosure included in app metadata

### Testing Requirements

**StoreKit Configuration:**
- [ ] Local .storekit file matches App Store Connect products
- [ ] Test scenarios cover all subscription states
- [ ] Error handling tested for network failures
- [ ] Purchase flow tested in sandbox environment

**Sandbox Testing:**
- [ ] Create sandbox test accounts
- [ ] Test each subscription product individually
- [ ] Verify free trial functionality
- [ ] Test subscription management (upgrade/downgrade)
- [ ] Validate receipt processing and verification

## Step 6: App Review Preparation

### Required App Store Review Information

**Subscription Features:**
- Provide demo account for App Review team
- Document how subscriptions unlock features
- Explain value proposition for each tier
- Show clear subscription management options

**User Experience:**
- Subscription paywall should not block core app evaluation
- Clear pricing information before purchase
- Easy cancellation process documented
- Restore purchases functionality working

**Technical Implementation:**
- StoreKit 2 properly implemented
- Receipt validation working
- Offline/network error handling
- Graceful degradation for expired subscriptions

### Common Rejection Reasons to Avoid

1. **Unclear Value Proposition:** Ensure subscription benefits are clear
2. **Missing Restore Purchases:** Implement restore functionality
3. **No Free Trial Disclosure:** Clearly communicate trial terms
4. **Subscription Wall:** Don't block app evaluation entirely
5. **Price Display Issues:** Show localized pricing correctly

## Step 7: Post-Launch Monitoring

### Key Metrics to Track

**Product Performance:**
- Conversion rates by product
- Trial-to-paid conversion rates
- Monthly vs yearly subscription preferences
- Regional performance variations

**Customer Behavior:**
- Upgrade/downgrade patterns
- Cancellation reasons
- Support ticket categories
- Feature usage by subscription tier

**Financial Metrics:**
- Monthly recurring revenue (MRR)
- Annual recurring revenue (ARR)
- Customer lifetime value (CLV)
- Churn rates by tier and region

### Optimization Opportunities

1. **A/B Testing:** Test different pricing strategies
2. **Promotional Offers:** Seasonal discounts and promotions
3. **Retention Campaigns:** Target at-risk subscribers
4. **Upselling:** Encourage upgrades from 1-child to 2-child tiers

## Support and Maintenance

### Ongoing Tasks

**Monthly:**
- Review subscription analytics
- Monitor customer feedback
- Update regional pricing if needed
- Analyze competitive landscape

**Quarterly:**
- Review and update product descriptions
- Assess new market opportunities
- Evaluate pricing strategy effectiveness
- Plan promotional campaigns

**Annually:**
- Comprehensive pricing review
- Product roadmap alignment
- Subscription model optimization
- Market expansion planning