import SwiftUI
import SubscriptionService
import SharedModels
import DesignSystem

@available(iOS 15.0, *)
struct SubscriptionDetailsView: View {
    @StateObject private var subscriptionStatusService = SubscriptionStatusService()
    @StateObject private var subscriptionService = SubscriptionService()
    let familyID: String?

    @State private var showingManageSubscription = false
    @State private var showingCancelConfirmation = false
    @State private var showingPlanChange = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    if subscriptionStatusService.isMonitoring {
                        subscriptionStatusCard
                        subscriptionDetailsCard
                        managementOptionsCard
                    } else {
                        loadingView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await subscriptionStatusService.refreshStatus()
            }
            .sheet(isPresented: $showingManageSubscription) {
                manageSubscriptionSheet
            }
            .sheet(isPresented: $showingPlanChange) {
                PlanChangeView(
                    familyID: familyID,
                    currentEntitlement: subscriptionStatusService.currentEntitlement
                )
            }
            .confirmationDialog(
                "Cancel Subscription",
                isPresented: $showingCancelConfirmation,
                titleVisibility: .visible
            ) {
                Button("Go to App Store", role: .none) {
                    openAppStoreSubscriptionSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You can manage your subscription in the App Store. Your access will continue until the end of your current billing period.")
            }
            .task {
                subscriptionStatusService.familyID = familyID
                await subscriptionStatusService.startMonitoring()
            }
            .onDisappear {
                subscriptionStatusService.stopMonitoring()
            }
        }
    }

    private var subscriptionStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(statusColor)

                Text("Subscription Status")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                statusBadge
            }

            if let entitlement = subscriptionStatusService.currentEntitlement {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(entitlement.subscriptionTier.displayName) - \(entitlement.billingPeriod.displayName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var subscriptionDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.fill")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("Billing Information")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            if let entitlement = subscriptionStatusService.currentEntitlement {
                VStack(spacing: 12) {
                    billingInfoRow(
                        label: "Next Billing Date",
                        value: formatBillingDate(entitlement.nextBillingDate)
                    )

                    Divider()

                    billingInfoRow(
                        label: "Auto-Renewal",
                        value: subscriptionStatusService.autoRenewStatus ? "Enabled" : "Disabled"
                    )

                    if let gracePeriodEnd = subscriptionStatusService.gracePeriodExpirationDate {
                        Divider()

                        billingInfoRow(
                            label: "Grace Period Ends",
                            value: formatBillingDate(gracePeriodEnd),
                            isWarning: true
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var managementOptionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "gear.fill")
                    .font(.title2)
                    .foregroundColor(.gray)

                Text("Manage Subscription")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            VStack(spacing: 12) {
                Button(action: {
                    showingPlanChange = true
                }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .foregroundColor(.green)

                        Text("Change Plan")
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    showingManageSubscription = true
                }) {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(.blue)

                        Text("Manage in App Store")
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    showingCancelConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)

                        Text("Cancel Subscription")
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var statusBadge: some View {
        Text(statusDisplayText)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(statusColor)
            )
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading subscription details...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var manageSubscriptionSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "app.badge")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Manage in App Store")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You'll be redirected to the App Store to manage your subscription. You can upgrade, downgrade, or cancel from there.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Button("Open App Store") {
                    openAppStoreSubscriptionSettings()
                    showingManageSubscription = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()
            }
            .padding()
            .navigationTitle("Manage Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingManageSubscription = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helper Views

    private func billingInfoRow(label: String, value: String, isWarning: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isWarning ? .orange : .primary)
        }
    }

    // MARK: - Computed Properties

    private var statusColor: Color {
        guard let status = subscriptionStatusService.currentStatus else {
            return .gray
        }

        switch status {
        case .active:
            return .green
        case .trial:
            return .blue
        case .expired:
            return .red
        case .gracePeriod:
            return .orange
        case .revoked:
            return .red
        }
    }

    private var statusDisplayText: String {
        guard let status = subscriptionStatusService.currentStatus else {
            return "Unknown"
        }

        switch status {
        case .active:
            return "Active"
        case .trial:
            return "Trial"
        case .expired:
            return "Expired"
        case .gracePeriod:
            return "Grace Period"
        case .revoked:
            return "Cancelled"
        }
    }

    // MARK: - Helper Methods

    private func formatBillingDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter.string(from: date)
    }

    private func openAppStoreSubscriptionSettings() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

#if DEBUG
@available(iOS 15.0, *)
#Preview {
    SubscriptionDetailsView(familyID: "preview-family-id")
}
#endif