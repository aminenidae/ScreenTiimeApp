import Foundation
import SharedModels
@testable import RewardCore
import CloudKit
import CloudKitService

// MARK: - Mock Repositories

class MockChildProfileRepository: ChildProfileRepository {
    var mockChild: ChildProfile?
    var mockChildren: [ChildProfile] = []
    var createdChildren: [ChildProfile] = []
    var updatedChildren: [ChildProfile] = []
    var shouldThrowError = false
    var createChildCalled = false
    var updateChildCalled = false
    var deleteChildCalled = false
    var fetchChildCalled = false
    var fetchChildrenCalled = false

    func createChild(_ child: ChildProfile) async throws -> ChildProfile {
        if shouldThrowError { throw MockError.repositoryError }
        createChildCalled = true
        createdChildren.append(child)
        return child
    }

    func fetchChild(id: String) async throws -> ChildProfile? {
        if shouldThrowError { throw MockError.repositoryError }
        fetchChildCalled = true
        return mockChild?.id == id ? mockChild : nil
    }

    func fetchChildren(for familyID: String) async throws -> [ChildProfile] {
        if shouldThrowError { throw MockError.repositoryError }
        fetchChildrenCalled = true
        if let child = mockChild, child.familyID == familyID {
            return [child]
        }
        return mockChildren.filter { $0.familyID == familyID }
    }

    func updateChild(_ child: ChildProfile) async throws -> ChildProfile {
        if shouldThrowError { throw MockError.repositoryError }
        updateChildCalled = true
        updatedChildren.append(child)
        return child
    }

    func deleteChild(id: String) async throws {
        if shouldThrowError { throw MockError.repositoryError }
        deleteChildCalled = true
    }
}

class MockAppCategorizationRepository: AppCategorizationRepository {
    var mockCategorization: AppCategorization?
    var mockCategorizations: [AppCategorization] = []
    var createdCategorizations: [AppCategorization] = []
    var updatedCategorizations: [AppCategorization] = []
    var shouldThrowError = false
    var createCalled = false
    var updateCalled = false
    var deleteCalled = false
    var fetchCalled = false

    func createAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization {
        if shouldThrowError { throw MockError.repositoryError }
        createCalled = true
        createdCategorizations.append(categorization)
        return categorization
    }

    func fetchAppCategorization(id: String) async throws -> AppCategorization? {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        return mockCategorization?.id == id ? mockCategorization : nil
    }

    func fetchAppCategorizations(for childID: String) async throws -> [AppCategorization] {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        if let categorization = mockCategorization, categorization.childProfileID == childID {
            return [categorization]
        }
        return mockCategorizations.filter { $0.childProfileID == childID }
    }

    func updateAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization {
        if shouldThrowError { throw MockError.repositoryError }
        updateCalled = true
        updatedCategorizations.append(categorization)
        return categorization
    }

    func deleteAppCategorization(id: String) async throws {
        if shouldThrowError { throw MockError.repositoryError }
        deleteCalled = true
    }
}

class MockFamilyRepository: FamilyRepository {
    var mockFamily: Family?
    var mockFamilies: [Family] = []
    var createdFamilies: [Family] = []
    var updatedFamilies: [Family] = []
    var shouldThrowError = false
    var createFamilyCalled = false
    var updateFamilyCalled = false
    var deleteFamilyCalled = false
    var fetchFamilyCalled = false

    func createFamily(_ family: Family) async throws -> Family {
        if shouldThrowError { throw MockError.repositoryError }
        createFamilyCalled = true
        createdFamilies.append(family)
        mockFamily = family
        return family
    }

    func fetchFamily(id: String) async throws -> Family? {
        if shouldThrowError { throw MockError.repositoryError }
        fetchFamilyCalled = true
        return mockFamily?.id == id ? mockFamily : nil
    }

    func fetchFamilies(for userID: String) async throws -> [Family] {
        if shouldThrowError { throw MockError.repositoryError }
        if let family = mockFamily,
           family.ownerUserID == userID || family.sharedWithUserIDs.contains(userID) {
            return [family]
        }
        return mockFamilies.filter { family in
            family.ownerUserID == userID || family.sharedWithUserIDs.contains(userID)
        }
    }

    func updateFamily(_ family: Family) async throws -> Family {
        if shouldThrowError { throw MockError.repositoryError }
        updateFamilyCalled = true
        updatedFamilies.append(family)
        mockFamily = family
        return family
    }

    func deleteFamily(id: String) async throws {
        if shouldThrowError { throw MockError.repositoryError }
        deleteFamilyCalled = true
        if mockFamily?.id == id {
            mockFamily = nil
        }
    }
}

class MockUsageSessionRepository: UsageSessionRepository {
    var mockSession: UsageSession?
    var mockSessions: [UsageSession] = []
    var createdSessions: [UsageSession] = []
    var updatedSessions: [UsageSession] = []
    var shouldThrowError = false
    var createCalled = false
    var updateCalled = false
    var deleteCalled = false
    var fetchCalled = false

    func createSession(_ session: UsageSession) async throws -> UsageSession {
        if shouldThrowError { throw MockError.repositoryError }
        createCalled = true
        createdSessions.append(session)
        return session
    }

    func fetchSession(id: String) async throws -> UsageSession? {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        return mockSession?.id == id ? mockSession : nil
    }

    func fetchSessions(for childID: String, dateRange: DateRange?) async throws -> [UsageSession] {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        if let session = mockSession, session.childProfileID == childID {
            return [session]
        }
        return mockSessions.filter { $0.childProfileID == childID }
    }

    func updateSession(_ session: UsageSession) async throws -> UsageSession {
        if shouldThrowError { throw MockError.repositoryError }
        updateCalled = true
        updatedSessions.append(session)
        return session
    }

    func deleteSession(id: String) async throws {
        if shouldThrowError { throw MockError.repositoryError }
        deleteCalled = true
    }
}

class MockPointTransactionRepository: PointTransactionRepository {
    var mockTransaction: PointTransaction?
    var mockTransactions: [PointTransaction] = []
    var createdTransactions: [PointTransaction] = []
    var updatedTransactions: [PointTransaction] = []
    var shouldThrowError = false
    var createCalled = false
    var updateCalled = false
    var deleteCalled = false
    var fetchCalled = false

    func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction {
        if shouldThrowError { throw MockError.repositoryError }
        createCalled = true
        createdTransactions.append(transaction)
        return transaction
    }

    func fetchTransaction(id: String) async throws -> PointTransaction? {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        return mockTransaction?.id == id ? mockTransaction : nil
    }

    func fetchTransactions(for childID: String, limit: Int?) async throws -> [PointTransaction] {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        if let transaction = mockTransaction, transaction.childProfileID == childID {
            return [transaction]
        }
        return mockTransactions.filter { $0.childProfileID == childID }
    }

    func fetchTransactions(for childID: String, dateRange: DateRange?) async throws -> [PointTransaction] {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        if let transaction = mockTransaction, transaction.childProfileID == childID {
            return [transaction]
        }
        return mockTransactions.filter { $0.childProfileID == childID }
    }

    func deleteTransaction(id: String) async throws {
        if shouldThrowError { throw MockError.repositoryError }
        deleteCalled = true
    }
}

class MockPointToTimeRedemptionRepository: PointToTimeRedemptionRepository {
    var mockRedemption: PointToTimeRedemption?
    var mockRedemptions: [PointToTimeRedemption] = []
    var createdRedemptions: [PointToTimeRedemption] = []
    var updatedRedemptions: [PointToTimeRedemption] = []
    var shouldThrowError = false
    var createCalled = false
    var updateCalled = false
    var deleteCalled = false
    var fetchCalled = false

    func createPointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption {
        if shouldThrowError { throw MockError.repositoryError }
        createCalled = true
        createdRedemptions.append(redemption)
        return redemption
    }

    func fetchPointToTimeRedemption(id: String) async throws -> PointToTimeRedemption? {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        return mockRedemption?.id == id ? mockRedemption : nil
    }

    func fetchPointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption] {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        if let redemption = mockRedemption, redemption.childProfileID == childID {
            return [redemption]
        }
        return mockRedemptions.filter { $0.childProfileID == childID }
    }

    func fetchActivePointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption] {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        return mockRedemptions.filter { $0.childProfileID == childID && $0.status == .active }
    }

    func updatePointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption {
        if shouldThrowError { throw MockError.repositoryError }
        updateCalled = true
        updatedRedemptions.append(redemption)
        return redemption
    }

    func deletePointToTimeRedemption(id: String) async throws {
        if shouldThrowError { throw MockError.repositoryError }
        deleteCalled = true
    }
}

// MARK: - Mock CloudKit Service

class MockCloudKitService {
    var mockFamily: Family?
    var mockFamilies: [Family] = []
    var shouldThrowError = false
    
    func fetchFamily(id: String) async throws -> Family? {
        if shouldThrowError { throw MockError.cloudKitError }
        return mockFamily?.id == id ? mockFamily : nil
    }
    
    func fetchFamilies(for userID: String) async throws -> [Family] {
        if shouldThrowError { throw MockError.cloudKitError }
        if let family = mockFamily,
           family.ownerUserID == userID || family.sharedWithUserIDs.contains(userID) {
            return [family]
        }
        return mockFamilies.filter { family in
            family.ownerUserID == userID || family.sharedWithUserIDs.contains(userID)
        }
    }
    
    func saveFamily(_ family: Family) async throws {
        if shouldThrowError { throw MockError.cloudKitError }
        mockFamily = family
    }
}

// MARK: - Mock Family Invitation Repository

class MockFamilyInvitationRepository: FamilyInvitationRepository {
    var invitations: [UUID: FamilyInvitation] = [:]
    var shouldThrowError = false
    var createCalled = false
    var fetchCalled = false
    var updateCalled = false

    func createInvitation(_ invitation: FamilyInvitation) async throws -> FamilyInvitation {
        if shouldThrowError { throw MockError.repositoryError }
        createCalled = true
        invitations[invitation.token] = invitation
        return invitation
    }

    func fetchInvitation(by token: UUID) async throws -> FamilyInvitation? {
        if shouldThrowError { throw MockError.repositoryError }
        fetchCalled = true
        return invitations[token]
    }

    func fetchInvitations(for familyID: String) async throws -> [FamilyInvitation] {
        if shouldThrowError { throw MockError.repositoryError }
        return Array(invitations.values).filter { $0.familyID == familyID }
    }

    func fetchInvitations(by invitingUserID: String) async throws -> [FamilyInvitation] {
        if shouldThrowError { throw MockError.repositoryError }
        return Array(invitations.values).filter { $0.invitingUserID == invitingUserID }
    }

    func updateInvitation(_ invitation: FamilyInvitation) async throws -> FamilyInvitation {
        if shouldThrowError { throw MockError.repositoryError }
        updateCalled = true
        invitations[invitation.token] = invitation
        return invitation
    }

    func deleteInvitation(id: UUID) async throws {
        if shouldThrowError { throw MockError.repositoryError }
        invitations.removeValue(forKey: id)
    }

    func deleteExpiredInvitations() async throws {
        if shouldThrowError { throw MockError.repositoryError }
        let now = Date()
        invitations = invitations.filter { $0.value.expiresAt > now }
    }
}

// MARK: - Mock Error

enum MockError: Error {
    case repositoryError
    case cloudKitError
}

extension MockError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .repositoryError:
            return "Mock repository error"
        case .cloudKitError:
            return "Mock CloudKit error"
        }
    }
}

// MARK: - Test Data Helpers

func createMockFamily(id: String = UUID().uuidString, name: String = "Test Family", ownerUserID: String, sharedWithUserIDs: [String] = [], childProfileIDs: [String] = []) -> Family {
    return Family(
        id: id,
        name: name,
        createdAt: Date(),
        ownerUserID: ownerUserID,
        sharedWithUserIDs: sharedWithUserIDs,
        childProfileIDs: childProfileIDs,
        userRoles: [ownerUserID: .owner]
    )
}