import SwiftUI
import Foundation
import SharedModels
import RewardCore

@MainActor
class DeepLinkHandler: ObservableObject {
    @Published var pendingInvitation: InvitationDetails?
    @Published var showInvitationSheet = false

    private var familyInvitationService: FamilyInvitationService?

    init(familyInvitationService: FamilyInvitationService? = nil) {
        self.familyInvitationService = familyInvitationService
    }

    func handleURL(_ url: URL) {
        guard url.scheme == "screentimerewards" else { return }

        switch url.host {
        case "invite":
            handleInvitationURL(url)
        default:
            print("Unknown deep link host: \(url.host ?? "nil")")
        }
    }

    private func handleInvitationURL(_ url: URL) {
        // Extract token from URL path
        let pathComponents = url.pathComponents
        guard pathComponents.count >= 2,
              pathComponents[0] == "/",
              let token = UUID(uuidString: pathComponents[1]) else {
            print("Invalid invitation URL format: \(url)")
            return
        }

        Task {
            await loadInvitationDetails(token: token)
        }
    }

    private func loadInvitationDetails(token: UUID) async {
        do {
            guard let service = familyInvitationService else {
                // Mock invitation for preview/testing
                pendingInvitation = InvitationDetails(
                    token: token,
                    familyName: "Smith Family",
                    invitingUserName: "John Smith",
                    expiresAt: Date().addingTimeInterval(24 * 60 * 60),
                    isValid: true
                )
                showInvitationSheet = true
                return
            }

            let invitation = try await service.getInvitationDetails(token: token)
            guard let invitation = invitation else {
                print("Invitation not found for token: \(token)")
                return
            }

            // TODO: Fetch family and user details from CloudKit
            pendingInvitation = InvitationDetails(
                token: token,
                familyName: "Family", // TODO: Get actual family name
                invitingUserName: "Parent", // TODO: Get actual user name
                expiresAt: invitation.expiresAt,
                isValid: !invitation.isUsed && invitation.expiresAt > Date()
            )

            showInvitationSheet = true

        } catch {
            print("Failed to load invitation details: \(error)")
        }
    }

    func acceptInvitation(currentUserID: String) async -> Bool {
        guard let invitation = pendingInvitation,
              let service = familyInvitationService else {
            return false
        }

        do {
            _ = try await service.validateAndAcceptInvitation(
                token: invitation.token,
                acceptingUserID: currentUserID
            )

            pendingInvitation = nil
            showInvitationSheet = false
            return true

        } catch {
            print("Failed to accept invitation: \(error)")
            return false
        }
    }

    func dismissInvitation() {
        pendingInvitation = nil
        showInvitationSheet = false
    }
}

struct InvitationDetails {
    let token: UUID
    let familyName: String
    let invitingUserName: String
    let expiresAt: Date
    let isValid: Bool
}