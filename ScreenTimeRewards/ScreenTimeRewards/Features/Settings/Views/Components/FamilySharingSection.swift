import SwiftUI
import SharedModels
import DesignSystem

struct FamilySharingSection: View {
    @ObservedObject var viewModel: FamilySharingViewModel
    @State private var showingInviteSheet = false
    @State private var showingRemoveConfirmation = false
    @State private var parentToRemove: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Invite Co-Parent Button
            Button(action: {
                showingInviteSheet = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(.blue)

                    Text("Invite Co-Parent")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .disabled(viewModel.isInviteDisabled)

            // Current Co-Parents List
            if !viewModel.coParents.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Co-Parents")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    ForEach(viewModel.coParents, id: \.userID) { parent in
                        coParentRow(parent: parent)
                    }
                }
            }

            // Family Owner Info
            if let owner = viewModel.familyOwner {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Family Owner")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        // Avatar placeholder
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(owner.displayName.prefix(1)))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(owner.displayName)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            HStack(spacing: 4) {
                                Text("Owner")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                roleBadge(for: .owner)
                            }
                        }

                        Spacer()

                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
        }
        .sheet(isPresented: $showingInviteSheet) {
            InviteCoParentSheet(viewModel: viewModel)
        }
        .alert("Remove Co-Parent", isPresented: $showingRemoveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let userID = parentToRemove {
                    Task {
                        await viewModel.removeCoParent(userID: userID)
                    }
                }
            }
        } message: {
            Text("This person will no longer have access to manage your family's screen time settings.")
        }
    }

    private func coParentRow(parent: CoParentInfo) -> some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(Color.green.gradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(parent.displayName.prefix(1)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(parent.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Text(parent.role.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    roleBadge(for: parent.role)
                }
            }

            Spacer()

            // Remove button (only visible to owner)
            if viewModel.isCurrentUserOwner {
                Button(action: {
                    parentToRemove = parent.userID
                    showingRemoveConfirmation = true
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func roleBadge(for role: PermissionRole) -> some View {
        Text(role.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(roleBadgeColor(for: role))
            )
            .foregroundColor(roleBadgeTextColor(for: role))
    }

    private func roleBadgeColor(for role: PermissionRole) -> Color {
        switch role {
        case .owner:
            return Color.orange.opacity(0.2)
        case .coParent:
            return Color.green.opacity(0.2)
        case .viewer:
            return Color.blue.opacity(0.2)
        }
    }

    private func roleBadgeTextColor(for role: PermissionRole) -> Color {
        switch role {
        case .owner:
            return Color.orange
        case .coParent:
            return Color.green
        case .viewer:
            return Color.blue
        }
    }
}

struct CoParentInfo {
    let userID: String
    let displayName: String
    let email: String?
    let joinedAt: Date
    let role: PermissionRole
}

#Preview {
    FamilySharingSection(viewModel: FamilySharingViewModel.mockViewModel())
        .padding()
}