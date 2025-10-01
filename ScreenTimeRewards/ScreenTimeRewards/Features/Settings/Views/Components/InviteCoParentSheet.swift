import SwiftUI
import SharedModels

struct InviteCoParentSheet: View {
    @ObservedObject var viewModel: FamilySharingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var shareItem: ShareItem?

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.2.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)

                    Text("Invite Co-Parent")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Share family management with another parent. They'll be able to manage screen time settings and monitor usage.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // Invite Link Section
                if let inviteLink = viewModel.inviteLink {
                    VStack(spacing: 16) {
                        Text("Invitation Ready!")
                            .font(.headline)
                            .foregroundColor(.green)

                        Text("Share this link with the other parent:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        // Link preview
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Family Invitation")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(inviteLink)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Button(action: {
                                UIPasteboard.general.string = inviteLink
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )

                        // Share button
                        Button(action: {
                            shareItem = ShareItem(
                                subject: "You're invited to manage our family's screen time",
                                text: "Join our family to help manage screen time settings and monitor usage together.",
                                url: URL(string: inviteLink)!
                            )
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Invitation")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                } else {
                    // Create invite button
                    VStack(spacing: 16) {
                        Text("Create a secure invitation link to share with the other parent.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button(action: {
                            Task {
                                await viewModel.createInviteLink()
                            }
                        }) {
                            if viewModel.isCreatingInvite {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Creating Invitation...")
                                }
                            } else {
                                HStack {
                                    Image(systemName: "link.badge.plus")
                                    Text("Create Invitation Link")
                                }
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isCreatingInvite ? Color.gray : Color.blue)
                        .cornerRadius(12)
                        .disabled(viewModel.isCreatingInvite)
                    }
                }

                Spacer()

                // Info section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Important")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Invitation links expire after 72 hours")
                        Text("• Only one co-parent can be added per family")
                        Text("• Co-parents have full access to manage settings")
                        Text("• Only family owners can remove co-parents")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            .padding()
            .navigationTitle("Invite Co-Parent")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(shareItem: item)
        }
    }
}

struct ShareItem: Identifiable {
    let id = UUID()
    let subject: String
    let text: String
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let shareItem: ShareItem

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let items: [Any] = [shareItem.text, shareItem.url]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.setValue(shareItem.subject, forKey: "subject")
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    InviteCoParentSheet(viewModel: FamilySharingViewModel.mockViewModel())
}