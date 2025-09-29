import XCTest
import SharedModels
@testable import SubscriptionService

@available(iOS 15.0, macOS 12.0, *)
@MainActor
final class FeatureGateServiceTests: XCTestCase {
    var featureGateService: FeatureGateService!
    fileprivate var mockFamilyRepository: MockFamilyRepository!

    override func setUp() async throws {
        try await super.setUp()
        mockFamilyRepository = MockFamilyRepository()
        featureGateService = FeatureGateService(familyRepository: mockFamilyRepository)
    }

    override func tearDown() async throws {
        featureGateService = nil
        mockFamilyRepository = nil
        try await super.tearDown()
    }

    func testCheckAccessWithActiveTrial() async {
        // Given: Family with active trial
        let trialStartDate = Date().addingTimeInterval(-86400) // 1 day ago
        let trialEndDate = Date().addingTimeInterval(86400 * 13) // 13 days from now
        let metadata = SubscriptionMetadata(
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            hasUsedTrial: true,
            isActive: true
        )
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: [],
            subscriptionMetadata: metadata
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Checking access
        let hasAccess = await featureGateService.checkAccess(for: "test-family")

        // Then: Should have access
        XCTAssertTrue(hasAccess)
        XCTAssertTrue(featureGateService.hasAccess)
    }

    func testCheckAccessWithActiveSubscription() async {
        // Given: Family with active subscription
        let subscriptionStartDate = Date().addingTimeInterval(-86400 * 30) // 30 days ago
        let subscriptionEndDate = Date().addingTimeInterval(86400 * 335) // ~11 months from now
        let metadata = SubscriptionMetadata(
            hasUsedTrial: true,
            subscriptionStartDate: subscriptionStartDate,
            subscriptionEndDate: subscriptionEndDate,
            isActive: true
        )
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: [],
            subscriptionMetadata: metadata
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Checking access
        let hasAccess = await featureGateService.checkAccess(for: "test-family")

        // Then: Should have access
        XCTAssertTrue(hasAccess)
        XCTAssertTrue(featureGateService.hasAccess)
    }

    func testCheckAccessWithExpiredTrial() async {
        // Given: Family with expired trial
        let trialStartDate = Date().addingTimeInterval(-86400 * 20) // 20 days ago
        let trialEndDate = Date().addingTimeInterval(-86400 * 6) // 6 days ago
        let metadata = SubscriptionMetadata(
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            hasUsedTrial: true
        )
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: [],
            subscriptionMetadata: metadata
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Checking access
        let hasAccess = await featureGateService.checkAccess(for: "test-family")

        // Then: Should not have access
        XCTAssertFalse(hasAccess)
        XCTAssertFalse(featureGateService.hasAccess)
    }

    func testCheckAccessWithNoTrialOrSubscription() async {
        // Given: Family with no trial or subscription
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: []
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Checking access
        let hasAccess = await featureGateService.checkAccess(for: "test-family")

        // Then: Should not have access
        XCTAssertFalse(hasAccess)
        XCTAssertFalse(featureGateService.hasAccess)
    }

    func testHasFeatureAccessWithAccess() async {
        // Given: Family with active trial
        let trialStartDate = Date().addingTimeInterval(-86400) // 1 day ago
        let trialEndDate = Date().addingTimeInterval(86400 * 13) // 13 days from now
        let metadata = SubscriptionMetadata(
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            hasUsedTrial: true,
            isActive: true
        )
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: [],
            subscriptionMetadata: metadata
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Checking feature access
        let hasUnlimitedMembers = await featureGateService.hasFeatureAccess(.unlimitedFamilyMembers, for: "test-family")
        let hasAdvancedAnalytics = await featureGateService.hasFeatureAccess(.advancedAnalytics, for: "test-family")

        // Then: Should have access to all features
        XCTAssertTrue(hasUnlimitedMembers)
        XCTAssertTrue(hasAdvancedAnalytics)
    }

    func testCanAddFamilyMemberWithFreeLimit() async {
        // Given: Family with no trial or subscription
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: []
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Checking if can add family member with 1 current member
        let canAdd = await featureGateService.canAddFamilyMember(for: "test-family", currentMemberCount: 1)

        // Then: Should be able to add (within free limit)
        XCTAssertTrue(canAdd)
    }

    func testCanAddFamilyMemberExceedingFreeLimit() async {
        // Given: Family with no trial or subscription
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: []
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Checking if can add family member with 2 current members (exceeding free limit)
        let canAdd = await featureGateService.canAddFamilyMember(for: "test-family", currentMemberCount: 2)

        // Then: Should not be able to add (exceeds free limit)
        XCTAssertFalse(canAdd)
    }

    func testGetFeatureAccessStatus() async {
        // Given: Family with active trial
        let trialStartDate = Date().addingTimeInterval(-86400) // 1 day ago
        let trialEndDate = Date().addingTimeInterval(86400 * 13) // 13 days from now
        let metadata = SubscriptionMetadata(
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            hasUsedTrial: true,
            isActive: true
        )
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: [],
            subscriptionMetadata: metadata
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Getting feature access status
        let status = await featureGateService.getFeatureAccessStatus(for: "test-family")

        // Then: All features should be accessible
        XCTAssertTrue(status.unlimitedFamilyMembers)
        XCTAssertTrue(status.advancedAnalytics)
        XCTAssertTrue(status.smartNotifications)
        XCTAssertTrue(status.enhancedParentalControls)
        XCTAssertTrue(status.cloudSync)
        XCTAssertTrue(status.prioritySupport)
    }

    func testGetAccessStatusMessage() async {
        // Given: Family with active trial
        let trialStartDate = Date().addingTimeInterval(-86400) // 1 day ago
        let trialEndDate = Date().addingTimeInterval(86400 * 13) // 13 days from now
        let metadata = SubscriptionMetadata(
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            hasUsedTrial: true,
            isActive: true
        )
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: [],
            subscriptionMetadata: metadata
        )
        mockFamilyRepository.families["test-family"] = family

        // When: Getting access status message
        let message = await featureGateService.getAccessStatusMessage(for: "test-family")

        // Then: Should contain trial information
        XCTAssertTrue(message.contains("Free trial active"))
        XCTAssertTrue(message.contains("days remaining"))
    }
}

// MARK: - Mock Family Repository

@available(iOS 15.0, macOS 12.0, *)
fileprivate class MockFamilyRepository: FamilyRepository {
    var families: [String: Family] = [:]

    func createFamily(_ family: Family) async throws -> Family {
        families[family.id] = family
        return family
    }

    func fetchFamily(id: String) async throws -> Family? {
        return families[id]
    }

    func fetchFamilies(for userID: String) async throws -> [Family] {
        return Array(families.values.filter { $0.ownerUserID == userID })
    }

    func updateFamily(_ family: Family) async throws -> Family {
        families[family.id] = family
        return family
    }

    func deleteFamily(id: String) async throws {
        families.removeValue(forKey: id)
    }
}