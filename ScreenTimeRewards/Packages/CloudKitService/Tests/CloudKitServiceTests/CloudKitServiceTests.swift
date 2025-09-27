import XCTest
@testable import CloudKitService
import SharedModels

final class CloudKitServiceTests: XCTestCase {

    var repository: AppCategorizationRepository!
    
    override func setUp() {
        super.setUp()
        repository = AppCategorizationRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    func testRepositoryCreation() {
        XCTAssertNotNil(repository)
    }
    
    func testSaveCategorization() async throws {
        let categorization = AppCategorization(
            appBundleID: "com.test.app",
            category: .learning,
            childProfileID: "child-123",
            pointsPerHour: 10
        )
        
        // This should not throw an error in the mock implementation
        try await repository.save(categorization: categorization)
    }
    
    func testFetchCategorizations() async throws {
        let childProfileID = UUID()
        let categorizations = try await repository.fetchCategorizations(for: childProfileID)
        
        // In the mock implementation, this should return an empty array
        XCTAssertTrue(categorizations.isEmpty)
    }
    
    func testFetchCategorizationByBundleID() async throws {
        let bundleID = "com.test.app"
        let childProfileID = UUID()
        let categorization = try await repository.fetchCategorization(by: bundleID, childProfileID: childProfileID)
        
        // In the mock implementation, this should return nil
        XCTAssertNil(categorization)
    }
    
    func testDeleteCategorization() async throws {
        let categorizationID = UUID()
        
        // This should not throw an error in the mock implementation
        try await repository.delete(categorizationID: categorizationID)
    }
    
    func testCloudKitServiceSingleton() {
        let service1 = CloudKitService.shared
        let service2 = CloudKitService.shared

        XCTAssertTrue(service1 === service2, "CloudKitService should be a singleton")
    }

    func testRepositoryInstances() {
        let service = CloudKitService.shared

        XCTAssertNotNil(service.childProfileRepository)
        XCTAssertNotNil(service.rewardRepository)
        XCTAssertNotNil(service.screenTimeRepository)

        // Verify they are the correct types
        XCTAssertTrue(service.childProfileRepository is CloudKitChildProfileRepository)
        XCTAssertTrue(service.rewardRepository is CloudKitRewardRepository)
        XCTAssertTrue(service.screenTimeRepository is CloudKitScreenTimeRepository)
    }

    func testDateRangeToday() {
        let today = DateRange.today()
        let calendar = Calendar.current

        let expectedStart = calendar.startOfDay(for: Date())
        let expectedEnd = calendar.date(byAdding: .day, value: 1, to: expectedStart)!

        XCTAssertEqual(calendar.startOfDay(for: today.start), expectedStart)
        XCTAssertLessThan(today.end.timeIntervalSince(expectedEnd), 60) // Within 1 minute
    }

    func testDateRangeThisWeek() {
        let thisWeek = DateRange.thisWeek()
        let calendar = Calendar.current
        let now = Date()

        let expectedStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now

        XCTAssertEqual(calendar.startOfDay(for: thisWeek.start), calendar.startOfDay(for: expectedStart))
        XCTAssertGreaterThan(thisWeek.end, thisWeek.start)
    }

    func testDateRangeInitialization() {
        let start = Date()
        let end = Date().addingTimeInterval(86400) // +1 day

        let dateRange = DateRange(start: start, end: end)

        XCTAssertEqual(dateRange.start, start)
        XCTAssertEqual(dateRange.end, end)
    }

    func testCloudKitErrorDescriptions() {
        let accountError = CloudKitError.accountNotAvailable
        let networkError = CloudKitError.networkUnavailable
        let quotaError = CloudKitError.quotaExceeded
        let notFoundError = CloudKitError.recordNotFound
        let permissionError = CloudKitError.permissionDenied

        XCTAssertFalse(accountError.localizedDescription.isEmpty)
        XCTAssertFalse(networkError.localizedDescription.isEmpty)
        XCTAssertFalse(quotaError.localizedDescription.isEmpty)
        XCTAssertFalse(notFoundError.localizedDescription.isEmpty)
        XCTAssertFalse(permissionError.localizedDescription.isEmpty)

        // Test unknown error
        let underlyingError = NSError(domain: "Test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let unknownError = CloudKitError.unknownError(underlyingError)
        XCTAssertTrue(unknownError.localizedDescription.contains("Test error"))
    }

    // MARK: - Placeholder Repository Tests

    func testChildProfileRepository_CreateChild_ReturnsChild() async throws {
        let service = CloudKitService.shared
        let repository = service.childProfileRepository

        let parentID = UUID()
        let child = ChildProfile(
            name: "Test Child",
            parentID: parentID,
            pointBalance: 100
        )

        let result = try await repository.createChild(child)

        XCTAssertEqual(result.name, child.name)
        XCTAssertEqual(result.parentID, child.parentID)
        XCTAssertEqual(result.pointBalance, child.pointBalance)
    }

    func testChildProfileRepository_FetchChild_ReturnsNil() async throws {
        // Placeholder implementation should return nil
        let service = CloudKitService.shared
        let repository = service.childProfileRepository

        let result = try await repository.fetchChild(id: UUID())

        XCTAssertNil(result)
    }

    func testChildProfileRepository_FetchChildren_ReturnsEmptyArray() async throws {
        // Placeholder implementation should return empty array
        let service = CloudKitService.shared
        let repository = service.childProfileRepository

        let result = try await repository.fetchChildren(for: UUID())

        XCTAssertTrue(result.isEmpty)
    }

    func testRewardRepository_CreateReward_ReturnsReward() async throws {
        let service = CloudKitService.shared
        let repository = service.rewardRepository

        let parentID = UUID()
        let reward = Reward(
            title: "Extra Screen Time",
            description: "30 minutes of extra screen time",
            pointCost: 100,
            parentID: parentID
        )

        let result = try await repository.createReward(reward)

        XCTAssertEqual(result.title, reward.title)
        XCTAssertEqual(result.pointCost, reward.pointCost)
        XCTAssertEqual(result.parentID, reward.parentID)
    }

    func testRewardRepository_FetchRewards_ReturnsEmptyArray() async throws {
        // Placeholder implementation should return empty array
        let service = CloudKitService.shared
        let repository = service.rewardRepository

        let result = try await repository.fetchRewards(for: UUID())

        XCTAssertTrue(result.isEmpty)
    }

    func testScreenTimeRepository_CreateSession_ReturnsSession() async throws {
        let service = CloudKitService.shared
        let repository = service.screenTimeRepository

        let childID = UUID()
        let session = ScreenTimeSession(
            childID: childID,
            appName: "Reading App",
            duration: 1800,
            pointsEarned: 90
        )

        let result = try await repository.createSession(session)

        XCTAssertEqual(result.childID, session.childID)
        XCTAssertEqual(result.appName, session.appName)
        XCTAssertEqual(result.duration, session.duration)
        XCTAssertEqual(result.pointsEarned, session.pointsEarned)
    }

    func testScreenTimeRepository_FetchSessions_ReturnsEmptyArray() async throws {
        // Placeholder implementation should return empty array
        let service = CloudKitService.shared
        let repository = service.screenTimeRepository

        let result = try await repository.fetchSessions(for: UUID(), dateRange: nil)

        XCTAssertTrue(result.isEmpty)
    }

    func testScreenTimeRepository_FetchSessionsWithDateRange_ReturnsEmptyArray() async throws {
        // Placeholder implementation should return empty array even with date range
        let service = CloudKitService.shared
        let repository = service.screenTimeRepository

        let dateRange = DateRange.today()
        let result = try await repository.fetchSessions(for: UUID(), dateRange: dateRange)

        XCTAssertTrue(result.isEmpty)
    }
}