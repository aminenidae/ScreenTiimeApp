# Database Schema

## CloudKit Schema (CKRecord Types)

### Record Type: Family
```swift
// Zone: CKRecordZone.default() (shared)
RecordType: "Family"
Fields:
  - id: String (UUID)
  - name: String
  - createdAt: Date/Time
  - ownerUserID: String
  - sharedWithUserIDs: List<String>
  - childProfileIDs: List<String>

Indexes:
  - QUERYABLE: ownerUserID
  - QUERYABLE: sharedWithUserIDs
```

### Record Type: ChildProfile
```swift
// Zone: Custom zone "child-{UUID}"
RecordType: "ChildProfile"
Fields:
  - id: String (UUID)
  - familyID: String
  - name: String
  - avatarAsset: Asset
  - birthDate: Date/Time
  - pointBalance: Int64
  - totalPointsEarned: Int64
  - deviceID: String
  - cloudKitZoneID: String
  - createdAt: Date/Time

Indexes:
  - QUERYABLE: familyID
  - SORTABLE: pointBalance
```

### Record Type: AppCategorization
```swift
// Zone: Child's private zone
RecordType: "AppCategorization"
Fields:
  - id: String (UUID)
  - childProfileID: String
  - bundleIdentifier: String
  - appName: String
  - category: String (enum)
  - pointsPerHour: Int64
  - isActive: Int64 (boolean)
  - createdAt: Date/Time
  - createdBy: String

Indexes:
  - QUERYABLE: childProfileID
  - QUERYABLE: bundleIdentifier + childProfileID
```

### Record Type: UsageSession
```swift
RecordType: "UsageSession"
Fields:
  - id: String (UUID)
  - childProfileID: String
  - appCategorizationID: String
  - startTime: Date/Time
  - endTime: Date/Time (optional)
  - durationSeconds: Int64
  - pointsEarned: Int64
  - isValidated: Int64
  - validationDetailsJSON: String

Indexes:
  - QUERYABLE: childProfileID + startTime
  - QUERYABLE: endTime (nil = active)
```

### Record Type: PointTransaction
```swift
RecordType: "PointTransaction"
Fields:
  - id: String (UUID)
  - childProfileID: String
  - type: String (enum)
  - amount: Int64
  - description: String
  - timestamp: Date/Time
  - balanceAfter: Int64

Indexes:
  - QUERYABLE: childProfileID + timestamp
  - SORTABLE: timestamp (desc)
```

### Record Type: SubscriptionEntitlement
```swift
// Zone: CKRecordZone.default() (shared)
RecordType: "SubscriptionEntitlement"
Fields:
  - id: String (UUID)
  - familyID: String
  - subscriptionTier: String (enum)
  - receiptData: String
  - originalTransactionID: String
  - purchaseDate: Date/Time
  - expirationDate: Date/Time
  - isActive: Int64 (boolean)
  - isInTrial: Int64 (boolean)
  - autoRenewStatus: Int64 (boolean)
  - lastValidatedAt: Date/Time
  - gracePeriodExpiresAt: Date/Time (optional)
  - productIdentifier: String
  - environment: String

Indexes:
  - QUERYABLE: familyID
  - QUERYABLE: expirationDate
  - SORTABLE: lastValidatedAt (desc)
```

---

## CoreData Schema (Local Cache)

```swift
Entity: ChildProfileEntity
Attributes:
  - id: UUID
  - name: String
  - pointBalance: Int64
  - cloudKitZoneID: String
  - lastSyncedAt: Date
  - recordName: String
Relationships:
  - family: Many-to-One -> FamilyEntity
  - transactions: One-to-Many -> PointTransactionEntity

Entity: SyncQueueEntity (Offline queue)
Attributes:
  - id: UUID
  - operation: String (create/update/delete)
  - recordType: String
  - recordData: Binary Data
  - timestamp: Date
  - retryCount: Int16
```

---

**Schema Design Decisions:**

1. **Zone Isolation:** Per-child zones for privacy and granular sync
2. **Denormalization:** `pointBalance` duplicates transaction sum for performance
3. **Offline Queue:** `SyncQueueEntity` stores operations when offline
4. **Indexes:** Compound indexes on frequently filtered fields
5. **Soft Deletes:** Use `isActive` flags, preserve history

---
