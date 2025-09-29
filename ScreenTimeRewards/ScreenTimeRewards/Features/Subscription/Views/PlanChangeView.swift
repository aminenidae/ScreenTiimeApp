import SwiftUI
import SubscriptionService
import SharedModels
import DesignSystem

@available(iOS 15.0, *)
struct PlanChangeView: View {
    @StateObject private var subscriptionService = SubscriptionService()
    @StateObject private var subscriptionStatusService = SubscriptionStatusService()
    @Environment(\.dismiss) private var dismiss

    let familyID: String?
    let currentEntitlement: SubscriptionEntitlementInfo?

    @State private var selectedProduct: SubscriptionProduct?
    @State private var isLoading = false
    @State private var showingPurchaseError = false
    @State private var errorMessage = ""
    @State private var showingDowngradeWarning = false
    @State private var showingSuccessMessage = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if subscriptionService.isLoading && subscriptionService.availableProducts.isEmpty {
                        loadingView
                    } else {
                        currentPlanSection
                        availablePlansSection
                        planComparisonSection
                        upgradeDowngradeInfo
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Change Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Continue") {
                        handlePlanChange()
                    }
                    .disabled(selectedProduct == nil || selectedProduct?.id == currentEntitlement?.productID)
                }
            }
            .task {
                await subscriptionService.fetchProducts()
            }
            .alert("Purchase Error", isPresented: $showingPurchaseError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Plan Changed Successfully", isPresented: $showingSuccessMessage) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your subscription plan has been updated. Changes take effect immediately.")
            }
            .confirmationDialog(
                "Confirm Downgrade",
                isPresented: $showingDowngradeWarning,
                titleVisibility: .visible
            ) {
                Button("Continue Downgrade", role: .destructive) {
                    performPlanChange()
                }
                Button("Cancel", role: .cancel) {
                    selectedProduct = nil
                }
            } message: {
                Text("Downgrading may affect your family's access. Some child profiles may need to be removed if they exceed the new plan's limit.")
            }
        }
    }

    private var currentPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.orange)

                Text("Current Plan")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            if let entitlement = currentEntitlement {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(entitlement.subscriptionTier.displayName) - \(entitlement.billingPeriod.displayName)")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Next billing: \(formatDate(entitlement.nextBillingDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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

    private var availablePlansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.title3)
                    .foregroundColor(.blue)

                Text("Available Plans")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(subscriptionService.availableProducts) { product in
                    planCard(product: product)
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

    private func planCard(product: SubscriptionProduct) -> some View {
        let isCurrentPlan = product.id == currentEntitlement?.productID
        let isSelected = product.id == selectedProduct?.id
        let isUpgrade = isUpgrade(from: currentEntitlement, to: product)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(planDisplayName(for: product))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(product.subscriptionPeriod.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isCurrentPlan {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Text(product.priceFormatted)
                .font(.title3)
                .fontWeight(.bold)

            if isUpgrade && !isCurrentPlan {
                Text("Upgrade")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            } else if !isUpgrade && !isCurrentPlan {
                Text("Downgrade")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.accentColor : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .onTapGesture {
            if !isCurrentPlan {
                selectedProduct = product
            }
        }
        .disabled(isCurrentPlan)
    }

    private var planComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(.purple)

                Text("Plan Comparison")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            VStack(spacing: 12) {
                planComparisonRow(feature: "1 Child Plan", oneChild: "✓", twoChild: "✓")
                Divider()
                planComparisonRow(feature: "2 Children Plan", oneChild: "—", twoChild: "✓")
                Divider()
                planComparisonRow(feature: "Family Sharing", oneChild: "✓", twoChild: "✓")
                Divider()
                planComparisonRow(feature: "Cloud Sync", oneChild: "✓", twoChild: "✓")
                Divider()
                planComparisonRow(feature: "Premium Analytics", oneChild: "✓", twoChild: "✓")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func planComparisonRow(feature: String, oneChild: String, twoChild: String) -> some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(oneChild)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 40)

            Text(twoChild)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 40)
        }
    }

    private var upgradeDowngradeInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)

                Text("Important Information")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("• Plan changes take effect immediately")
                Text("• Billing is prorated by Apple automatically")
                Text("• Downgrades may require removing some child profiles")
                Text("• Your data will be preserved during plan changes")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading available plans...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Helper Methods

    private func planDisplayName(for product: SubscriptionProduct) -> String {
        switch product.id {
        case ProductIdentifiers.oneChildMonthly, ProductIdentifiers.oneChildYearly:
            return "1 Child"
        case ProductIdentifiers.twoChildMonthly, ProductIdentifiers.twoChildYearly:
            return "2 Children"
        default:
            return product.displayName
        }
    }

    private func isUpgrade(from currentEntitlement: SubscriptionEntitlementInfo?, to product: SubscriptionProduct) -> Bool {
        guard let currentEntitlement = currentEntitlement else { return true }

        let currentTier = currentEntitlement.subscriptionTier
        let newTier = subscriptionTierFromProductID(product.id)

        return newTier.maxChildren > currentTier.maxChildren ||
               (newTier == currentTier && product.subscriptionPeriod.unit == .year && currentEntitlement.billingPeriod == .monthly)
    }

    private func subscriptionTierFromProductID(_ productID: String) -> SubscriptionTier {
        switch productID {
        case ProductIdentifiers.oneChildMonthly, ProductIdentifiers.oneChildYearly:
            return .oneChild
        case ProductIdentifiers.twoChildMonthly, ProductIdentifiers.twoChildYearly:
            return .twoChildren
        default:
            return .oneChild
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter.string(from: date)
    }

    private func handlePlanChange() {
        guard let product = selectedProduct else { return }
        guard let currentEntitlement = currentEntitlement else { return }

        let newTier = subscriptionTierFromProductID(product.id)
        let isDowngrade = newTier.maxChildren < currentEntitlement.subscriptionTier.maxChildren

        if isDowngrade {
            showingDowngradeWarning = true
        } else {
            performPlanChange()
        }
    }

    private func performPlanChange() {
        guard let product = selectedProduct else { return }

        Task {
            await MainActor.run {
                isLoading = true
            }

            do {
                let result = try await subscriptionService.purchase(product.id)

                await MainActor.run {
                    isLoading = false

                    switch result {
                    case .success:
                        showingSuccessMessage = true
                    case .userCancelled:
                        // User cancelled - no action needed
                        break
                    case .pending:
                        errorMessage = "Purchase is pending. Please check your payment method."
                        showingPurchaseError = true
                    @unknown default:
                        errorMessage = "An unknown error occurred during the plan change."
                        showingPurchaseError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingPurchaseError = true
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 15.0, *)
#Preview {
    let mockEntitlement = SubscriptionEntitlementInfo(
        productID: ProductIdentifiers.oneChildMonthly,
        purchaseDate: Date(),
        expirationDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
        isAutoRenewOn: true,
        willAutoRenew: true
    )

    return PlanChangeView(
        familyID: "preview-family-id",
        currentEntitlement: mockEntitlement
    )
}
#endif