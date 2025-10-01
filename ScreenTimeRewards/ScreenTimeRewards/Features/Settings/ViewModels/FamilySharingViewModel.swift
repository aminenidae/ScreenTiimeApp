import SwiftUI
import Combine
import SharedModels
import CloudKitService
import RewardCore

@MainActor
class FamilySharingViewModel: ObservableObject {
    @Published var coParents: [CoParentInfo] = []
    @Published var familyOwner: CoParentInfo?
    @Published var isCurrentUserOwner = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var inviteLink: String?
    @Published var isCreatingInvite = false

    private var familyRepository: FamilyRepository?
    private var familyInvitationService: FamilyInvitationService?
    private var currentFamily: Family?
    private var currentUserID: String?
    private var cancellables = Set<AnyCancellable>()

    // Computed properties
    var isInviteDisabled: Bool {
        !isCurrentUserOwner || coParents.count >= 1 // Max 2 parents total (owner + 1 co-parent)
    }

    init(
        familyRepository: FamilyRepository? = nil,
        familyInvitationService: FamilyInvitationService? = nil
    ) {
        self.familyRepository = familyRepository
        self.familyInvitationService = familyInvitationService
    }

    func loadFamilyData(familyID: String, currentUserID: String) async {
        self.currentUserID = currentUserID
        isLoading = true
        defer { isLoading = false }

        do {
            guard let repository = familyRepository else {
                // Mock data for preview/testing
                await loadMockData(familyID: familyID, currentUserID: currentUserID)
                return
            }

            let family = try await repository.fetchFamily(id: familyID)
            guard let family = family else {
                showError(message: "Family not found")
                return
            }

            self.currentFamily = family
            self.isCurrentUserOwner = family.ownerUserID == currentUserID

            // Load family owner info
            familyOwner = CoParentInfo(
                userID: family.ownerUserID,
                displayName: "Family Owner", // TODO: Get actual name from CloudKit
                email: nil,
                joinedAt: family.createdAt,
                role: .owner
            )

            // Load co-parents info
            coParents = family.sharedWithUserIDs.map { userID in
                let role = family.userRoles[userID] ?? .coParent
                return CoParentInfo(
                    userID: userID,
                    displayName: "Co-Parent", // TODO: Get actual name from CloudKit
                    email: nil,
                    joinedAt: Date(), // TODO: Get actual join date
                    role: role
                )
            }

        } catch {
            showError(message: "Failed to load family data: \(error.localizedDescription)")
        }
    }

    func createInviteLink() async {
        guard let family = currentFamily,
              let currentUserID = currentUserID,
              isCurrentUserOwner else {
            showError(message: "Only family owners can create invitations")
            return
        }

        isCreatingInvite = true
        defer { isCreatingInvite = false }

        do {
            guard let service = familyInvitationService else {
                // Mock invite link for preview/testing
                inviteLink = "screentimerewards://invite/\(UUID().uuidString)"
                return
            }

            let invitation = try await service.createInvitation(
                familyID: family.id,
                invitingUserID: currentUserID
            )

            inviteLink = invitation.deepLinkURL

        } catch {
            showError(message: "Failed to create invitation: \(error.localizedDescription)")
        }
    }

    func removeCoParent(userID: String) async {
        guard let family = currentFamily,
              isCurrentUserOwner else {
            showError(message: "Only family owners can remove co-parents")
            return
        }

        do {
            guard let repository = familyRepository else {
                // Mock removal for preview/testing
                coParents.removeAll { $0.userID == userID }
                return
            }

            var updatedFamily = family
            updatedFamily.sharedWithUserIDs.removeAll { $0 == userID }

            let savedFamily = try await repository.updateFamily(updatedFamily)
            currentFamily = savedFamily

            // Update local state
            coParents.removeAll { $0.userID == userID }

        } catch {
            showError(message: "Failed to remove co-parent: \(error.localizedDescription)")
        }
    }

    func acceptInvitation(token: UUID, acceptingUserID: String) async -> Bool {
        do {
            guard let service = familyInvitationService else {
                showError(message: "Service unavailable")
                return false
            }

            let result = try await service.validateAndAcceptInvitation(
                token: token,
                acceptingUserID: acceptingUserID
            )

            // Update local state if this is the current family
            if result.family.id == currentFamily?.id {
                currentFamily = result.family
                await loadFamilyData(familyID: result.family.id, currentUserID: currentUserID ?? "")
            }

            return true

        } catch {
            showError(message: "Failed to accept invitation: \(error.localizedDescription)")
            return false
        }
    }

    private func loadMockData(familyID: String, currentUserID: String) async {
        // Mock data for preview/testing
        let mockFamily = Family(
            id: familyID,
            name: "Smith Family",
            createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 30 days ago
            ownerUserID: currentUserID,
            sharedWithUserIDs: ["mock-coparent-1"],
            childProfileIDs: ["mock-child-1", "mock-child-2"]
        )

        currentFamily = mockFamily
        isCurrentUserOwner = true

        familyOwner = CoParentInfo(
            userID: currentUserID,
            displayName: "John Smith",
            email: "john.smith@example.com",
            joinedAt: mockFamily.createdAt,
            role: .owner
        )

        coParents = [
            CoParentInfo(
                userID: "mock-coparent-1",
                displayName: "Jane Smith",
                email: "jane.smith@example.com",
                joinedAt: Date().addingTimeInterval(-7 * 24 * 60 * 60), // 7 days ago
                role: .coParent
            )
        ]
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Mock Data

extension FamilySharingViewModel {
    static func mockViewModel() -> FamilySharingViewModel {
        let viewModel = FamilySharingViewModel()

        viewModel.familyOwner = CoParentInfo(
            userID: "mock-owner",
            displayName: "John Smith",
            email: "john.smith@example.com",
            joinedAt: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            role: .owner
        )

        viewModel.coParents = [
            CoParentInfo(
                userID: "mock-coparent-1",
                displayName: "Jane Smith",
                email: "jane.smith@example.com",
                joinedAt: Date().addingTimeInterval(-7 * 24 * 60 * 60),
                role: .coParent
            )
        ]

        viewModel.isCurrentUserOwner = true
        return viewModel
    }
}