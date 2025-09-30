import XCTest
import SharedModels
@testable import RewardCore

@available(iOS 15.0, macOS 12.0, *)
final class PermissionAwareRepositoryServiceTests: XCTestCase {
    var repositoryService: PermissionAwareRepositoryService!
    var permissionService: PermissionService!
    var mockChildProfileRepository: MockChildProfileRepository!
    var mockAppCategorizationRepository: MockAppCategorizationRepository!
    var mockFamilyRepository: MockFamilyRepository!
    var mockUsageSessionRepository: MockUsageSessionRepository!
    var mockPointTransactionRepository: MockPointTransactionRepository!

    override func setUp() {
        super.setUp()

        mockChildProfileRepository = MockChildProfileRepository()
        mockAppCategorizationRepository = MockAppCategorizationRepository()
        mockFamilyRepository = MockFamilyRepository()
        mockUsageSessionRepository = MockUsageSessionRepository()
        mockPointTransactionRepository = MockPointTransactionRepository()

        permissionService = PermissionService(
            cloudKitService: mockFamilyRepository,
            currentUserID: "test-user"
        )

        repositoryService = PermissionAwareRepositoryService(
            permissionService: permissionService,
            childProfileRepository: mockChildProfileRepository,
            appCategorizationRepository: mockAppCategorizationRepository,
            familyRepository: mockFamilyRepository,
            usageSessionRepository: mockUsageSessionRepository,
            pointTransactionRepository: mockPointTransactionRepository
        )

        // Set up default family
        let family = Family(
            id: "test-family",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "owner-user",
            sharedWithUserIDs: ["coparent-user"],
            childProfileIDs: ["test-child"],
            userRoles: ["coparent-user": .coParent]
        )
        mockFamilyRepository.mockFamily = family

        let childProfile = ChildProfile(
            id: "test-child",
            familyID: "test-family",
            name: "Test Child",
            avatarAssetURL: nil,
            birthDate: Date(),
            pointBalance: 100
        )
        mockChildProfileRepository.mockChild = childProfile
    }

    override func tearDown() {
        repositoryService = nil
        permissionService = nil
        mockChildProfileRepository = nil
        mockAppCategorizationRepository = nil
        mockFamilyRepository = nil
        mockUsageSessionRepository = nil
        mockPointTransactionRepository = nil
        super.tearDown()
    }

    // MARK: - Child Profile Permission Tests

    func testOwnerCanCreateChild() async throws {
        // Given
        let child = ChildProfile(
            id: "new-child",
            familyID: "test-family",
            name: "New Child",
            avatarAssetURL: nil,
            birthDate: Date(),
            pointBalance: 0
        )

        // When
        let createdChild = try await repositoryService.createChild(child, by: "owner-user")

        // Then
        XCTAssertEqual(createdChild.id, "new-child")
        XCTAssertTrue(mockChildProfileRepository.createChildCalled)
    }

    func testCoParentCanCreateChild() async throws {
        // Given
        let child = ChildProfile(
            id: "new-child",
            familyID: "test-family",
            name: "New Child",
            avatarAssetURL: nil,
            birthDate: Date(),
            pointBalance: 0
        )

        // When
        let createdChild = try await repositoryService.createChild(child, by: "coparent-user")

        // Then
        XCTAssertEqual(createdChild.id, "new-child")
        XCTAssertTrue(mockChildProfileRepository.createChildCalled)
    }

    func testUnauthorizedUserCannotCreateChild() async {
        // Given
        let child = ChildProfile(
            id: "new-child",
            familyID: "test-family",
            name: "New Child",
            avatarAssetURL: nil,
            birthDate: Date(),
            pointBalance: 0
        )

        // When & Then
        do {
            _ = try await repositoryService.createChild(child, by: "unauthorized-user")
            XCTFail("Should have thrown unauthorized error")
        } catch PermissionError.unauthorized {
            // Expected
            XCTAssertFalse(mockChildProfileRepository.createChildCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testOwnerCanDeleteChild() async throws {
        // When
        try await repositoryService.deleteChild(
            id: "test-child",
            from: "test-family",
            by: "owner-user"
        )

        // Then
        XCTAssertTrue(mockChildProfileRepository.deleteChildCalled)
    }

    func testUnauthorizedUserCannotDeleteChild() async {
        // When & Then
        do {
            try await repositoryService.deleteChild(
                id: "test-child",
                from: "test-family",
                by: "unauthorized-user"
            )
            XCTFail("Should have thrown unauthorized error")
        } catch PermissionError.unauthorized {
            // Expected
            XCTAssertFalse(mockChildProfileRepository.deleteChildCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - App Categorization Permission Tests

    func testOwnerCanCreateAppCategorization() async throws {
        // Given
        let categorization = AppCategorization(
            id: "test-cat",
            appBundleID: "com.test.app",
            category: .learning,
            childProfileID: "test-child",
            pointsPerHour: 10
        )

        // When
        let createdCategorization = try await repositoryService.createAppCategorization(
            categorization,
            by: "owner-user"
        )

        // Then
        XCTAssertEqual(createdCategorization.id, "test-cat")
        XCTAssertTrue(mockAppCategorizationRepository.createCalled)
    }

    func testCoParentCanCreateAppCategorization() async throws {
        // Given
        let categorization = AppCategorization(
            id: "test-cat",
            appBundleID: "com.test.app",
            category: .learning,
            childProfileID: "test-child",
            pointsPerHour: 10
        )

        // When
        let createdCategorization = try await repositoryService.createAppCategorization(
            categorization,
            by: "coparent-user"
        )

        // Then
        XCTAssertEqual(createdCategorization.id, "test-cat")
        XCTAssertTrue(mockAppCategorizationRepository.createCalled)
    }

    func testUnauthorizedUserCannotCreateAppCategorization() async {
        // Given
        let categorization = AppCategorization(
            id: "test-cat",
            appBundleID: "com.test.app",
            category: .learning,
            childProfileID: "test-child",
            pointsPerHour: 10
        )

        // When & Then
        do {
            _ = try await repositoryService.createAppCategorization(
                categorization,
                by: "unauthorized-user"
            )
            XCTFail("Should have thrown unauthorized error")
        } catch PermissionError.unauthorized {
            // Expected
            XCTAssertFalse(mockAppCategorizationRepository.createCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Family Permission Tests

    func testOwnerCanUpdateFamily() async throws {
        // Given
        guard let family = mockFamilyRepository.mockFamily else {
            XCTFail("Mock family should be available")
            return
        }

        // When
        let updatedFamily = try await repositoryService.updateFamily(family, by: "owner-user")

        // Then
        XCTAssertEqual(updatedFamily.id, "test-family")
        XCTAssertTrue(mockFamilyRepository.updateFamilyCalled)
    }

    func testCoParentCanUpdateFamily() async throws {
        // Given
        guard let family = mockFamilyRepository.mockFamily else {
            XCTFail("Mock family should be available")
            return
        }

        // When
        let updatedFamily = try await repositoryService.updateFamily(family, by: "coparent-user")

        // Then
        XCTAssertEqual(updatedFamily.id, "test-family")
        XCTAssertTrue(mockFamilyRepository.updateFamilyCalled)
    }

    func testUnauthorizedUserCannotUpdateFamily() async {
        // Given
        guard let family = mockFamilyRepository.mockFamily else {
            XCTFail("Mock family should be available")
            return
        }

        // When & Then
        do {
            _ = try await repositoryService.updateFamily(family, by: "unauthorized-user")
            XCTFail("Should have thrown unauthorized error")
        } catch PermissionError.unauthorized {
            // Expected
            XCTAssertFalse(mockFamilyRepository.updateFamilyCalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Permission Management Tests

    func testOwnerCanAssignRoles() async throws {
        // When
        let updatedFamily = try await repositoryService.assignUserRole(
            .viewer,
            to: "new-user",
            in: "test-family",
            by: "owner-user"
        )

        // Then
        XCTAssertEqual(updatedFamily.userRoles["new-user"], .viewer)
    }

    func testCoParentCannotAssignRoles() async {
        // When & Then
        do {
            _ = try await repositoryService.assignUserRole(
                .viewer,
                to: "new-user",
                in: "test-family",
                by: "coparent-user"
            )
            XCTFail("Should have thrown unauthorized error")
        } catch PermissionError.unauthorized {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testGetFamilyMembersWithPermissionCheck() async throws {
        // When
        let members = try await repositoryService.getFamilyMembers(
            familyID: "test-family",
            by: "owner-user"
        )

        // Then
        XCTAssertEqual(members.count, 2) // owner + coparent
        XCTAssertTrue(members.contains { $0.userID == "owner-user" && $0.role == .owner })
        XCTAssertTrue(members.contains { $0.userID == "coparent-user" && $0.role == .coParent })
    }
}

// MARK: - Mock Repositories

class MockChildProfileRepository: ChildProfileRepository {
    var mockChild: ChildProfile?
    var createChildCalled = false
    var updateChildCalled = false
    var deleteChildCalled = false
    var fetchChildCalled = false
    var fetchChildrenCalled = false

    func createChild(_ child: ChildProfile) async throws -> ChildProfile {
        createChildCalled = true
        return child
    }

    func fetchChild(id: String) async throws -> ChildProfile? {
        fetchChildCalled = true
        return mockChild?.id == id ? mockChild : nil
    }

    func fetchChildren(for familyID: String) async throws -> [ChildProfile] {
        fetchChildrenCalled = true
        if let child = mockChild, child.familyID == familyID {
            return [child]
        }
        return []
    }

    func updateChild(_ child: ChildProfile) async throws -> ChildProfile {
        updateChildCalled = true
        return child
    }

    func deleteChild(id: String) async throws {
        deleteChildCalled = true
    }
}

class MockAppCategorizationRepository: AppCategorizationRepository {
    var createCalled = false
    var updateCalled = false
    var deleteCalled = false
    var fetchCalled = false

    func createAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization {
        createCalled = true
        return categorization
    }

    func fetchAppCategorization(id: String) async throws -> AppCategorization? {
        fetchCalled = true
        return nil
    }

    func fetchAppCategorizations(for childID: String) async throws -> [AppCategorization] {
        fetchCalled = true
        return []
    }

    func updateAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization {
        updateCalled = true
        return categorization
    }

    func deleteAppCategorization(id: String) async throws {
        deleteCalled = true
    }
}

class MockFamilyRepository: FamilyRepository {
    var mockFamily: Family?
    var createFamilyCalled = false
    var updateFamilyCalled = false
    var deleteFamilyCalled = false
    var fetchFamilyCalled = false

    func createFamily(_ family: Family) async throws -> Family {
        createFamilyCalled = true
        mockFamily = family
        return family
    }

    func fetchFamily(id: String) async throws -> Family? {
        fetchFamilyCalled = true
        return mockFamily?.id == id ? mockFamily : nil
    }

    func fetchFamilies(for userID: String) async throws -> [Family] {
        if let family = mockFamily,
           family.ownerUserID == userID || family.sharedWithUserIDs.contains(userID) {
            return [family]
        }
        return []
    }

    func updateFamily(_ family: Family) async throws -> Family {
        updateFamilyCalled = true
        mockFamily = family
        return family
    }

    func deleteFamily(id: String) async throws {
        deleteFamilyCalled = true
        if mockFamily?.id == id {
            mockFamily = nil
        }
    }
}

class MockUsageSessionRepository: UsageSessionRepository {
    var createCalled = false

    func createSession(_ session: UsageSession) async throws -> UsageSession {
        createCalled = true
        return session
    }

    func fetchSession(id: String) async throws -> UsageSession? {
        return nil
    }

    func fetchSessions(for childID: String, dateRange: DateRange?) async throws -> [UsageSession] {
        return []
    }

    func updateSession(_ session: UsageSession) async throws -> UsageSession {
        return session
    }

    func deleteSession(id: String) async throws {
    }
}

class MockPointTransactionRepository: PointTransactionRepository {
    var createCalled = false

    func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction {
        createCalled = true
        return transaction
    }

    func fetchTransaction(id: String) async throws -> PointTransaction? {
        return nil
    }

    func fetchTransactions(for childID: String, limit: Int?) async throws -> [PointTransaction] {
        return []
    }

    func fetchTransactions(for childID: String, dateRange: DateRange?) async throws -> [PointTransaction] {
        return []
    }

    func deleteTransaction(id: String) async throws {
    }
}