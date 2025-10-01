# CoreData Schema Documentation

This document describes the CoreData schema used for local caching in the ScreenTimeRewards application.

## Overview

The CoreData schema mirrors the CloudKit record types to provide offline support and improve performance. All entities are designed to be compatible with their CloudKit counterparts.

## Entities

### Family
- **id**: UUID (Primary Key)
- **name**: String
- **createdAt**: Date
- **ownerUserID**: String
- **sharedWithUserIDs**: Transformable ([String])
- **childProfileIDs**: Transformable ([UUID])

### ChildProfile
- **id**: UUID (Primary Key)
- **familyID**: UUID
- **name**: String
- **avatarAssetURL**: String (Optional)
- **birthDate**: Date
- **pointBalance**: Int16
- **totalPointsEarned**: Int32
- **deviceID**: String (Optional)
- **cloudKitZoneID**: String
- **createdAt**: Date

### AppCategorization
- **id**: UUID (Primary Key)
- **childProfileID**: UUID
- **bundleIdentifier**: String
- **appName**: String
- **category**: String (Raw value of AppCategory enum)
- **pointsPerHour**: Int16
- **iconData**: Data (Optional)
- **isActive**: Boolean
- **createdAt**: Date
- **updatedAt**: Date
- **createdBy**: String

### UsageSession
- **id**: UUID (Primary Key)
- **childProfileID**: UUID
- **appCategorizationID**: UUID
- **startTime**: Date
- **endTime**: Date (Optional)
- **durationSeconds**: Int32
- **pointsEarned**: Int16
- **isValidated**: Boolean
- **deviceActivityEventID**: String (Optional)

### PointTransaction
- **id**: UUID (Primary Key)
- **childProfileID**: UUID
- **type**: String (Raw value of TransactionType enum)
- **amount**: Int16
- **relatedSessionID**: UUID (Optional)
- **relatedRedemptionID**: UUID (Optional)
- **description**: String
- **timestamp**: Date
- **balanceAfter**: Int32

### RewardRedemption
- **id**: UUID (Primary Key)
- **childProfileID**: UUID
- **appCategorizationID**: UUID
- **pointsSpent**: Int16
- **timeGrantedMinutes**: Int16
- **conversionRate**: Int16
- **redeemedAt**: Date
- **expiresAt**: Date (Optional)
- **timeUsedMinutes**: Int16
- **status**: String (Raw value of RedemptionStatus enum)
- **managedSettingsStoreID**: String (Optional)

### FamilySettings
- **id**: UUID (Primary Key)
- **familyID**: UUID
- **defaultPointsPerHour**: Int16
- **conversionRate**: Int16
- **minimumSessionMinutes**: Int16
- **dailyRewardLimitMinutes**: Int16 (Optional)
- **weeklyRewardLimitMinutes**: Int16 (Optional)
- **enableNotifications**: Boolean
- **enableChildNotifications**: Boolean
- **validationStrictness**: String (Raw value of ValidationLevel enum)
- **lastModifiedAt**: Date
- **lastModifiedBy**: String

### SubscriptionEntitlement
- **id**: UUID (Primary Key)
- **familyID**: UUID
- **subscriptionTier**: String (Raw value of SubscriptionTier enum)
- **receiptData**: String
- **originalTransactionID**: String
- **purchaseDate**: Date
- **expirationDate**: Date
- **isActive**: Boolean
- **isInTrial**: Boolean
- **autoRenewStatus**: Boolean
- **lastValidatedAt**: Date
- **gracePeriodExpiresAt**: Date (Optional)
- **productIdentifier**: String
- **environment**: String

## Relationships

- **Family** ↔ **ChildProfile** (One-to-Many)
- **ChildProfile** ↔ **AppCategorization** (One-to-Many)
- **ChildProfile** ↔ **UsageSession** (One-to-Many)
- **ChildProfile** ↔ **PointTransaction** (One-to-Many)
- **ChildProfile** ↔ **RewardRedemption** (One-to-Many)
- **Family** ↔ **FamilySettings** (One-to-One)
- **Family** ↔ **SubscriptionEntitlement** (One-to-Many)

## Indexes

- All entities have indexes on their primary keys (id)
- Foreign key fields are indexed for performance
- Timestamp fields are indexed for chronological queries
- Status fields are indexed for filtering

## Sync Strategy

The CoreData schema is designed to work with the CloudKitService:

1. **Offline First**: All operations are performed locally first
2. **Sync Queue**: Changes are queued for synchronization when online
3. **Conflict Resolution**: Uses CloudKit's built-in conflict resolution
4. **Incremental Sync**: Only changed records are synchronized
5. **Zone Isolation**: Per-child data isolation is maintained

## COPPA Compliance

The schema supports COPPA compliance by:

1. **Age Verification**: Storing child birth dates for age calculation
2. **Parental Consent**: Tracking consent status in Family records
3. **Data Retention**: Supporting configurable data retention policies
4. **Privacy Controls**: Enabling granular privacy settings