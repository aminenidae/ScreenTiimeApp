import SwiftUI
import DesignSystem
import SharedModels
import SubscriptionService

struct PaywallView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var selectedChildCount: Int = 1
    @State private var isAnnual: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    headerSection
                    planSelectionSection
                    pricingToggleSection
                    pricingComparisonSection
                    trialOfferSection
                    purchaseButtonSection
                }
                .padding(Spacing.md)
            }
            .background(Color(red: DesignSystemColor.backgroundPrimary.red,
                            green: DesignSystemColor.backgroundPrimary.green,
                            blue: DesignSystemColor.backgroundPrimary.blue))
            .navigationTitle("Choose Your Plan")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(leading: Button("Close") { dismiss() })
        }
        .task {
            await viewModel.fetchProducts()
        }
        .sheet(isPresented: $viewModel.showingSuccessView) {
            PurchaseSuccessView(
                productName: selectedProductDisplayName,
                onContinue: {
                    viewModel.dismissSuccessView()
                    dismiss()
                }
            )
        }
        .sheet(isPresented: .constant(viewModel.error != nil)) {
            if let error = viewModel.error {
                PurchaseErrorView(
                    error: error,
                    onRetry: {
                        viewModel.clearError()
                        Task { await viewModel.startPurchase(for: selectedProductId) }
                    },
                    onCancel: {
                        viewModel.clearError()
                    },
                    onContactSupport: {
                        openSupportContact()
                    }
                )
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(red: DesignSystemColor.accent.red,
                                     green: DesignSystemColor.accent.green,
                                     blue: DesignSystemColor.accent.blue))

            Text("Unlock Premium Features")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                     green: DesignSystemColor.textPrimary.green,
                                     blue: DesignSystemColor.textPrimary.blue))

            Text("Get unlimited screen time rewards, advanced analytics, and family sync")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                     green: DesignSystemColor.textSecondary.green,
                                     blue: DesignSystemColor.textSecondary.blue))
        }
        .padding(.top, Spacing.lg)
    }

    private var planSelectionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Number of Children")
                .font(.headline)
                .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                     green: DesignSystemColor.textPrimary.green,
                                     blue: DesignSystemColor.textPrimary.blue))

            HStack(spacing: Spacing.sm) {
                ForEach([1, 2, 3], id: \.self) { count in
                    Button(action: { selectedChildCount = count }) {
                        HStack {
                            Text(count == 3 ? "3+" : "\(count)")
                                .font(.system(size: 16, weight: .semibold))

                            if count == 3 {
                                Text("child\(count > 1 ? "ren" : "")")
                                    .font(.caption)
                            } else {
                                Text("child\(count > 1 ? "ren" : "")")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(selectedChildCount == count ? .white : DesignSystemColor.primaryBrand.color)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedChildCount == count ? DesignSystemColor.primaryBrand.color : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(DesignSystemColor.primaryBrand.color, lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var pricingToggleSection: some View {
        HStack {
            Text("Monthly")
                .font(.subheadline)
                .fontWeight(isAnnual ? .regular : .semibold)
                .foregroundColor(isAnnual ? Color(red: DesignSystemColor.textSecondary.red,
                                                green: DesignSystemColor.textSecondary.green,
                                                blue: DesignSystemColor.textSecondary.blue) :
                               Color(red: DesignSystemColor.textPrimary.red,
                                   green: DesignSystemColor.textPrimary.green,
                                   blue: DesignSystemColor.textPrimary.blue))

            Toggle("", isOn: $isAnnual)
                .toggleStyle(SwitchToggleStyle(tint: DesignSystemColor.primaryBrand.color))
                .scaleEffect(0.8)

            HStack(spacing: 4) {
                Text("Annual")
                    .font(.subheadline)
                    .fontWeight(isAnnual ? .semibold : .regular)
                    .foregroundColor(isAnnual ? Color(red: DesignSystemColor.textPrimary.red,
                                                    green: DesignSystemColor.textPrimary.green,
                                                    blue: DesignSystemColor.textPrimary.blue) :
                                   Color(red: DesignSystemColor.textSecondary.red,
                                       green: DesignSystemColor.textSecondary.green,
                                       blue: DesignSystemColor.textSecondary.blue))

                if isAnnual {
                    Text("SAVE \(savingsPercentage)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(DesignSystemColor.success.color)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var pricingComparisonSection: some View {
        VStack(spacing: Spacing.md) {
            VStack(spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected Plan")
                            .font(.headline)
                            .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                                 green: DesignSystemColor.textPrimary.green,
                                                 blue: DesignSystemColor.textPrimary.blue))

                        Text("\(selectedChildCount == 3 ? "3+" : "\(selectedChildCount)") child\(selectedChildCount > 1 ? "ren" : "") • \(isAnnual ? "Yearly" : "Monthly")")
                            .font(.subheadline)
                            .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                                 green: DesignSystemColor.textSecondary.green,
                                                 blue: DesignSystemColor.textSecondary.blue))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(currentPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                                 green: DesignSystemColor.textPrimary.green,
                                                 blue: DesignSystemColor.textPrimary.blue))

                        Text("per \(isAnnual ? "year" : "month")")
                            .font(.caption)
                            .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                                 green: DesignSystemColor.textSecondary.green,
                                                 blue: DesignSystemColor.textSecondary.blue))
                    }
                }

                if isAnnual {
                    HStack {
                        Text("Monthly equivalent: \(monthlyEquivalent)")
                            .font(.caption)
                            .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                                 green: DesignSystemColor.textSecondary.green,
                                                 blue: DesignSystemColor.textSecondary.blue))
                        Spacer()
                        Text("Save \(annualSavings) per year")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: DesignSystemColor.success.red,
                                                 green: DesignSystemColor.success.green,
                                                 blue: DesignSystemColor.success.blue))
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color(red: DesignSystemColor.backgroundSecondary.red,
                            green: DesignSystemColor.backgroundSecondary.green,
                            blue: DesignSystemColor.backgroundSecondary.blue))
            .cornerRadius(12)
        }
        .padding(.horizontal, Spacing.md)
    }

    private var trialOfferSection: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(Color(red: DesignSystemColor.accent.red,
                                         green: DesignSystemColor.accent.green,
                                         blue: DesignSystemColor.accent.blue))
                Text("14-Day Free Trial")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                         green: DesignSystemColor.textPrimary.green,
                                         blue: DesignSystemColor.textPrimary.blue))
            }

            Text("Try all premium features risk-free. Cancel anytime during your trial period.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                     green: DesignSystemColor.textSecondary.green,
                                     blue: DesignSystemColor.textSecondary.blue))
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystemColor.accent.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystemColor.accent.color, lineWidth: 1)
                )
        )
        .padding(.horizontal, Spacing.md)
    }

    private var purchaseButtonSection: some View {
        VStack(spacing: Spacing.sm) {
            Button(action: {
                Task { await viewModel.startPurchase(for: selectedProductId) }
            }) {
                HStack {
                    if viewModel.isPurchasing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "star.fill")
                    }

                    Text(viewModel.isPurchasing ? "Processing..." : "Start Free Trial")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(DesignSystemColor.primaryBrand.color)
                .cornerRadius(12)
            }
            .disabled(viewModel.isPurchasing || viewModel.isLoading)

            Button("Restore Purchases") {
                Task { await viewModel.restorePurchases() }
            }
            .font(.subheadline)
            .foregroundColor(DesignSystemColor.primaryBrand.color)
            .disabled(viewModel.isPurchasing || viewModel.isLoading)

            Text("Payment will be charged to your App Store account. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                     green: DesignSystemColor.textSecondary.green,
                                     blue: DesignSystemColor.textSecondary.blue))
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Computed Properties

    private var selectedProductId: String {
        switch (selectedChildCount, isAnnual) {
        case (1, false):
            return ProductIdentifiers.oneChildMonthly
        case (1, true):
            return ProductIdentifiers.oneChildYearly
        case (2, false), (3, false):
            return ProductIdentifiers.twoChildMonthly
        case (2, true), (3, true):
            return ProductIdentifiers.twoChildYearly
        default:
            return ProductIdentifiers.oneChildMonthly
        }
    }

    private var currentPrice: String {
        if let product = viewModel.availableProducts.first(where: { $0.id == selectedProductId }) {
            return product.priceFormatted
        }

        // Fallback pricing based on product configuration
        switch (selectedChildCount, isAnnual) {
        case (1, false):
            return "$9.99"
        case (1, true):
            return "$89.99"
        case (2, false), (3, false):
            return "$13.98"
        case (2, true), (3, true):
            return "$125.99"
        default:
            return "$9.99"
        }
    }

    private var savingsPercentage: Int {
        let monthlyPrice: Decimal
        let annualPrice: Decimal

        switch selectedChildCount {
        case 1:
            monthlyPrice = 9.99
            annualPrice = 89.99
        case 2, 3:
            monthlyPrice = 13.98
            annualPrice = 125.99
        default:
            monthlyPrice = 9.99
            annualPrice = 89.99
        }

        let annualEquivalent = monthlyPrice * 12
        let savings = annualEquivalent - annualPrice
        let percentage = (savings / annualEquivalent) * 100

        return Int(NSDecimalNumber(decimal: percentage).doubleValue)
    }

    private var monthlyEquivalent: String {
        let annualPrice: Decimal

        switch selectedChildCount {
        case 1:
            annualPrice = 89.99
        case 2, 3:
            annualPrice = 125.99
        default:
            annualPrice = 89.99
        }

        let monthlyEquivalent = annualPrice / 12
        return String(format: "$%.2f", NSDecimalNumber(decimal: monthlyEquivalent).doubleValue)
    }

    private var annualSavings: String {
        let monthlyPrice: Decimal
        let annualPrice: Decimal

        switch selectedChildCount {
        case 1:
            monthlyPrice = 9.99
            annualPrice = 89.99
        case 2, 3:
            monthlyPrice = 13.98
            annualPrice = 125.99
        default:
            monthlyPrice = 9.99
            annualPrice = 89.99
        }

        let annualEquivalent = monthlyPrice * 12
        let savings = annualEquivalent - annualPrice

        return String(format: "$%.2f", NSDecimalNumber(decimal: savings).doubleValue)
    }

    private var selectedProductDisplayName: String {
        if let product = viewModel.availableProducts.first(where: { $0.id == selectedProductId }) {
            return product.displayName
        }

        // Fallback display names
        switch (selectedChildCount, isAnnual) {
        case (1, false):
            return "Screen Time Rewards (1 Child, Monthly)"
        case (1, true):
            return "Screen Time Rewards (1 Child, Annual)"
        case (2, false), (3, false):
            return "Screen Time Rewards (\(selectedChildCount) Children, Monthly)"
        case (2, true), (3, true):
            return "Screen Time Rewards (\(selectedChildCount) Children, Annual)"
        default:
            return "Screen Time Rewards Premium"
        }
    }

    private func openSupportContact() {
        #if os(iOS)
        let email = "support@screentimerewards.com"
        let subject = "Purchase Support Request"
        let body = "Hello, I need help with my subscription purchase."

        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(forURLComponent: true) ?? "")&body=\(body.addingPercentEncoding(forURLComponent: true) ?? "")") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

extension String {
    func addingPercentEncoding(forURLComponent: Bool) -> String? {
        if forURLComponent {
            return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}