# API Specification

**Note:** This application uses CloudKit's native API rather than REST or GraphQL. The following defines the protocol-based repository interfaces that abstract CloudKit operations for testability and maintainability.

## CloudKit Repository Definitions

All data access follows the Repository Pattern with Swift protocols that map to CloudKit CKDatabase operations. This approach enables:
- Unit testing with mock repositories
- Consistent error handling across the app
- Abstraction of CloudKit implementation details
- Future migration flexibility if needed

---

### FamilyRepository Protocol

```swift
import CloudKit
import Combine

protocol FamilyRepository {
    /// Create a new family in the shared zone
    func createFamily(_ family: Family) -> AnyPublisher<Family, Error>

    /// Fetch family by ID from shared zone
    func fetchFamily(id: UUID) -> AnyPublisher<Family, Error>

    /// Fetch all families where current user is owner or shared member
    func fetchUserFamilies() -> AnyPublisher<[Family], Error>

    /// Update family details (name, shared users)
    func updateFamily(_ family: Family) -> AnyPublisher<Family, Error>

    /// Add parent to family sharing
    func addParent(to familyID: UUID, userID: String) -> AnyPublisher<Family, Error>

    /// Remove parent from family sharing
    func removeParent(from familyID: UUID, userID: String) -> AnyPublisher<Family, Error>

    /// Subscribe to real-time family changes
    func subscribeToFamilyChanges(familyID: UUID) -> AnyPublisher<Family, Error>
}
```

### ChildProfileRepository Protocol

```swift
protocol ChildProfileRepository {
    /// Create child profile in dedicated private zone
    func createChildProfile(_ profile: ChildProfile) -> AnyPublisher<ChildProfile, Error>

    /// Fetch child profile from private zone
    func fetchChildProfile(id: UUID) -> AnyPublisher<ChildProfile, Error>

    /// Fetch all children in a family
    func fetchChildrenInFamily(familyID: UUID) -> AnyPublisher<[ChildProfile], Error>

    /// Update child profile (name, avatar, etc.)
    func updateChildProfile(_ profile: ChildProfile) -> AnyPublisher<ChildProfile, Error>

    /// Update point balance (atomic operation with conflict resolution)
    func updatePointBalance(childID: UUID, delta: Int) -> AnyPublisher<Int, Error>

    /// Subscribe to child profile changes
    func subscribeToChildChanges(childID: UUID) -> AnyPublisher<ChildProfile, Error>
}
```

### SubscriptionRepository Protocol

```swift
protocol SubscriptionRepository {
    /// Fetch active subscription entitlement
    func fetchEntitlement(familyID: UUID) -> AnyPublisher<SubscriptionEntitlement?, Error>

    /// Validate receipt via CloudKit Function
    func validateReceipt(receiptData: String) -> AnyPublisher<SubscriptionEntitlement, Error>

    /// Update entitlement after validation
    func updateEntitlement(_ entitlement: SubscriptionEntitlement) -> AnyPublisher<SubscriptionEntitlement, Error>

    /// Check if feature is allowed for current subscription
    func checkFeatureAccess(feature: FeatureFlag, familyID: UUID) -> AnyPublisher<Bool, Error>

    /// Subscribe to entitlement changes
    func subscribeToEntitlementChanges(familyID: UUID) -> AnyPublisher<SubscriptionEntitlement, Error>
}
```

---

## CloudKit Implementation Notes

**Zone Strategy:**
- `CKRecordZone.default()` - Family and FamilySettings (shared across parents)
- `CKRecordZone(zoneName: "child-{UUID}")` - Per-child private zones
- `CKRecordZone(zoneName: "parent-coordination")` - Multi-parent real-time sync

**Query Pattern Example:**
```swift
let predicate = NSPredicate(format: "childProfileID == %@ AND endTime == nil", childID.uuidString)
let query = CKQuery(recordType: "UsageSession", predicate: predicate)
```

**Subscription Example:**
```swift
let subscription = CKQuerySubscription(
    recordType: "Family",
    predicate: NSPredicate(format: "recordID == %@", familyRecordID),
    options: [.firesOnRecordUpdate]
)
```

---
