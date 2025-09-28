import XCTest
@testable import RewardCore
import SharedModels

final class DataAnonymizationServiceTests: XCTestCase {
    
    func testAnonymizeUserID() {
        // Arrange
        let service = DataAnonymizationService()
        let familyID = "test-family-id"
        
        // Act
        let anonymizedID = service.anonymizeUserID(familyID)
        
        // Assert
        XCTAssertNotNil(anonymizedID)
        XCTAssertNotEqual(familyID, anonymizedID)
        XCTAssertEqual(anonymizedID.count, 64) // SHA-256 produces 64 hex characters
    }
    
    func testAnonymizeDeviceModel_iPhone() {
        // Arrange
        let service = DataAnonymizationService()
        let deviceModel = "iPhone12,1"
        
        // Act
        let anonymizedModel = service.anonymizeDeviceModel(deviceModel)
        
        // Assert
        XCTAssertEqual(anonymizedModel, "iPhone")
    }
    
    func testAnonymizeDeviceModel_iPad() {
        // Arrange
        let service = DataAnonymizationService()
        let deviceModel = "iPad8,1"
        
        // Act
        let anonymizedModel = service.anonymizeDeviceModel(deviceModel)
        
        // Assert
        XCTAssertEqual(anonymizedModel, "iPad")
    }
    
    func testAnonymizeDeviceModel_other() {
        // Arrange
        let service = DataAnonymizationService()
        let deviceModel = "MacBookPro16,1"
        
        // Act
        let anonymizedModel = service.anonymizeDeviceModel(deviceModel)
        
        // Assert
        XCTAssertEqual(anonymizedModel, "Other")
    }
    
    func testAnonymizeEvent() async {
        // Arrange
        let service = DataAnonymizationService()
        let event = AnalyticsEvent(
            eventType: .featureUsage(feature: "test"),
            anonymizedUserID: "test-user-id",
            sessionID: "test-session",
            appVersion: "1.0.0",
            osVersion: "15.0",
            deviceModel: "iPhone12,1"
        )
        
        // Act
        let anonymizedEvent = await service.anonymize(event: event)
        
        // Assert
        XCTAssertNotEqual(event.anonymizedUserID, anonymizedEvent.anonymizedUserID)
        XCTAssertEqual(anonymizedEvent.deviceModel, "iPhone")
        XCTAssertEqual(event.eventType, anonymizedEvent.eventType)
        XCTAssertEqual(event.sessionID, anonymizedEvent.sessionID)
        XCTAssertEqual(event.appVersion, anonymizedEvent.appVersion)
        XCTAssertEqual(event.osVersion, anonymizedEvent.osVersion)
    }
}