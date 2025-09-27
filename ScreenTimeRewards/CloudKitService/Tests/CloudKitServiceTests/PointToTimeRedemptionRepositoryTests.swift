import XCTest
@testable import CloudKitService
import SharedModels

final class PointToTimeRedemptionRepositoryTests: XCTestCase {
    var repository: CloudKitService.PointToTimeRedemptionRepository!

    override func setUp() {
        super.setUp()
        repository = CloudKitService.PointToTimeRedemptionRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    // MARK: - Create Tests

    func testCreatePointToTimeRedemption_Success() async throws {
        // Given
        let redemption = createMockRedemption()

        // When
        let createdRedemption = try await repository.createPointToTimeRedemption(redemption)

        // Then
        XCTAssertEqual(createdRedemption.id, redemption.id)
        XCTAssertEqual(createdRedemption.childProfileID, redemption.childProfileID)
        XCTAssertEqual(createdRedemption.pointsSpent, redemption.pointsSpent)
        XCTAssertEqual(createdRedemption.timeGrantedMinutes, redemption.timeGrantedMinutes)
        XCTAssertEqual(createdRedemption.status, redemption.status)
    }

    func testCreatePointToTimeRedemption_ValidatesData() async throws {
        // Given
        let redemption = PointToTimeRedemption(
            id: "test-id",
            childProfileID: "child-1",
            appCategorizationID: "app-1",
            pointsSpent: 100,
            timeGrantedMinutes: 10,
            conversionRate: 10.0,
            redeemedAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            timeUsedMinutes: 0,
            status: .active
        )

        // When
        let createdRedemption = try await repository.createPointToTimeRedemption(redemption)

        // Then
        XCTAssertEqual(createdRedemption.conversionRate, 10.0)
        XCTAssertTrue(createdRedemption.expiresAt > createdRedemption.redeemedAt)
    }

    // MARK: - Fetch Tests

    func testFetchPointToTimeRedemption_NotFound() async throws {
        // Given
        let nonExistentID = "non-existent-id"

        // When
        let result = try await repository.fetchPointToTimeRedemption(id: nonExistentID)

        // Then
        XCTAssertNil(result, "Should return nil for non-existent redemption")
    }

    func testFetchPointToTimeRedemptions_EmptyResult() async throws {
        // Given
        let childID = "test-child-id"

        // When
        let results = try await repository.fetchPointToTimeRedemptions(for: childID)

        // Then
        XCTAssertTrue(results.isEmpty, "Should return empty array for child with no redemptions")
    }

    func testFetchActivePointToTimeRedemptions_EmptyResult() async throws {
        // Given
        let childID = "test-child-id"

        // When
        let results = try await repository.fetchActivePointToTimeRedemptions(for: childID)

        // Then
        XCTAssertTrue(results.isEmpty, "Should return empty array for child with no active redemptions")
    }

    // MARK: - Update Tests

    func testUpdatePointToTimeRedemption_Success() async throws {
        // Given
        let redemption = createMockRedemption()
        let updatedRedemption = PointToTimeRedemption(
            id: redemption.id,
            childProfileID: redemption.childProfileID,
            appCategorizationID: redemption.appCategorizationID,
            pointsSpent: redemption.pointsSpent,
            timeGrantedMinutes: redemption.timeGrantedMinutes,
            conversionRate: redemption.conversionRate,
            redeemedAt: redemption.redeemedAt,
            expiresAt: redemption.expiresAt,
            timeUsedMinutes: 5, // Updated usage
            status: .active
        )

        // When
        let result = try await repository.updatePointToTimeRedemption(updatedRedemption)

        // Then
        XCTAssertEqual(result.timeUsedMinutes, 5)
        XCTAssertEqual(result.status, RedemptionStatus.active)
    }

    func testUpdatePointToTimeRedemption_StatusChange() async throws {
        // Given
        let redemption = createMockRedemption()
        let expiredRedemption = PointToTimeRedemption(
            id: redemption.id,
            childProfileID: redemption.childProfileID,
            appCategorizationID: redemption.appCategorizationID,
            pointsSpent: redemption.pointsSpent,
            timeGrantedMinutes: redemption.timeGrantedMinutes,
            conversionRate: redemption.conversionRate,
            redeemedAt: redemption.redeemedAt,
            expiresAt: redemption.expiresAt,
            timeUsedMinutes: redemption.timeUsedMinutes,
            status: .expired // Changed to expired
        )

        // When
        let result = try await repository.updatePointToTimeRedemption(expiredRedemption)

        // Then
        XCTAssertEqual(result.status, RedemptionStatus.expired)
    }

    // MARK: - Delete Tests

    func testDeletePointToTimeRedemption_Success() async throws {
        // Given
        let redemptionID = "test-redemption-id"

        // When & Then (should not throw)
        try await repository.deletePointToTimeRedemption(id: redemptionID)
    }

    // MARK: - Helper Methods Tests

    func testFetchRedemptionsWithDateRange() async throws {
        // Given
        let childID = "test-child-id"
        let dateRange = DateRange(
            start: Date().addingTimeInterval(-86400), // 1 day ago
            end: Date()
        )

        // When
        let results = try await repository.fetchRedemptions(for: childID, dateRange: dateRange)

        // Then
        XCTAssertTrue(results.isEmpty, "Should return empty array in demo implementation")
    }

    func testFetchRedemptionsWithStatus() async throws {
        // Given
        let childID = "test-child-id"
        let status: RedemptionStatus = .active

        // When
        let results = try await repository.fetchRedemptions(for: childID, status: status)

        // Then
        XCTAssertTrue(results.isEmpty, "Should return empty array in demo implementation")
    }

    func testMarkExpiredRedemptions() async throws {
        // When
        let expiredCount = try await repository.markExpiredRedemptions()

        // Then
        XCTAssertEqual(expiredCount, 0, "Should return 0 in demo implementation")
    }

    func testGetRedemptionStats() async throws {
        // Given
        let childID = "test-child-id"

        // When
        let stats = try await repository.getRedemptionStats(for: childID)

        // Then
        XCTAssertEqual(stats.totalRedemptions, 0)
        XCTAssertEqual(stats.totalPointsSpent, 0)
        XCTAssertEqual(stats.totalTimeGranted, 0)
        XCTAssertEqual(stats.totalTimeUsed, 0)
        XCTAssertEqual(stats.activeRedemptions, 0)
        XCTAssertEqual(stats.efficiencyRatio, 0.0)
        XCTAssertEqual(stats.averagePointsPerMinute, 0.0)
    }

    // MARK: - RedemptionStats Tests

    func testRedemptionStats_EfficiencyRatio() {
        // Given
        let stats = RedemptionStats(
            totalRedemptions: 5,
            totalPointsSpent: 500,
            totalTimeGranted: 50,
            totalTimeUsed: 30,
            activeRedemptions: 2
        )

        // When & Then
        XCTAssertEqual(stats.efficiencyRatio, 0.6, accuracy: 0.01) // 30/50 = 0.6
    }

    func testRedemptionStats_AveragePointsPerMinute() {
        // Given
        let stats = RedemptionStats(
            totalRedemptions: 3,
            totalPointsSpent: 300,
            totalTimeGranted: 30,
            totalTimeUsed: 25,
            activeRedemptions: 1
        )

        // When & Then
        XCTAssertEqual(stats.averagePointsPerMinute, 10.0, accuracy: 0.01) // 300/30 = 10.0
    }

    func testRedemptionStats_ZeroDivision() {
        // Given
        let stats = RedemptionStats(
            totalRedemptions: 0,
            totalPointsSpent: 0,
            totalTimeGranted: 0,
            totalTimeUsed: 0,
            activeRedemptions: 0
        )

        // When & Then
        XCTAssertEqual(stats.efficiencyRatio, 0.0)
        XCTAssertEqual(stats.averagePointsPerMinute, 0.0)
    }

    // MARK: - Error Handling Tests

    func testRepositoryOperations_DoNotThrow() async {
        // All repository operations should handle errors gracefully in this demo implementation
        do {
            let redemption = createMockRedemption()

            // Test all operations
            let _ = try await repository.createPointToTimeRedemption(redemption)
            let _ = try await repository.fetchPointToTimeRedemption(id: "test-id")
            let _ = try await repository.fetchPointToTimeRedemptions(for: "test-child")
            let _ = try await repository.fetchActivePointToTimeRedemptions(for: "test-child")
            let _ = try await repository.updatePointToTimeRedemption(redemption)
            try await repository.deletePointToTimeRedemption(id: "test-id")

            // If we get here, all operations completed without throwing
            XCTAssertTrue(true)

        } catch {
            XCTFail("Repository operations should not throw in demo implementation: \(error)")
        }
    }

    // MARK: - Performance Tests

    func testCreateRedemption_Performance() async {
        let redemption = createMockRedemption()

        measure {
            Task {
                do {
                    let _ = try await repository.createPointToTimeRedemption(redemption)
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func createMockRedemption() -> PointToTimeRedemption {
        return PointToTimeRedemption(
            id: UUID().uuidString,
            childProfileID: "test-child-id",
            appCategorizationID: "test-app-cat-id",
            pointsSpent: 100,
            timeGrantedMinutes: 10,
            conversionRate: 10.0,
            redeemedAt: Date(),
            expiresAt: Date().addingTimeInterval(3600), // 1 hour from now
            timeUsedMinutes: 0,
            status: .active
        )
    }
}

// MARK: - CloudKitService Integration Tests

final class CloudKitServiceIntegrationTests: XCTestCase {
    var cloudKitService: CloudKitService!

    override func setUp() {
        super.setUp()
        cloudKitService = CloudKitService.shared
    }

    override func tearDown() {
        cloudKitService = nil
        super.tearDown()
    }

    func testCloudKitService_AllRepositoriesAccessible() async throws {
        // Test that all repository protocols are properly implemented

        // Test ChildProfileRepository
        let mockChild = ChildProfile(
            id: "test-child",
            familyID: "test-family",
            name: "Test Child",
            avatarAssetURL: nil,
            birthDate: Date(),
            pointBalance: 100
        )
        let createdChild = try await cloudKitService.createChild(mockChild)
        XCTAssertEqual(createdChild.id, mockChild.id)

        // Test PointToTimeRedemptionRepository
        let redemption = PointToTimeRedemption(
            id: "test-redemption",
            childProfileID: "test-child",
            appCategorizationID: "test-app",
            pointsSpent: 50,
            timeGrantedMinutes: 5,
            conversionRate: 10.0,
            redeemedAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            timeUsedMinutes: 0,
            status: .active
        )
        let createdRedemption = try await cloudKitService.createPointToTimeRedemption(redemption)
        XCTAssertEqual(createdRedemption.id, redemption.id)

        // Test PointTransactionRepository
        let transaction = PointTransaction(
            id: "test-transaction",
            childProfileID: "test-child",
            points: -50,
            reason: "Redeemed for screen time",
            timestamp: Date()
        )
        let createdTransaction = try await cloudKitService.createTransaction(transaction)
        XCTAssertEqual(createdTransaction.id, transaction.id)
    }

    func testCloudKitService_MockChildProfile() async throws {
        // Test the mock child profile functionality
        let fetchedChild = try await cloudKitService.fetchChild(id: "mock-child-id")

        XCTAssertNotNil(fetchedChild)
        XCTAssertEqual(fetchedChild?.id, "mock-child-id")
        XCTAssertEqual(fetchedChild?.name, "Demo Child")
        XCTAssertEqual(fetchedChild?.pointBalance, 450)
        XCTAssertEqual(fetchedChild?.totalPointsEarned, 1250)
    }

    func testCloudKitService_Singleton() {
        // Test that CloudKitService is properly implemented as a singleton
        let instance1 = CloudKitService.shared
        let instance2 = CloudKitService.shared

        XCTAssertTrue(instance1 === instance2, "CloudKitService should be a singleton")
    }
}