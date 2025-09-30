import SwiftUI
import SharedModels

struct InvitationAcceptanceView: View {
    let invitation: InvitationDetails
    @ObservedObject var deepLinkHandler: DeepLinkHandler
    @Environment(\.dismiss) private var dismiss
    @State private var isAccepting = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.2.badge.plus")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text("Family Invitation")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("You've been invited to join a family")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                // Invitation Details
                VStack(spacing: 20) {
                    // Family Info Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.title2)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Family")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(invitation.familyName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }

                        Divider()

                        HStack {
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundColor(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Invited by")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(invitation.invitingUserName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }

                        Divider()

                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.title2)
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Expires")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(formatExpirationDate(invitation.expiresAt))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(invitation.expiresAt < Date() ? .red : .primary)
                            }

                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )

                    // Permissions Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text("As a co-parent, you'll be able to:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            PermissionRow(icon: "clock", text: "Manage screen time limits and bedtime controls")
                            PermissionRow(icon: "apps.iphone", text: "Set app restrictions and categorizations")
                            PermissionRow(icon: "chart.bar", text: "View usage reports and analytics")
                            PermissionRow(icon: "bell", text: "Receive notifications about family activity")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
                    if invitation.isValid {
                        Button(action: {
                            Task {
                                await acceptInvitation()
                            }
                        }) {
                            if isAccepting {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Joining Family...")
                                }
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Accept Invitation")
                                }
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isAccepting ? Color.gray : Color.blue)
                        .cornerRadius(12)
                        .disabled(isAccepting)
                    } else {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("This invitation has expired or is no longer valid")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }

                            Text("Please ask the family owner to send a new invitation.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                    }

                    Button("Not Now") {
                        deepLinkHandler.dismissInvitation()
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func acceptInvitation() async {
        isAccepting = true
        defer { isAccepting = false }

        // TODO: Get current user ID from auth service
        let currentUserID = "current-user-id"

        let success = await deepLinkHandler.acceptInvitation(currentUserID: currentUserID)

        if success {
            // Show success message or navigate to family dashboard
            dismiss()
        } else {
            errorMessage = "Failed to join family. Please try again."
            showError = true
        }
    }

    private func formatExpirationDate(_ date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)

        if timeInterval < 0 {
            return "Expired"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minutes"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hours"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) days"
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.green)
                .frame(width: 20)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

#Preview {
    InvitationAcceptanceView(
        invitation: InvitationDetails(
            token: UUID(),
            familyName: "Smith Family",
            invitingUserName: "John Smith",
            expiresAt: Date().addingTimeInterval(24 * 60 * 60),
            isValid: true
        ),
        deepLinkHandler: DeepLinkHandler()
    )
}