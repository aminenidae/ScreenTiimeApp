import XCTest
import CloudKit
@testable import RewardCore
@testable import SharedModels
@testable import CloudKitService

@available(iOS 15.0, macOS 12.0, *)
final class FamilyInvitationServiceTests: XCTestCase {
    var service: FamilyInvitationService!
    var mockInvitationRepository: MockFamilyInvitationRepository!
    var mockFamilyRepository: MockFamilyRepository!
    var mockCloudKitSharingService: MockCloudKitSharingService!
    var validationService: FamilyInvitationValidationService!

    override func setUp() {
        super.setUp()
        mockInvitationRepository = MockFamilyInvitationRepository()
        mockFamilyRepository = MockFamilyRepository()
        mockCloudKitSharingService = MockCloudKitSharingService()
        validationService = FamilyInvitationValidationService()

        service = FamilyInvitationService(
            familyInvitationRepository: mockInvitationRepository,
            familyRepository: mockFamilyRepository,
            cloudKitSharingService: mockCloudKitSharingService,
            validationService: validationService
        )
    }

    override func tearDown() {
        service = nil
        mockInvitationRepository = nil
        mockFamilyRepository = nil
        mockCloudKitSharingService = nil
        validationService = nil
        super.tearDown()
    }

    // MARK: - Create Invitation Tests

    func testCreateInvitation_Success() async throws {
        // Given
        let familyID = "family-123"
        let ownerUserID = "owner-456"
        let family = createMockFamily(id: familyID, ownerUserID: ownerUserID, sharedWithUserIDs: [])

        mockFamilyRepository.families[familyID] = family

        // When
        let invitation = try await service.createInvitation(
            familyID: familyID,
            invitingUserID: ownerUserID
        )

        // Then
        XCTAssertEqual(invitation.familyID, familyID)
        XCTAssertEqual(invitation.invitingUserID, ownerUserID)
        XCTAssertFalse(invitation.isUsed)
        XCTAssertTrue(invitation.deepLinkURL.hasPrefix("screentimerewards://invite/"))
        XCTAssertGreaterThan(invitation.expiresAt, Date())
    }

    func testCreateInvitation_NotFamilyOwner_ThrowsError() async {
        // Given
        let familyID = "family-123"
        let ownerUserID = "owner-456"
        let notOwnerUserID = "not-owner-789"
        let family = createMockFamily(id: familyID, ownerUserID: ownerUserID, sharedWithUserIDs: [])

        mockFamilyRepository.families[familyID] = family

        // When & Then
        do {
            _ = try await service.createInvitation(
                familyID: familyID,
                invitingUserID: notOwnerUserID
            )
            XCTFail("Expected error to be thrown")
        } catch let error as InvitationValidationError {
            // Check that the error is the expected type
            if case .notFamilyOwner = error {
                // Success - expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testCreateInvitation_FamilyFull_ThrowsError() async {
        // Given
        let familyID = "family-123"
        let ownerUserID = "owner-456"
        let family = createMockFamily(
            id: familyID,
            ownerUserID: ownerUserID,
            sharedWithUserIDs: ["coparent-1"] // Already has 1 co-parent (max is 2 total)
        )

        mockFamilyRepository.families[familyID] = family

        // When & Then
        do {
            _ = try await service.createInvitation(
                familyID: familyID,
                invitingUserID: ownerUserID
            )
            XCTFail("Expected error to be thrown")
        } catch let error as InvitationValidationError {
            // Check that the error is the expected type
            if case .familyMemberLimitReached(let current, let maximum) = error {
                XCTAssertEqual(current, 2)
                XCTAssertEqual(maximum, 2)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testCreateInvitation_FamilyNotFound_ThrowsError() async {
        // Given
        let familyID = "nonexistent-family"
        let ownerUserID = "owner-456"

        // When & Then
        do {
            _ = try await service.createInvitation(
                familyID: familyID,
                invitingUserID: ownerUserID
            )
            XCTFail("Expected error to be thrown")
        } catch let error as InvitationError {
            XCTAssertEqual(error, .familyNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Accept Invitation Tests

    func testAcceptInvitation_Success() async throws {
        // Given
        let familyID = "family-123"
        let ownerUserID = "owner-456"
        let acceptingUserID = "accepter-789"
        let token = UUID()

        let family = createMockFamily(id: familyID, ownerUserID: ownerUserID, sharedWithUserIDs: [])
        let invitation = createMockInvitation(
            familyID: familyID,
            invitingUserID: ownerUserID,
            token: token,
            isUsed: false,
            expiresAt: Date().addingTimeInterval(3600) // 1 hour from now
        )

        mockFamilyRepository.families[familyID] = family
        mockInvitationRepository.invitations[token] = invitation

        // When
        let result = try await service.validateAndAcceptInvitation(
            token: token,
            acceptingUserID: acceptingUserID
        )

        // Then
        XCTAssertEqual(result.family.id, familyID)
        XCTAssertEqual(result.invitingUserID, ownerUserID)
        XCTAssertEqual(result.acceptingUserID, acceptingUserID)
        XCTAssertTrue(result.family.sharedWithUserIDs.contains(acceptingUserID))

        // Check that invitation was marked as used
        let updatedInvitation = mockInvitationRepository.invitations[token]
        XCTAssertTrue(updatedInvitation?.isUsed ?? false)
    }

    func testAcceptInvitation_ExpiredInvitation_ThrowsError() async {
        // Given
        let familyID = "family-123"
        let ownerUserID = "owner-456"
        let acceptingUserID = "accepter-789"
        let token = UUID()

        let family = createMockFamily(id: familyID, ownerUserID: ownerUserID, sharedWithUserIDs: [])
        let invitation = createMockInvitation(
            familyID: familyID,
            invitingUserID: ownerUserID,
            token: token,
            isUsed: false,
            expiresAt: Date().addingTimeInterval(-3600) // 1 hour ago
        )

        mockFamilyRepository.families[familyID] = family
        mockInvitationRepository.invitations[token] = invitation

        // When & Then
        do {
            _ = try await service.validateAndAcceptInvitation(
                token: token,
                acceptingUserID: acceptingUserID
            )
            XCTFail("Expected error to be thrown")
        } catch let error as InvitationValidationError {
            // Check that the error is the expected type
            if case .invitationExpired = error {
                // Success - expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testAcceptInvitation_AlreadyUsed_ThrowsError() async {
        // Given
        let familyID = "family-123"
        let ownerUserID = "owner-456"
        let acceptingUserID = "accepter-789"
        let token = UUID()

        let family = createMockFamily(id: familyID, ownerUserID: ownerUserID, sharedWithUserIDs: [])
        let invitation = createMockInvitation(
            familyID: familyID,
            invitingUserID: ownerUserID,
            token: token,
            isUsed: true,
            expiresAt: Date().addingTimeInterval(3600)
        )

        mockFamilyRepository.families[familyID] = family
        mockInvitationRepository.invitations[token] = invitation

        // When & Then
        do {
            _ = try await service.validateAndAcceptInvitation(
                token: token,
                acceptingUserID: acceptingUserID
            )
            XCTFail("Expected error to be thrown")
        } catch let error as InvitationValidationError {
            // Check that the error is the expected type
            if case .invitationAlreadyUsed = error {
                // Success - expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testAcceptInvitation_UserAlreadyInFamily_ThrowsError() async {
        // Given
        let familyID = "family-123"
        let ownerUserID = "owner-456"
        let acceptingUserID = "accepter-789"
        let token = UUID()

        let family = createMockFamily(
            id: familyID,
            ownerUserID: ownerUserID,
            sharedWithUserIDs: [acceptingUserID] // User already in family
        )
        let invitation = createMockInvitation(
            familyID: familyID,
            invitingUserID: ownerUserID,
            token: token,
            isUsed: false,
            expiresAt: Date().addingTimeInterval(3600)
        )

        mockFamilyRepository.families[familyID] = family
        mockInvitationRepository.invitations[token] = invitation

        // When & Then
        do {
            _ = try await service.validateAndAcceptInvitation(
                token: token,
                acceptingUserID: acceptingUserID
            )
            XCTFail("Expected error to be thrown")
        } catch let error as InvitationValidationError {
            // Check that the error is the expected type
            if case .userAlreadyInFamily = error {
                // Success - expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helper Methods

    private func createMockFamily(
        id: String,
        ownerUserID: String,
        sharedWithUserIDs: [String]
    ) -> Family {
        return Family(
            id: id,
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: ownerUserID,
            sharedWithUserIDs: sharedWithUserIDs,
            childProfileIDs: ["child-1", "child-2"]
        )
    }

    private func createMockInvitation(
        familyID: String,
        invitingUserID: String,
        token: UUID,
        isUsed: Bool,
        expiresAt: Date
    ) -> FamilyInvitation {
        return FamilyInvitation(
            id: UUID(),
            familyID: familyID,
            invitingUserID: invitingUserID,
            inviteeEmail: nil,
            token: token,
            createdAt: Date(),
            expiresAt: expiresAt,
            isUsed: isUsed,
            deepLinkURL: "screentimerewards://invite/\(token.uuidString)"
        )
    }
}

// MARK: - Mock Repositories

class MockFamilyInvitationRepository: FamilyInvitationRepository {
    var invitations: [UUID: FamilyInvitation] = [:]

    func createInvitation(_ invitation: FamilyInvitation) async throws -> FamilyInvitation {
        invitations[invitation.token] = invitation
        return invitation
    }

    func fetchInvitation(by token: UUID) async throws -> FamilyInvitation? {
        return invitations[token]
    }

    func fetchInvitations(for familyID: String) async throws -> [FamilyInvitation] {
        return invitations.values.filter { $0.familyID == familyID }
    }

    func fetchInvitations(by invitingUserID: String) async throws -> [FamilyInvitation] {
        return invitations.values.filter { $0.invitingUserID == invitingUserID }
    }

    func updateInvitation(_ invitation: FamilyInvitation) async throws -> FamilyInvitation {
        invitations[invitation.token] = invitation
        return invitation
    }

    func deleteInvitation(id: UUID) async throws {
        invitations.removeValue(forKey: id)
    }

    func deleteExpiredInvitations() async throws {
        let now = Date()
        invitations = invitations.filter { _, invitation in
            invitation.expiresAt > now
        }
    }
}

class MockFamilyRepository: FamilyRepository {
    var families: [String: Family] = [:]

    func createFamily(_ family: Family) async throws -> Family {
        families[family.id] = family
        return family
    }

    func fetchFamily(id: String) async throws -> Family? {
        return families[id]
    }

    func fetchFamilies(for userID: String) async throws -> [Family] {
        return families.values.filter { family in
            family.ownerUserID == userID || family.sharedWithUserIDs.contains(userID)
        }
    }

    func updateFamily(_ family: Family) async throws -> Family {
        families[family.id] = family
        return family
    }

    func deleteFamily(id: String) async throws {
        families.removeValue(forKey: id)
    }
}

class MockCloudKitSharingService: CloudKitSharingService {
    var shares: [String: CKShare] = [:]

    override func shareFamily(familyID: String, with userID: String, permission: CKShare.ParticipantPermission = .readWrite) async throws -> CKShare {
        let share = CKShare(rootRecord: CKRecord(recordType: "Family", recordID: CKRecord.ID(recordName: familyID)))
        shares[familyID] = share
        return share
    }

    override func fetchShareForFamily(familyID: String) async throws -> CKShare? {
        return shares[familyID]
    }

    override func shareChildProfileZone(childProfileID: String, with participantUserID: String) async throws {
        // Mock implementation - no-op
    }

    override func createFamilySharingSubscription(for familyID: String) async throws -> CKSubscription {
        return CKQuerySubscription(
            recordType: "Family",
            predicate: NSPredicate(value: true),
            subscriptionID: "family-sharing-\(familyID)",
            options: [.firesOnRecordCreation]
        )
    }
}