# Backend Architecture

**Note:** This application uses a **serverless architecture** with CloudKit as the backend.

## Service Architecture (Serverless)

### CloudKit Zone Management

```swift
class CloudKitZoneManager {
    func createChildZone(childID: UUID) async throws -> CKRecordZone {
        let zoneID = CKRecordZone.ID(zoneName: "child-\(childID.uuidString)")
        let zone = CKRecordZone(zoneID: zoneID)
        return try await privateDatabase.save(zone)
    }
}
```

## Database Architecture (CloudKit Implementation)

```swift
extension ChildProfile {
    func toCKRecord(in zoneID: CKRecordZone.ID) -> CKRecord {
        let record = CKRecord(recordType: "ChildProfile", recordID: recordID)
        record["id"] = id.uuidString
        record["name"] = name
        record["pointBalance"] = pointBalance as NSNumber
        return record
    }

    static func from(ckRecord: CKRecord) -> ChildProfile? {
        // Parse CKRecord to model
    }
}
```

## Data Access Layer (Repository Implementation)

```swift
class CloudKitChildRepository: ChildProfileRepository {
    func createChildProfile(_ profile: ChildProfile) -> AnyPublisher<ChildProfile, Error> {
        Future { promise in
            Task {
                let zone = try await self.zoneManager.createChildZone(childID: profile.id)
                let record = profile.toCKRecord(in: zone.zoneID)
                let savedRecord = try await self.database.save(record)
                promise(.success(ChildProfile.from(ckRecord: savedRecord)!))
            }
        }
        .eraseToAnyPublisher()
    }

    func updatePointBalance(childID: UUID, delta: Int) -> AnyPublisher<Int, Error> {
        // Atomic point balance update
    }
}
```

## Authentication and Authorization

```swift
class AuthorizationService {
    func requestParentAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    func determineUserRole() async throws -> UserRole {
        let status = AuthorizationCenter.shared.authorizationStatus
        return status == .approved ? .parent : .child
    }
}
```

---
