# Data Models

## Family

**Purpose:** Represents a family unit with multiple parents and children sharing screen time management

**Key Attributes:**
- `id`: UUID - Unique family identifier
- `name`: String - Family display name (e.g., "Smith Family")
- `createdAt`: Date - Family creation timestamp
- `ownerUserID`: String - iCloud user ID of primary account holder
- `sharedWithUserIDs`: [String] - iCloud user IDs of additional parents
- `childProfiles`: [UUID] - References to child profile IDs

### TypeScript Interface
```typescript
interface Family {
  id: UUID;
  name: string;
  createdAt: Date;
  ownerUserID: string;
  sharedWithUserIDs: string[];
  childProfiles: UUID[];
  metadata: {
    recordName: string;
    zoneName: string; // CloudKit shared zone
    modifiedAt: Date;
    modifiedBy: string; // Which parent made last change
  };
}
```

### Relationships
- Has many `ChildProfile` (one-to-many)
- Has many `ParentUser` via iCloud Family Sharing (many-to-many)

---

## ChildProfile

**Purpose:** Individual child account with point balance, app categorizations, and usage history

**Key Attributes:**
- `id`: UUID - Unique child identifier
- `familyID`: UUID - Reference to parent family
- `name`: String - Child's display name
- `avatarAsset`: CKAsset? - Profile picture stored in CloudKit
- `birthDate`: Date - For age-appropriate content and COPPA compliance
- `pointBalance`: Int - Current available points
- `totalPointsEarned`: Int - Lifetime points earned
- `deviceID`: String? - Associated iOS device identifier
- `cloudKitZoneID`: String - Private zone identifier for this child

### TypeScript Interface
```typescript
interface ChildProfile {
  id: UUID;
  familyID: UUID;
  name: string;
  avatarAsset?: CKAsset;
  birthDate: Date;
  pointBalance: number;
  totalPointsEarned: number;
  deviceID?: string;
  cloudKitZoneID: string;
  createdAt: Date;
  metadata: {
    recordName: string;
    zoneName: string; // Child's private zone
    lastSyncedAt: Date;
  };
}
```

### Relationships
- Belongs to `Family` (many-to-one)
- Has many `AppCategorization` (one-to-many)
- Has many `UsageSession` (one-to-many)
- Has many `PointTransaction` (one-to-many)
- Has many `RewardRedemption` (one-to-many)

---

## AppCategorization

**Purpose:** Parent-defined classification of apps as learning or reward with point values

**Key Attributes:**
- `id`: UUID - Unique categorization identifier
- `childProfileID`: UUID - Reference to child profile
- `bundleIdentifier`: String - iOS app bundle ID (e.g., "com.duolingo.duolingoapp")
- `appName`: String - Display name of the app
- `category`: AppCategory - Enum: `.learning` or `.reward`
- `pointsPerHour`: Int - Points earned per hour (for learning apps)
- `iconData`: Data? - Cached app icon
- `isActive`: Bool - Whether categorization is currently enforced

### TypeScript Interface
```typescript
enum AppCategory {
  learning = 'learning',
  reward = 'reward'
}

interface AppCategorization {
  id: UUID;
  childProfileID: UUID;
  bundleIdentifier: string;
  appName: string;
  category: AppCategory;
  pointsPerHour: number; // Only for learning apps
  iconData?: Data;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string; // Which parent created this
}
```

### Relationships
- Belongs to `ChildProfile` (many-to-one)
- Referenced by `UsageSession` (one-to-many)

---

## UsageSession

**Purpose:** Tracks time spent in an app during a continuous usage period

**Key Attributes:**
- `id`: UUID - Unique session identifier
- `childProfileID`: UUID - Reference to child profile
- `appCategorizationID`: UUID - Reference to categorized app
- `startTime`: Date - Session start timestamp
- `endTime`: Date? - Session end timestamp (nil if ongoing)
- `durationSeconds`: Int - Calculated duration
- `pointsEarned`: Int - Points awarded for this session
- `isValidated`: Bool - Whether session passed anti-gaming validation
- `deviceActivityEventID`: String? - Reference to DeviceActivityMonitor event

### TypeScript Interface
```typescript
interface UsageSession {
  id: UUID;
  childProfileID: UUID;
  appCategorizationID: UUID;
  startTime: Date;
  endTime?: Date;
  durationSeconds: number;
  pointsEarned: number;
  isValidated: boolean;
  deviceActivityEventID?: string;
  validationDetails?: {
    activeEngagement: boolean;
    minimumTimeThresholdMet: boolean;
    suspiciousActivityDetected: boolean;
  };
}
```

### Relationships
- Belongs to `ChildProfile` (many-to-one)
- References `AppCategorization` (many-to-many)

---

## PointTransaction

**Purpose:** Immutable ledger of all point earnings and redemptions

**Key Attributes:**
- `id`: UUID - Unique transaction identifier
- `childProfileID`: UUID - Reference to child profile
- `type`: TransactionType - Enum: `.earned`, `.redeemed`, `.adjusted`, `.expired`
- `amount`: Int - Points added (positive) or removed (negative)
- `relatedSessionID`: UUID? - Reference to UsageSession if earned
- `relatedRedemptionID`: UUID? - Reference to RewardRedemption if redeemed
- `description`: String - Human-readable transaction description
- `timestamp`: Date - When transaction occurred
- `balanceAfter`: Int - Point balance after this transaction

### TypeScript Interface
```typescript
enum TransactionType {
  earned = 'earned',
  redeemed = 'redeemed',
  adjusted = 'adjusted', // Parent manual adjustment
  expired = 'expired'    // Future: point expiration
}

interface PointTransaction {
  id: UUID;
  childProfileID: UUID;
  type: TransactionType;
  amount: number; // Positive or negative
  relatedSessionID?: UUID;
  relatedRedemptionID?: UUID;
  description: string;
  timestamp: Date;
  balanceAfter: number;
  metadata: {
    triggeredBy?: string; // System or parent user ID
    notes?: string;
  };
}
```

### Relationships
- Belongs to `ChildProfile` (many-to-one)
- May reference `UsageSession` (one-to-one)
- May reference `RewardRedemption` (one-to-one)

---

## RewardRedemption

**Purpose:** Records when a child converts points to screen time for reward apps

**Key Attributes:**
- `id`: UUID - Unique redemption identifier
- `childProfileID`: UUID - Reference to child profile
- `appCategorizationID`: UUID - Reference to reward app
- `pointsSpent`: Int - Points deducted
- `timeGrantedMinutes`: Int - Screen time minutes awarded
- `conversionRate`: Int - Points per minute at time of redemption
- `redeemedAt`: Date - Redemption timestamp
- `expiresAt`: Date? - When granted time expires
- `timeUsedMinutes`: Int - How much of granted time was used
- `status`: RedemptionStatus - Enum: `.active`, `.used`, `.expired`

### TypeScript Interface
```typescript
enum RedemptionStatus {
  active = 'active',     // Time available to use
  used = 'used',         // Time fully consumed
  expired = 'expired'    // Time expired unused
}

interface RewardRedemption {
  id: UUID;
  childProfileID: UUID;
  appCategorizationID: UUID;
  pointsSpent: number;
  timeGrantedMinutes: number;
  conversionRate: number; // Points per minute
  redeemedAt: Date;
  expiresAt?: Date;
  timeUsedMinutes: number;
  status: RedemptionStatus;
  managedSettingsStoreID?: string; // Family Controls reference
}
```

### Relationships
- Belongs to `ChildProfile` (many-to-one)
- References `AppCategorization` (one-to-one)
- Creates `PointTransaction` (one-to-one)

---

## SubscriptionEntitlement

**Purpose:** Tracks active subscription status and entitlements for feature gating

**Key Attributes:**
- `id`: UUID - Unique entitlement identifier
- `familyID`: UUID - Reference to family
- `subscriptionTier`: SubscriptionTier - Enum: `.oneChild`, `.twoChildren`, `.threeOrMore`
- `receiptData`: String - App Store receipt for validation
- `originalTransactionID`: String - StoreKit original transaction ID
- `purchaseDate`: Date - When subscription started
- `expirationDate`: Date - When subscription expires
- `isActive`: Bool - Current subscription status
- `isInTrial`: Bool - Whether in 14-day free trial
- `autoRenewStatus`: Bool - Auto-renewal enabled
- `lastValidatedAt`: Date - Last receipt validation timestamp

### TypeScript Interface
```typescript
enum SubscriptionTier {
  oneChild = 'oneChild',       // $9.99/month
  twoChildren = 'twoChildren', // $13.98/month
  threeOrMore = 'threeOrMore'  // +$3.99/child/month
}

interface SubscriptionEntitlement {
  id: UUID;
  familyID: UUID;
  subscriptionTier: SubscriptionTier;
  receiptData: string;
  originalTransactionID: string;
  purchaseDate: Date;
  expirationDate: Date;
  isActive: boolean;
  isInTrial: boolean;
  autoRenewStatus: boolean;
  lastValidatedAt: Date;
  gracePeriodExpiresAt?: Date; // Offline grace period
  metadata: {
    productIdentifier: string;
    environment: 'sandbox' | 'production';
    validationAttempts: number;
  };
}
```

### Relationships
- Belongs to `Family` (one-to-one)
- Validates against `ChildProfile` count for tier enforcement

---

## FamilySettings

**Purpose:** Configurable parameters for the reward system managed by parents

**Key Attributes:**
- `id`: UUID - Unique settings identifier
- `familyID`: UUID - Reference to family
- `defaultPointsPerHour`: Int - Default point value for learning apps
- `conversionRate`: Int - Points required per minute of reward time
- `minimumSessionMinutes`: Int - Minimum learning time to earn points
- `dailyRewardLimitMinutes`: Int? - Max reward time per day (optional)
- `weeklyRewardLimitMinutes`: Int? - Max reward time per week (optional)
- `enableNotifications`: Bool - Parent notification preferences
- `enableChildNotifications`: Bool - Child notification preferences
- `validationStrictness`: ValidationLevel - Enum: `.lenient`, `.moderate`, `.strict`

### TypeScript Interface
```typescript
enum ValidationLevel {
  lenient = 'lenient',     // Basic validation
  moderate = 'moderate',   // Standard anti-gaming checks
  strict = 'strict'        // Aggressive validation
}

interface FamilySettings {
  id: UUID;
  familyID: UUID;
  defaultPointsPerHour: number;
  conversionRate: number; // Points per minute of reward time
  minimumSessionMinutes: number;
  dailyRewardLimitMinutes?: number;
  weeklyRewardLimitMinutes?: number;
  enableNotifications: boolean;
  enableChildNotifications: boolean;
  validationStrictness: ValidationLevel;
  lastModifiedAt: Date;
  lastModifiedBy: string; // Which parent modified
}
```

### Relationships
- Belongs to `Family` (one-to-one)

---

## NotificationEventType

**Purpose:** Defines the types of notification events that can be triggered for parent notifications

**Key Attributes:**
- `pointsEarned`: Triggered when child earns points during a learning session
- `goalAchieved`: Triggered when child reaches a learning goal milestone
- `weeklyMilestone`: Triggered for weekly progress summaries
- `streakAchieved`: Triggered when child maintains a learning streak

### Swift Enum
```swift
enum NotificationEventType: String, CaseIterable {
    case pointsEarned = "points_earned"
    case goalAchieved = "goal_achieved"
    case weeklyMilestone = "weekly_milestone"
    case streakAchieved = "streak_achieved"
}
```

### Usage
- Used in `ChildProfile` to track enabled notification types
- Referenced by `NotificationService` to determine which events trigger notifications

---

## Data Model Design Decisions:

1. **Immutable Transactions:** `PointTransaction` is append-only ledger for auditability and debugging
2. **CloudKit Zone Mapping:** `ChildProfile.cloudKitZoneID` enables per-child data isolation
3. **Validation Tracking:** `UsageSession.validationDetails` supports anti-gaming algorithms
4. **Parent Attribution:** Most models track which parent made changes for multi-parent transparency
5. **Offline Support:** All models include metadata for conflict resolution (CKRecord system fields)
6. **COPPA Compliance:** `ChildProfile.birthDate` enforces age-appropriate features
7. **Extensibility:** `RewardRedemption` designed to support future reward types via strategy pattern
8. **Subscription Model:** `SubscriptionEntitlement` uses CloudKit Functions for server-side receipt validation
9. **Grace Periods:** Offline subscription validation supports 7-day grace period for network issues
10. **Notification Events:** `NotificationEventType` provides type-safe notification event definitions

---