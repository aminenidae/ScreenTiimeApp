# Core Workflows

## Workflow 1: Parent Categorizes App as Learning

```mermaid
sequenceDiagram
    participant Parent
    participant ParentUI
    participant RewardEngine
    participant CloudKit
    participant ChildDevice

    Parent->>ParentUI: Opens app categorization
    ParentUI->>RewardEngine: Fetch installed apps
    Parent->>ParentUI: Set "Duolingo" as Learning (20 pts/hr)
    ParentUI->>RewardEngine: Validate categorization
    RewardEngine->>CloudKit: Save AppCategorization
    CloudKit->>ChildDevice: Push notification
    ChildDevice->>ChildDevice: Update local cache
    ParentUI->>Parent: Success confirmation
```

## Workflow 2: Child Earns Points

```mermaid
sequenceDiagram
    participant Child
    participant DeviceActivity
    participant RewardEngine
    participant Validator
    participant CloudKit

    Child->>DeviceActivity: Opens Duolingo
    DeviceActivity->>RewardEngine: App launched
    RewardEngine->>CloudKit: Create UsageSession
    Child->>DeviceActivity: Uses app 30 min
    DeviceActivity->>RewardEngine: App closed
    RewardEngine->>Validator: Validate session
    Validator->>RewardEngine: Valid (10 pts)
    RewardEngine->>CloudKit: Update session + balance
    RewardEngine->>Child: "You earned 10 points!"
```

## Workflow 3: Subscription Purchase & Feature Gating

```mermaid
sequenceDiagram
    participant Parent
    participant StoreKit
    participant SubscriptionService
    participant CloudKitFunction
    participant CloudKit

    Parent->>StoreKit: Initiate purchase (2-child plan)
    StoreKit->>StoreKit: Process payment
    StoreKit->>SubscriptionService: Transaction completed
    SubscriptionService->>CloudKitFunction: Validate receipt
    CloudKitFunction->>CloudKitFunction: Verify with App Store
    CloudKitFunction->>CloudKit: Save entitlement
    CloudKit->>SubscriptionService: Return entitlement
    SubscriptionService->>Parent: Unlock features
```

## Workflow 4: Multi-Parent Real-Time Sync

```mermaid
sequenceDiagram
    participant Parent1
    participant CloudKit
    participant APNs
    participant Parent2

    Parent1->>CloudKit: Update conversion rate
    CloudKit->>CloudKit: Update shared zone
    CloudKit->>APNs: Send push
    APNs->>Parent2: Deliver notification
    Parent2->>CloudKit: Fetch updated settings
    Parent2->>Parent2: Update UI automatically
```

---
