# QA Fix Implementation Plan

## Overview
This document provides a detailed implementation plan for addressing the issues identified in the comprehensive QA review. The plan is organized by priority level and includes specific instructions for each fix.

## Priority 1: Required Fixes (Must Address Before PASS)

### 1. Implement PointToTimeRedemption Data Structure

**File**: `ScreenTimeRewards/SharedModels/Sources/SharedModels/Models.swift`

**Task**: Add the missing PointToTimeRedemption structure and related types:

```swift
// Add after existing enum definitions
public enum RedemptionStatus: String, Codable, CaseIterable {
    case active = "active"
    case expired = "expired"
    case used = "used"
}

// Add after existing struct definitions
public struct PointToTimeRedemption: Codable, Identifiable {
    public let id: String
    public let childProfileID: String
    public let appCategorizationID: String
    public let pointsSpent: Int
    public let timeGrantedMinutes: Int
    public let conversionRate: Double
    public let redeemedAt: Date
    public let expiresAt: Date
    public var timeUsedMinutes: Int
    public var status: RedemptionStatus

    public init(
        id: String,
        childProfileID: String,
        appCategorizationID: String,
        pointsSpent: Int,
        timeGrantedMinutes: Int,
        conversionRate: Double,
        redeemedAt: Date,
        expiresAt: Date,
        timeUsedMinutes: Int = 0,
        status: RedemptionStatus = .active
    ) {
        self.id = id
        self.childProfileID = childProfileID
        self.appCategorizationID = appCategorizationID
        self.pointsSpent = pointsSpent
        self.timeGrantedMinutes = timeGrantedMinutes
        self.conversionRate = conversionRate
        self.redeemedAt = redeemedAt
        self.expiresAt = expiresAt
        self.timeUsedMinutes = timeUsedMinutes
        self.status = status
    }
}
```

### 2. Define Repository Protocols

**File**: `ScreenTimeRewards/SharedModels/Sources/SharedModels/Models.swift`

**Task**: Add the PointToTimeRedemptionRepository protocol:

```swift
// Add after other repository protocol definitions (near line 1500)
@available(iOS 15.0, macOS 12.0, *)
public protocol PointToTimeRedemptionRepository {
    func createPointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption
    func fetchPointToTimeRedemption(id: String) async throws -> PointToTimeRedemption?
    func fetchPointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption]
    func fetchActivePointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption]
    func updatePointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption
    func deletePointToTimeRedemption(id: String) async throws
}
```

### 3. Complete FamilyControlsError Implementation

**File**: `ScreenTimeRewards/FamilyControlsKit/Sources/FamilyControlsKit/FamilyControlsService.swift`

**Task**: Add missing error cases to FamilyControlsError enum:

```swift
// Replace existing FamilyControlsError enum (around line 230)
public enum FamilyControlsError: Error, LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unavailable
    case monitoringFailed(Error)
    case timeLimitFailed(Error)
    case restrictionFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Family Controls authorization denied"
        case .authorizationRestricted:
            return "Family Controls authorization restricted"
        case .unavailable:
            return "Family Controls unavailable"
        case .monitoringFailed(let error):
            return "Failed to monitor family controls: \(error.localizedDescription)"
        case .timeLimitFailed(let error):
            return "Failed to set time limit: \(error.localizedDescription)"
        case .restrictionFailed(let error):
            return "Failed to apply restrictions: \(error.localizedDescription)"
        }
    }
}
```

### 4. Add Missing Model Initializers

**File**: `ScreenTimeRewards/SharedModels/Sources/SharedModels/Models.swift`

**Task**: Ensure ChildProfile initializer is complete and add Reward structure:

```swift
// Verify ChildProfile initializer includes all parameters (around line 50)
public init(
    id: String,
    familyID: String,
    name: String,
    avatarAssetURL: String?,
    birthDate: Date,
    pointBalance: Int,
    totalPointsEarned: Int = 0,
    deviceID: String? = nil,
    cloudKitZoneID: String? = nil,
    createdAt: Date = Date(),
    ageVerified: Bool = false,
    verificationMethod: String? = nil,
    dataRetentionPeriod: Int? = nil,
    notificationPreferences: NotificationPreferences? = nil
) {
    self.id = id
    self.familyID = familyID
    self.name = name
    self.avatarAssetURL = avatarAssetURL
    self.birthDate = birthDate
    self.pointBalance = pointBalance
    self.totalPointsEarned = totalPointsEarned
    self.deviceID = deviceID
    self.cloudKitZoneID = cloudKitZoneID
    self.createdAt = createdAt
    self.ageVerified = ageVerified
    self.verificationMethod = verificationMethod
    self.dataRetentionPeriod = dataRetentionPeriod
    self.notificationPreferences = notificationPreferences
}

// Add Reward structure (around line 100)
public struct Reward: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let pointCost: Int
    public let imageURL: String?
    public let isActive: Bool
    public let createdAt: Date

    public init(
        id: String,
        name: String,
        description: String,
        pointCost: Int,
        imageURL: String?,
        isActive: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.pointCost = pointCost
        self.imageURL = imageURL
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
```

## Priority 2: Recommended Fixes (Should Address for Improved Quality)

### 1. Implement DeviceActivitySchedule

**File**: `ScreenTimeRewards/SharedModels/Sources/SharedModels/Models.swift`

**Task**: Ensure DeviceActivitySchedule is fully implemented:

```swift
// Verify DeviceActivitySchedule implementation (around line 1080)
public struct DeviceActivitySchedule: Codable, Equatable {
    public let intervalStart: DateComponents
    public let intervalEnd: DateComponents
    public let repeats: Bool

    public init(
        intervalStart: DateComponents,
        intervalEnd: DateComponents,
        repeats: Bool = true
    ) {
        self.intervalStart = intervalStart
        self.intervalEnd = intervalEnd
        self.repeats = repeats
    }

    public static func dailySchedule(from startTime: DateComponents, to endTime: DateComponents) -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: startTime,
            intervalEnd: endTime,
            repeats: true
        )
    }

    public static func allDay() -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
    }
}
```

### 2. Add DateRange.today() Utility Method

**File**: `ScreenTimeRewards/SharedModels/Sources/SharedModels/Models.swift`

**Task**: Add the missing DateRange.today() method:

```swift
// Add to DateRange extensions (around line 20)
public extension DateRange {
    static func today() -> DateRange {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return DateRange(start: start, end: end)
    }
}
```

## Priority 3: Future Enhancements (Nice to Have)

### 1. Replace Mock CloudKit Implementations

**Files**: All files in `ScreenTimeRewards/CloudKitService/Sources/CloudKitService/`

**Task**: Replace print statements and empty return values with actual CloudKit operations:
- Implement proper CloudKit record creation, fetching, updating, and deletion
- Add proper error handling for CloudKit operations
- Implement proper data synchronization mechanisms

### 2. Complete FamilyControlsService Implementation

**File**: `ScreenTimeRewards/FamilyControlsKit/Sources/FamilyControlsKit/FamilyControlsService.swift`

**Task**: Replace fallback implementations with actual Family Controls integration:
- Implement actual Family Controls and ManagedSettings integration
- Add proper error handling for Family Controls operations
- Implement proper authorization status monitoring

## Testing Validation

After implementing these fixes, validate that the following tests pass:
1. `FamilyControlsKitTests/FamilyControlsKitTests.swift`
2. `CloudKitServiceTests/PointToTimeRedemptionRepositoryTests.swift`
3. `CloudKitServiceTests/CloudKitServiceTests.swift`
4. All integration tests in `Tests/IntegrationTests/`

## Verification Steps

1. Run all unit tests to ensure they pass
2. Run integration tests to verify functionality
3. Build the main application to ensure no compilation errors
4. Verify that the QA gate status can be updated to PASS