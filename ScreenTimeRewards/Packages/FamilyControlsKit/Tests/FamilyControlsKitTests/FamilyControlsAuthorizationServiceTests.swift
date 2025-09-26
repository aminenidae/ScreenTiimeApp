import XCTest
#if canImport(FamilyControls)
import FamilyControls
#endif
@testable import FamilyControlsKit

@available(iOS 15.0, *)
final class FamilyControlsAuthorizationServiceTests: XCTestCase {

    // MARK: - Properties

    private var authorizationService: FamilyControlsAuthorizationService!
    private var mockAuthorizationCenter: MockAuthorizationCenter!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockAuthorizationCenter = MockAuthorizationCenter()
        authorizationService = FamilyControlsAuthorizationService(authorizationCenter: mockAuthorizationCenter)
    }

    override func tearDown() {
        authorizationService = nil
        mockAuthorizationCenter = nil
        super.tearDown()
    }

    // MARK: - Authorization Status Tests

    func testAuthorizationStatus_ReturnsCorrectStatus() {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .approved

        // When
        let status = authorizationService.authorizationStatus

        // Then
        XCTAssertEqual(status, .approved)
    }

    // MARK: - Request Authorization Tests

    func testRequestAuthorization_WhenApproved_ReturnsApprovedStatus() async throws {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .approved
        mockAuthorizationCenter.shouldThrowError = false

        // When
        let status = try await authorizationService.requestAuthorization()

        // Then
        XCTAssertEqual(status, .approved)
        XCTAssertTrue(mockAuthorizationCenter.requestAuthorizationCalled)
    }

    func testRequestAuthorization_WhenDenied_ThrowsAuthorizationDenied() async {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .denied
        mockAuthorizationCenter.shouldThrowError = false

        // When/Then
        do {
            _ = try await authorizationService.requestAuthorization()
            XCTFail("Expected FamilyControlsAuthorizationError.authorizationDenied to be thrown")
        } catch FamilyControlsAuthorizationError.authorizationDenied {
            // Success - expected error was thrown
            XCTAssertTrue(mockAuthorizationCenter.requestAuthorizationCalled)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func testRequestAuthorization_WhenNotDetermined_ThrowsRequestFailed() async {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .notDetermined
        mockAuthorizationCenter.shouldThrowError = false

        // When/Then
        do {
            _ = try await authorizationService.requestAuthorization()
            XCTFail("Expected FamilyControlsAuthorizationError.requestFailed to be thrown")
        } catch FamilyControlsAuthorizationError.requestFailed {
            // Success - expected error was thrown
            XCTAssertTrue(mockAuthorizationCenter.requestAuthorizationCalled)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func testRequestAuthorization_WhenAuthorizationCenterThrows_ThrowsRequestFailed() async {
        // Given
        mockAuthorizationCenter.shouldThrowError = true
        mockAuthorizationCenter.errorToThrow = NSError(domain: "TestError", code: -1, userInfo: nil)

        // When/Then
        do {
            _ = try await authorizationService.requestAuthorization()
            XCTFail("Expected FamilyControlsAuthorizationError.requestFailed to be thrown")
        } catch FamilyControlsAuthorizationError.requestFailed {
            // Success - expected error was thrown
            XCTAssertTrue(mockAuthorizationCenter.requestAuthorizationCalled)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - Parent Role Tests

    func testIsParent_WhenAuthorized_ReturnsTrue() {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .approved

        // When
        let isParent = authorizationService.isParent()

        // Then
        XCTAssertTrue(isParent)
    }

    func testIsParent_WhenNotAuthorized_ReturnsFalse() {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .denied

        // When
        let isParent = authorizationService.isParent()

        // Then
        XCTAssertFalse(isParent)
    }

    func testIsParent_WhenNotDetermined_ReturnsFalse() {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .notDetermined

        // When
        let isParent = authorizationService.isParent()

        // Then
        XCTAssertFalse(isParent)
    }

    // MARK: - Child Role Tests

    func testIsChild_WhenAuthorized_ReturnsFalse() {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .approved

        // When
        let isChild = authorizationService.isChild()

        // Then
        XCTAssertFalse(isChild)
    }

    func testIsChild_WhenDenied_ReturnsTrue() {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .denied

        // When
        let isChild = authorizationService.isChild()

        // Then
        XCTAssertTrue(isChild)
    }

    func testIsChild_WhenNotDetermined_ReturnsTrue() {
        // Given
        mockAuthorizationCenter.mockAuthorizationStatus = .notDetermined

        // When
        let isChild = authorizationService.isChild()

        // Then
        XCTAssertTrue(isChild)
    }
}

// MARK: - Mock Authorization Center

private class MockAuthorizationCenter: AuthorizationCenter {
    var mockAuthorizationStatus: AuthorizationStatus = .notDetermined
    var requestAuthorizationCalled = false
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: nil)

    override var authorizationStatus: AuthorizationStatus {
        return mockAuthorizationStatus
    }

    override func requestAuthorization(for context: FamilyControls.AuthorizationContext) async throws {
        requestAuthorizationCalled = true

        if shouldThrowError {
            throw errorToThrow
        }
    }
}

// MARK: - Authorization Status Extension Tests

final class AuthorizationStatusExtensionTests: XCTestCase {

    func testDescription_AllCases() {
        XCTAssertEqual(AuthorizationStatus.notDetermined.description, "Not Determined")
        XCTAssertEqual(AuthorizationStatus.denied.description, "Denied")
        XCTAssertEqual(AuthorizationStatus.approved.description, "Approved")
    }

    func testIsAuthorized_WhenApproved_ReturnsTrue() {
        XCTAssertTrue(AuthorizationStatus.approved.isAuthorized)
    }

    func testIsAuthorized_WhenDenied_ReturnsFalse() {
        XCTAssertFalse(AuthorizationStatus.denied.isAuthorized)
    }

    func testIsAuthorized_WhenNotDetermined_ReturnsFalse() {
        XCTAssertFalse(AuthorizationStatus.notDetermined.isAuthorized)
    }
}