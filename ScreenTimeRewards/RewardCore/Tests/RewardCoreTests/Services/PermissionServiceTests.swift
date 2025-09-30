import XCTest
import SharedModels
@testable import RewardCore

@available(iOS 15.0, macOS 12.0, *)
final class PermissionServiceTests: XCTestCase {
    var permissionService: PermissionService!
    var mockCloudKitService: MockCloudKitService!

    override func setUp() {
        super.setUp()
        mockCloudKitService = MockCloudKitService()
        permissionService = PermissionService(
            cloudKitService: mockCloudKitService,
            currentUserID: "test-user-id"
        )
    }

    override func tearDown() {
        permissionService = nil
        mockCloudKitService = nil
        super.tearDown()
    }

    // MARK: - Permission Checking Tests

    func testOwnerHasAllPermissions() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id")
        mockCloudKitService.mockFamily = family

        let checks = [
            PermissionCheck(userID: "owner-id", familyID: family.id, action: .view),
            PermissionCheck(userID: "owner-id", familyID: family.id, action: .edit),
            PermissionCheck(userID: "owner-id", familyID: family.id, action: .delete),
            PermissionCheck(userID: "owner-id", familyID: family.id, action: .invite),
            PermissionCheck(userID: "owner-id", familyID: family.id, action: .remove)
        ]

        // When & Then
        for check in checks {
            let hasPermission = try await permissionService.checkPermission(check)
            XCTAssertTrue(hasPermission, "Owner should have \(check.action) permission")
        }
    }

    func testCoParentHasLimitedPermissions() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id", coParents: ["coparent-id": .coParent])
        mockCloudKitService.mockFamily = family

        // When & Then
        let viewCheck = PermissionCheck(userID: "coparent-id", familyID: family.id, action: .view)
        XCTAssertTrue(try await permissionService.checkPermission(viewCheck))

        let editCheck = PermissionCheck(userID: "coparent-id", familyID: family.id, action: .edit)
        XCTAssertTrue(try await permissionService.checkPermission(editCheck))

        let deleteCheck = PermissionCheck(userID: "coparent-id", familyID: family.id, action: .delete)
        XCTAssertTrue(try await permissionService.checkPermission(deleteCheck))

        let inviteCheck = PermissionCheck(userID: "coparent-id", familyID: family.id, action: .invite)
        XCTAssertFalse(try await permissionService.checkPermission(inviteCheck))

        let removeCheck = PermissionCheck(userID: "coparent-id", familyID: family.id, action: .remove)
        XCTAssertFalse(try await permissionService.checkPermission(removeCheck))
    }

    func testViewerHasOnlyViewPermissions() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id", coParents: ["viewer-id": .viewer])
        mockCloudKitService.mockFamily = family

        // When & Then
        let viewCheck = PermissionCheck(userID: "viewer-id", familyID: family.id, action: .view)
        XCTAssertTrue(try await permissionService.checkPermission(viewCheck))

        let editCheck = PermissionCheck(userID: "viewer-id", familyID: family.id, action: .edit)
        XCTAssertFalse(try await permissionService.checkPermission(editCheck))

        let deleteCheck = PermissionCheck(userID: "viewer-id", familyID: family.id, action: .delete)
        XCTAssertFalse(try await permissionService.checkPermission(deleteCheck))

        let inviteCheck = PermissionCheck(userID: "viewer-id", familyID: family.id, action: .invite)
        XCTAssertFalse(try await permissionService.checkPermission(inviteCheck))

        let removeCheck = PermissionCheck(userID: "viewer-id", familyID: family.id, action: .remove)
        XCTAssertFalse(try await permissionService.checkPermission(removeCheck))
    }

    func testNonMemberHasNoPermissions() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id")
        mockCloudKitService.mockFamily = family

        // When & Then
        let viewCheck = PermissionCheck(userID: "non-member", familyID: family.id, action: .view)
        XCTAssertFalse(try await permissionService.checkPermission(viewCheck))
    }

    func testFamilyNotFoundThrowsError() async {
        // Given
        mockCloudKitService.mockFamily = nil

        // When & Then
        let check = PermissionCheck(userID: "user-id", familyID: "non-existent-family", action: .view)

        do {
            _ = try await permissionService.checkPermission(check)
            XCTFail("Should have thrown PermissionError.familyNotFound")
        } catch PermissionError.familyNotFound {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Role Management Tests

    func testGetUserRole() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id", coParents: ["coparent-id": .coParent, "viewer-id": .viewer])

        // When & Then
        XCTAssertEqual(permissionService.getUserRole(userID: "owner-id", in: family), .owner)
        XCTAssertEqual(permissionService.getUserRole(userID: "coparent-id", in: family), .coParent)
        XCTAssertEqual(permissionService.getUserRole(userID: "viewer-id", in: family), .viewer)
        XCTAssertNil(permissionService.getUserRole(userID: "non-member", in: family))
    }

    func testAssignRoleByOwner() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id")
        mockCloudKitService.mockFamily = family

        // When
        let updatedFamily = try await permissionService.assignRole(
            .coParent,
            to: "new-user",
            in: family.id,
            by: "owner-id"
        )

        // Then
        XCTAssertEqual(updatedFamily.userRoles["new-user"], .coParent)
        XCTAssertTrue(updatedFamily.sharedWithUserIDs.contains("new-user"))
    }

    func testAssignRoleByNonOwnerThrowsError() async {
        // Given
        let family = createMockFamily(ownerID: "owner-id", coParents: ["coparent-id": .coParent])
        mockCloudKitService.mockFamily = family

        // When & Then
        do {
            _ = try await permissionService.assignRole(
                .viewer,
                to: "new-user",
                in: family.id,
                by: "coparent-id"
            )
            XCTFail("Should have thrown unauthorized error")
        } catch PermissionError.unauthorized {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRemoveUserByOwner() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id", coParents: ["coparent-id": .coParent])
        mockCloudKitService.mockFamily = family

        // When
        let updatedFamily = try await permissionService.removeUser(
            "coparent-id",
            from: family.id,
            by: "owner-id"
        )

        // Then
        XCTAssertNil(updatedFamily.userRoles["coparent-id"])
        XCTAssertFalse(updatedFamily.sharedWithUserIDs.contains("coparent-id"))
    }

    func testCannotRemoveOwner() async {
        // Given
        let family = createMockFamily(ownerID: "owner-id")
        mockCloudKitService.mockFamily = family

        // When & Then
        do {
            _ = try await permissionService.removeUser(
                "owner-id",
                from: family.id,
                by: "owner-id"
            )
            XCTFail("Should have thrown invalid role error")
        } catch PermissionError.invalidRole {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Family Members Tests

    func testGetFamilyMembers() async throws {
        // Given
        let family = createMockFamily(
            ownerID: "owner-id",
            coParents: ["coparent-id": .coParent, "viewer-id": .viewer]
        )
        mockCloudKitService.mockFamily = family

        // When
        let members = try await permissionService.getFamilyMembers(familyID: family.id)

        // Then
        XCTAssertEqual(members.count, 3)

        let ownerMember = members.first { $0.userID == "owner-id" }
        XCTAssertEqual(ownerMember?.role, .owner)

        let coParentMember = members.first { $0.userID == "coparent-id" }
        XCTAssertEqual(coParentMember?.role, .coParent)

        let viewerMember = members.first { $0.userID == "viewer-id" }
        XCTAssertEqual(viewerMember?.role, .viewer)
    }

    func testIsFamilyMember() async throws {
        // Given
        let family = createMockFamily(ownerID: "owner-id", coParents: ["coparent-id": .coParent])
        mockCloudKitService.mockFamily = family

        // When & Then
        XCTAssertTrue(try await permissionService.isFamilyMember(userID: "owner-id", familyID: family.id))
        XCTAssertTrue(try await permissionService.isFamilyMember(userID: "coparent-id", familyID: family.id))
        XCTAssertFalse(try await permissionService.isFamilyMember(userID: "non-member", familyID: family.id))
    }

    // MARK: - Current User Permission Tests

    func testCurrentUserPermissionChecking() async throws {
        // Given
        let currentUserPermissionService = PermissionService(
            cloudKitService: mockCloudKitService,
            currentUserID: "owner-id"
        )
        let family = createMockFamily(ownerID: "owner-id")
        mockCloudKitService.mockFamily = family

        // When & Then
        XCTAssertTrue(try await currentUserPermissionService.checkCurrentUserPermission(
            familyID: family.id,
            action: .edit
        ))
    }

    func testValidatePermissionThrowsOnUnauthorized() async {
        // Given
        let family = createMockFamily(ownerID: "owner-id")
        mockCloudKitService.mockFamily = family

        let check = PermissionCheck(userID: "non-member", familyID: family.id, action: .edit)

        // When & Then
        do {
            try await permissionService.validatePermission(check)
            XCTFail("Should have thrown unauthorized error")
        } catch PermissionError.unauthorized(let action) {
            XCTAssertEqual(action, .edit)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Helper Methods

    private func createMockFamily(
        ownerID: String,
        coParents: [String: PermissionRole] = [:]
    ) -> Family {
        return Family(
            id: "test-family-id",
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: ownerID,
            sharedWithUserIDs: Array(coParents.keys),
            childProfileIDs: [],
            userRoles: coParents
        )
    }
}

// MARK: - Mock CloudKit Service

@available(iOS 15.0, macOS 12.0, *)
class MockCloudKitService: FamilyRepository {
    var mockFamily: Family?

    func createFamily(_ family: Family) async throws -> Family {
        mockFamily = family
        return family
    }

    func fetchFamily(id: String) async throws -> Family? {
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
        mockFamily = family
        return family
    }

    func deleteFamily(id: String) async throws {
        if mockFamily?.id == id {
            mockFamily = nil
        }
    }
}