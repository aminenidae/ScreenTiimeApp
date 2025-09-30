# Multi-Parent Collaboration Architecture Specification

## Overview

This document provides detailed technical specifications for implementing multi-parent collaboration features (Epic 6) which are critical for the v1.1 release. These features enable multiple parents to collaboratively manage their children's screen time profiles with real-time synchronization, secure permission controls, and transparent activity tracking.

## Architecture Components

### 1. Data Model Extensions

#### Family Model Enhancement
```swift
// Extended Family model to support multi-parent collaboration
struct Family: Codable {
    let id: String
    let name: String
    let ownerUserID: String
    let sharedWithUserIDs: [String] // Array of co-parent user IDs
    let subscriptionMetadata: SubscriptionMetadata
    let settings: FamilySettings
    let metadata: RecordMetadata
    let ckShareID: String? // CloudKit Share ID for multi-parent access
}

// Enhanced RecordMetadata for tracking changes
struct RecordMetadata: Codable {
    let createdAt: Date
    let updatedAt: Date
    let createdBy: String // User ID of creator
    let updatedBy: String // User ID of last modifier
}
```

#### Parent Coordination Event Model
```swift
// New model for tracking parent activities
struct ParentCoordinationEvent: Codable {
    let id: String
    let familyID: String
    let userID: String // User ID of parent who made the change
    let userName: String // Display name of parent
    let eventType: ParentCoordinationEventType
    let targetRecordType: String
    let targetRecordID: String
    let description: String
    let timestamp: Date
    let details: [String: AnyCodable] // Additional details about the change
}

enum ParentCoordinationEventType: String, Codable {
    case appCategorization
    case pointAdjustment
    case settingsChange
    case rewardRedemption
    case childProfileUpdate
}
```

### 2. CloudKit Architecture

#### Dedicated Coordination Zone
- Zone Name: `parent-coordination-{familyID}`
- Purpose: Store parent coordination events for real-time synchronization
- Record Types:
  - `ParentCoordinationEvent` - Tracks all parent activities
  - `FamilyInvitation` - Stores pending invitations
  - `ParentActivityStatus` - Tracks online status of parents

#### CloudKit Subscriptions
```swift
// Subscription for real-time coordination events
let subscription = CKQuerySubscription(
    recordType: "ParentCoordinationEvent",
    predicate: NSPredicate(format: "familyID = %@ AND userID != %@", familyID, currentUserID),
    options: [.firesOnRecordCreation]
)

let notificationInfo = CKSubscription.NotificationInfo()
notificationInfo.shouldSendContentAvailable = true
subscription.notificationInfo = notificationInfo
```

#### CKShare Integration
```swift
// Implementation for sharing family records with co-parents
func createFamilyShare(for family: Family) async throws -> CKShare {
    let share = CKShare(rootRecord: family.record)
    share[CKShare.SystemFieldKey.title] = "Family Screen Time Management"
    share.publicPermission = .none
    share.participants.forEach { participant in
        participant.permission = .readWrite
    }
    return share
}
```

### 3. Real-Time Synchronization

#### Event Publishing
```swift
// Service for publishing coordination events
class ParentCoordinationService {
    func publishEvent(_ event: ParentCoordinationEvent) async throws {
        // Save event to CloudKit coordination zone
        try await cloudKitService.save(record: event.record)
        
        // Notify other parents via push notification
        await sendCoordinationNotification(for: event)
    }
    
    func subscribeToFamilyEvents(familyID: String) async throws {
        // Set up CloudKit subscription for family events
        try await cloudKitService.createSubscription(
            recordType: "ParentCoordinationEvent",
            predicate: NSPredicate(format: "familyID = %@ AND userID != %@", familyID, currentUserID)
        )
    }
}
```

#### Push Notification Handling
```swift
// Background notification handler
func handleCoordinationNotification(_ userInfo: [AnyHashable: Any]) {
    // Fetch coordination events in background
    Task {
        let events = try await fetchNewCoordinationEvents()
        // Update local cache
        await updateLocalCache(with: events)
        // Notify UI via Combine publishers
        await publishUIUpdates(events: events)
    }
}
```

### 4. Conflict Resolution

#### Version Tracking
```swift
// Using CloudKit's recordChangeTag for conflict detection
class ConflictResolver {
    func resolveConflict(localRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
        // Compare recordChangeTag values
        let localTag = localRecord.recordChangeTag
        let serverTag = serverRecord.recordChangeTag
        
        // Last-Write-Wins strategy (default)
        if serverRecord.modificationDate > localRecord.modificationDate {
            return serverRecord
        } else {
            // Update local record with server values but preserve local changes
            return mergeRecords(local: localRecord, server: serverRecord)
        }
    }
    
    func mergeRecords(local: CKRecord, server: CKRecord) -> CKRecord {
        // Field-level merge implementation
        let mergedRecord = server.copy() as! CKRecord
        
        // Preserve local changes that don't conflict with server
        for key in local.allKeys() {
            if server[key] == nil || server[key] == local[key] {
                mergedRecord[key] = local[key]
            }
        }
        
        return mergedRecord
    }
}
```

### 5. Permission System

#### Role-Based Access Control
```swift
enum ParentRole: String, Codable {
    case owner = "owner"
    case coParent = "coParent"
    case viewer = "viewer" // For future implementation
}

struct ParentPermission {
    let role: ParentRole
    let canModifySettings: Bool
    let canCategorizeApps: Bool
    let canAdjustPoints: Bool
    let canManageRewards: Bool
    let canInviteCoParents: Bool
    let canRemoveCoParents: Bool
}

class PermissionService {
    func getPermissions(for userID: String, in family: Family) -> ParentPermission {
        if userID == family.ownerUserID {
            return ParentPermission(
                role: .owner,
                canModifySettings: true,
                canCategorizeApps: true,
                canAdjustPoints: true,
                canManageRewards: true,
                canInviteCoParents: true,
                canRemoveCoParents: true
            )
        } else if family.sharedWithUserIDs.contains(userID) {
            return ParentPermission(
                role: .coParent,
                canModifySettings: true,
                canCategorizeApps: true,
                canAdjustPoints: true,
                canManageRewards: true,
                canInviteCoParents: false,
                canRemoveCoParents: false
            )
        } else {
            return ParentPermission(
                role: .viewer,
                canModifySettings: false,
                canCategorizeApps: false,
                canAdjustPoints: false,
                canManageRewards: false,
                canInviteCoParents: false,
                canRemoveCoParents: false
            )
        }
    }
}
```

### 6. Activity Log Implementation

#### Event Formatting
```swift
class ActivityLogFormatter {
    func formatEvent(_ event: ParentCoordinationEvent) -> String {
        switch event.eventType {
        case .appCategorization:
            return "\(event.userName) categorized '\(event.details["appName"] ?? "Unknown App")' as \(event.details["category"] ?? "Unknown")"
        case .pointAdjustment:
            let points = event.details["points"] as? Int ?? 0
            let action = event.details["action"] as? String ?? "adjusted"
            return "\(event.userName) \(action) \(points) points for \(event.details["childName"] ?? "child")"
        case .settingsChange:
            return "\(event.userName) updated \(event.details["settingName"] ?? "a setting")"
        case .rewardRedemption:
            return "\(event.userName) redeemed \(event.details["points"] ?? "some") points for \(event.details["appName"] ?? "an app")"
        case .childProfileUpdate:
            return "\(event.userName) updated profile for \(event.details["childName"] ?? "a child")"
        }
    }
}
```

## Implementation Sequence

### Phase 1: Foundation (Week 1)
1. **Parent Invitation System**
   - Implement invitation token generation and storage
   - Create deep link handling for invitation acceptance
   - Integrate CKShare for family record sharing
   - Build UI components for invitation management

2. **Real-Time Synchronization Infrastructure**
   - Set up parent coordination zone in CloudKit
   - Implement event publishing service
   - Create CloudKit subscriptions for coordination events
   - Build push notification handling

### Phase 2: Conflict Resolution (Week 2)
1. **Conflict Detection**
   - Implement recordChangeTag comparison
   - Add conflict detection to repository layer

2. **Resolution Mechanisms**
   - Implement Last-Write-Wins strategy
   - Add field-level merge capabilities
   - Create user prompt for critical conflicts

### Phase 3: Visibility & Control (Week 3)
1. **Activity Log**
   - Implement event querying and formatting
   - Build activity log UI with pagination
   - Add search and filtering capabilities

2. **Permissions System**
   - Implement role-based access control
   - Add permission checks to all repository methods
   - Build UI indicators for permission levels

### Phase 4: Testing & Validation (Week 4)
1. **Integration Testing**
   - Test end-to-end invitation flow
   - Validate real-time synchronization
   - Test conflict resolution scenarios

2. **Performance Validation**
   - Measure synchronization latency
   - Validate scalability with multiple parents
   - Test offline behavior

## Performance Requirements

1. **Synchronization Latency**: <5 seconds for 95th percentile
2. **Conflict Resolution**: >95% automatic resolution
3. **Push Notification Delivery**: >99% delivery rate
4. **Data Consistency**: Zero data loss during conflicts

## Security Considerations

1. **Invitation Security**
   - Time-limited tokens (72-hour expiration)
   - One-time use enforcement
   - Owner-only invitation privileges

2. **Data Privacy**
   - COPPA compliance maintained
   - End-to-end encryption for sensitive data
   - Proper access controls at data layer

3. **Authentication**
   - iCloud authentication required
   - Family Controls authorization enforced
   - Secure session management

## Testing Strategy

### Unit Tests
- Test conflict resolution algorithms
- Validate permission enforcement logic
- Test event formatting and querying

### Integration Tests
- End-to-end invitation flow
- Real-time synchronization validation
- Conflict scenario testing

### Performance Tests
- Synchronization latency measurement
- Concurrent edit handling
- Scalability with multiple parents

### User Acceptance Tests
- Usability testing with families
- Invitation flow validation
- Activity log usefulness assessment

## Dependencies

1. **v1.0 Family Data Model**: Existing family model with sharedWithUserIDs field
2. **CloudKit Architecture**: Existing CloudKit integration and repository patterns
3. **iCloud Authentication**: Existing authentication flows
4. **Family Controls Integration**: Existing Family Controls framework integration

## Success Metrics

1. **Functional**: Two parents can manage simultaneously with <5 second sync
2. **Performance**: Sync latency <5s (95th percentile), >95% auto-resolution
3. **Adoption**: 40% of families add co-parent within 30 days
4. **Stability**: Zero critical bugs, <50% of CloudKit quota used

## Future Extensibility

1. **Viewer Role**: Read-only access for extended family members
2. **Advanced Conflict Resolution**: CRDT-based conflict resolution
3. **In-App Messaging**: Direct communication between parents
4. **Change Reversion**: Ability to undo co-parent changes