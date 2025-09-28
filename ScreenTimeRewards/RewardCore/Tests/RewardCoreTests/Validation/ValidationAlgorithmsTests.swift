import XCTest
@testable import RewardCore
@testable import SharedModels

final class ValidationAlgorithmsTests: XCTestCase {
    
    // MARK: - RapidSwitchingValidator Tests
    
    func testRapidSwitchingValidatorInitialization() {
        // When
        let validator = RapidSwitchingValidator()
        
        // Then
        XCTAssertNotNil(validator)
        XCTAssertEqual(validator.validatorName, "RapidSwitchingValidator")
    }
    
    func testRapidSwitchingValidator_ValidateSession_ShortDuration_ReturnsSuspiciousResult() async {
        // Given
        let validator = RapidSwitchingValidator()
        let session = createTestSession(duration: 15) // 15 seconds - very short
        let validationLevel = ValidationLevel.moderate
        
        // When
        let result = await validator.validateSession(session, validationLevel: validationLevel)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.validationScore, 0.3, accuracy: 0.01)
        XCTAssertEqual(result.confidenceLevel, 0.8, accuracy: 0.01)
        XCTAssertEqual(result.detectedPatterns.count, 1)
        if case .rapidAppSwitching = result.detectedPatterns.first! {
            // Expected pattern detected
        } else {
            XCTFail("Expected rapidAppSwitching pattern")
        }
        XCTAssertEqual(result.validationLevel, validationLevel)
        XCTAssertEqual(result.adjustmentFactor, 0.0, accuracy: 0.01) // Very low score should give no points
    }
    
    func testRapidSwitchingValidator_ValidateSession_LongDuration_ReturnsValidResult() async {
        // Given
        let validator = RapidSwitchingValidator()
        let session = createTestSession(duration: 3600) // 1 hour - long session
        let validationLevel = ValidationLevel.moderate
        
        // When
        let result = await validator.validateSession(session, validationLevel: validationLevel)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.validationScore, 0.9, accuracy: 0.01)
        XCTAssertEqual(result.confidenceLevel, 0.7, accuracy: 0.01)
        XCTAssertTrue(result.detectedPatterns.isEmpty)
        XCTAssertEqual(result.validationLevel, validationLevel)
        XCTAssertEqual(result.adjustmentFactor, 1.0, accuracy: 0.01) // High score should give full points
    }
    
    // MARK: - EngagementValidator Tests
    
    func testEngagementValidatorInitialization() {
        // When
        let validator = EngagementValidator()
        
        // Then
        XCTAssertNotNil(validator)
        XCTAssertEqual(validator.validatorName, "EngagementValidator")
    }
    
    func testEngagementValidator_ValidateSession_HighInteraction_ReturnsValidResult() async {
        // Given
        let validator = EngagementValidator()
        let session = createTestSession(duration: 1800) // 30 minutes
        let validationLevel = ValidationLevel.moderate
        
        // When
        let result = await validator.validateSession(session, validationLevel: validationLevel)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertGreaterThanOrEqual(result.validationScore, 0.7)
        XCTAssertGreaterThanOrEqual(result.confidenceLevel, 0.6)
        XCTAssertEqual(result.validationLevel, validationLevel)
        XCTAssertGreaterThanOrEqual(result.adjustmentFactor, 0.5)
    }
    
    // MARK: - TimingPatternValidator Tests
    
    func testTimingPatternValidatorInitialization() {
        // When
        let validator = TimingPatternValidator()
        
        // Then
        XCTAssertNotNil(validator)
        XCTAssertEqual(validator.validatorName, "TimingPatternValidator")
    }
    
    func testTimingPatternValidator_ValidateSession_NormalTiming_ReturnsValidResult() async {
        // Given
        let validator = TimingPatternValidator()
        let session = createTestSession(duration: 1800) // 30 minutes
        let validationLevel = ValidationLevel.moderate
        
        // When
        let result = await validator.validateSession(session, validationLevel: validationLevel)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertGreaterThanOrEqual(result.validationScore, 0.7)
        XCTAssertGreaterThanOrEqual(result.confidenceLevel, 0.6)
        XCTAssertEqual(result.validationLevel, validationLevel)
        XCTAssertGreaterThanOrEqual(result.adjustmentFactor, 0.5)
    }
    
    // MARK: - CompositeUsageValidator Tests
    
    func testCompositeUsageValidatorInitialization() {
        // Given
        let validators: [UsageValidator] = [RapidSwitchingValidator(), EngagementValidator()]
        
        // When
        let compositeValidator = CompositeUsageValidator(validators: validators)
        
        // Then
        XCTAssertNotNil(compositeValidator)
        XCTAssertEqual(compositeValidator.validatorName, "CompositeValidator")
    }
    
    func testCompositeUsageValidator_ValidateSession_CombinesResults() async {
        // Given
        let validators: [UsageValidator] = [RapidSwitchingValidator(), EngagementValidator()]
        let compositeValidator = CompositeUsageValidator(validators: validators)
        let session = createTestSession(duration: 1800) // 30 minutes
        let validationLevel = ValidationLevel.moderate
        
        // When
        let result = await compositeValidator.validateSession(session, validationLevel: validationLevel)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertLessThanOrEqual(result.validationScore, 1.0)
        XCTAssertGreaterThanOrEqual(result.validationScore, 0.0)
        XCTAssertLessThanOrEqual(result.confidenceLevel, 1.0)
        XCTAssertGreaterThanOrEqual(result.confidenceLevel, 0.0)
        XCTAssertEqual(result.validationLevel, validationLevel)
        XCTAssertLessThanOrEqual(result.adjustmentFactor, 1.0)
        XCTAssertGreaterThanOrEqual(result.adjustmentFactor, 0.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestSession(duration: TimeInterval) -> UsageSession {
        let now = Date()
        let endTime = now.addingTimeInterval(duration)
        
        return UsageSession(
            id: "test-session-\(UUID().uuidString)",
            childProfileID: "child-123",
            appBundleID: "com.example.app",
            category: .learning,
            startTime: now,
            endTime: endTime,
            duration: duration,
            isValidated: false
        )
    }
}