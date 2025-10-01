# Real-Time Synchronization Implementation

## Overview

This document describes the implementation of real-time synchronization for parent coordination in the ScreenTime Rewards application. The feature enables changes made by one parent to be immediately visible to co-parents in the same family.

## Architecture

### Components

1. **ParentCoordinationService** - Core service managing coordination events
2. **ParentCoordinationRepository** - CloudKit repository for coordination events
3. **ChangeDetectionService** - Detects and publishes changes
4. **ParentCoordinationNotificationHandler** - Handles push notifications
5. **SynchronizationManager** - Ensures synchronization guarantees
6. **PerformanceOptimizationService** - Optimizes sync performance
7. **ParentDashboardViewModel** - UI integration point

### Data Models

#### ParentCoordinationEvent
```swift
public struct ParentCoordinationEvent: Codable, Identifiable {
    public let id: UUID
    public let familyID: UUID
    public let triggeringUserID: String
    public let eventType: ParentCoordinationEventType
    public let targetEntity: String
    public let targetEntityID: UUID
    public let changes: CodableDictionary
    public let timestamp: Date
    public let deviceID: String?
}
```

#### ParentCoordinationEventType
```swift
public enum ParentCoordinationEventType: String, Codable, CaseIterable {
    case appCategorizationChanged
    case settingsUpdated
    case pointsAdjusted
    case rewardRedeemed
    case childProfileModified
}
```

## Implementation Details

### 1. Parent Coordination Zone

A dedicated CloudKit zone is created for each family to isolate coordination events:
```
parent-coordination-{familyID}
```

### 2. CloudKit Subscriptions

Query subscriptions are created to receive real-time notifications:
- Filtered by family ID
- Excludes events triggered by the current user
- Configured for silent push notifications

### 3. Event Publishing

Changes are detected and published as coordination events:
- App categorization changes
- Child profile modifications
- Point balance adjustments
- Reward redemptions
- Settings updates

### 4. Push Notification Handling

Background fetch retrieves coordination events and updates the local cache. UI components are notified through Combine publishers.

### 5. Synchronization Guarantees

#### Retry Logic
Failed operations are retried with exponential backoff.

#### Offline Queue
Events are queued when offline and processed when connectivity is restored.

#### Idempotent Processing
Events are processed only once, even if received multiple times.

### 6. Performance Optimizations

#### Debouncing (300ms)
Frequent updates are debounced to reduce network traffic.

#### Batch Operations
Multiple events are processed together for efficiency.

#### Delta Sync
Only changes since the last sync are transferred.

## Integration Points

### View Models
ParentDashboardViewModel subscribes to coordination events and updates the UI accordingly.

### Repositories
CloudKit repositories are extended to support coordination event storage.

### Services
Various services coordinate to provide a seamless real-time experience.

## Testing

### Unit Tests
- Model initialization and serialization
- Service initialization
- Event publishing and handling

### Integration Tests
- Zone creation and subscription management
- Event publishing and retrieval
- Offline queue functionality
- Retry mechanisms

### UI Tests
- Toast notification display
- UI update responsiveness
- Error handling

## Performance Metrics

### Latency Target
- <5 seconds for event propagation (NFR11)

### Battery Impact
- Minimal due to APNs and efficient delta sync

### Memory Usage
- Events are cached efficiently with automatic cleanup

## Security Considerations

### Data Privacy
- Events are stored in private CloudKit database
- Family-scoped access control
- End-to-end encryption

### User Identification
- Events include triggering user ID for filtering
- Device ID tracking for debugging

## Future Enhancements

### Conflict Resolution
- Vector clock implementation for complex conflicts
- Last-write-wins with merge strategies

### Advanced Filtering
- User preference-based event filtering
- Priority-based delivery

### Enhanced Offline Support
- Extended offline operation periods
- Conflict detection and resolution