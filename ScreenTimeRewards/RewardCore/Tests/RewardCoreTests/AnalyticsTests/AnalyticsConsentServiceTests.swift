import XCTest
@testable import RewardCore
import SharedModels

final class AnalyticsConsentServiceTests: XCTestCase {
    
    func testSetConsentLevel() async throws {
        // Arrange
        let service = AnalyticsConsentService()
        let familyID = "test-family-id"
        let consentLevel = AnalyticsConsentLevel.detailed
        
        // Act
        try await service.setConsentLevel(consentLevel, for: familyID)
        
        // Assert
        let retrievedLevel = try await service.getConsentLevel(for: familyID)
        XCTAssertEqual(retrievedLevel, consentLevel)
    }
    
    func testIsCollectionAllowed_whenConsentIsNone() async throws {
        // Arrange
        let service = AnalyticsConsentService()
        let familyID = "test-family-id"
        try await service.setConsentLevel(.none, for: familyID)
        
        // Act
        let isAllowed = await service.isCollectionAllowed(for: familyID)
        
        // Assert
        XCTAssertFalse(isAllowed)
    }
    
    func testIsCollectionAllowed_whenConsentIsDetailed() async throws {
        // Arrange
        let service = AnalyticsConsentService()
        let familyID = "test-family-id"
        try await service.setConsentLevel(.detailed, for: familyID)
        
        // Act
        let isAllowed = await service.isCollectionAllowed(for: familyID)
        
        // Assert
        XCTAssertTrue(isAllowed)
    }
    
    func testIsDetailedCollectionAllowed() async throws {
        // Arrange
        let service = AnalyticsConsentService()
        let familyID = "test-family-id"
        
        // Test with detailed consent
        try await service.setConsentLevel(.detailed, for: familyID)
        let isDetailedAllowed = await service.isDetailedCollectionAllowed(for: familyID)
        XCTAssertTrue(isDetailedAllowed)
        
        // Test with standard consent
        try await service.setConsentLevel(.standard, for: familyID)
        let isStandardAllowed = await service.isDetailedCollectionAllowed(for: familyID)
        XCTAssertFalse(isStandardAllowed)
    }
    
    func testIsEssentialCollectionAllowed() async throws {
        // Arrange
        let service = AnalyticsConsentService()
        let familyID = "test-family-id"
        
        // Test with essential consent
        try await service.setConsentLevel(.essential, for: familyID)
        let isEssentialAllowed = await service.isEssentialCollectionAllowed(for: familyID)
        XCTAssertTrue(isEssentialAllowed)
        
        // Test with none consent
        try await service.setConsentLevel(.none, for: familyID)
        let isNoneAllowed = await service.isEssentialCollectionAllowed(for: familyID)
        XCTAssertFalse(isNoneAllowed)
    }
    
    func testWithdrawConsent() async throws {
        // Arrange
        let service = AnalyticsConsentService()
        let familyID = "test-family-id"
        try await service.setConsentLevel(.detailed, for: familyID)
        
        // Act
        try await service.withdrawConsent(for: familyID)
        
        // Assert
        // After withdrawal, the default consent level should be returned
        let consentLevel = try await service.getConsentLevel(for: familyID)
        XCTAssertEqual(consentLevel, .detailed) // Default value
    }
}