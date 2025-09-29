import SwiftUI
import SharedModels
import DesignSystem
import SubscriptionService
import LocalAuthentication

@available(iOS 15.0, *)
struct PaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService()
    @StateObject private var trialService: TrialEligibilityService
    @Environment(\.dismiss) private var dismiss

    @State private var isActivatingTrial = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showTrialSuccess = false

    private let familyID: String

    init(familyID: String, familyRepository: FamilyRepository) {
        self.familyID = familyID
        self._trialService = StateObject(wrappedValue: TrialEligibilityService(familyRepository: familyRepository))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection

                    trialSection

                    subscriptionPlansSection

                    footerSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Unlock Premium")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadProducts()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Trial Activated!", isPresented: $showTrialSuccess) {
            Button("Get Started") {
                dismiss()
            }
        } message: {
            Text("Your 14-day free trial has started. Enjoy full access to all premium features!")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.linearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))

            Text("Unlock Premium Features")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Get the full Screen Time Rewards experience with advanced parental controls and unlimited family members.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var trialSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.green)
                    Text("14-Day Free Trial")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "Full access to all premium features", color: .green)
                    FeatureRow(icon: "checkmark.circle.fill", text: "No payment required to start", color: .green)
                    FeatureRow(icon: "checkmark.circle.fill", text: "Cancel anytime during trial", color: .green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .green.opacity(0.2), radius: 8, x: 0, y: 4)
            )

            Button(action: activateTrial) {
                HStack {
                    if isActivatingTrial {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "hand.thumbsup.fill")
                    }

                    Text(isActivatingTrial ? "Activating Trial..." : "Start Free Trial")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isActivatingTrial)
        }
    }

    private var subscriptionPlansSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Subscription Plans")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }

            if subscriptionService.isLoading {
                ProgressView("Loading plans...")
                    .frame(height: 100)
            } else if subscriptionService.availableProducts.isEmpty {
                Text("No subscription plans available")
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(subscriptionService.availableProducts) { product in
                        SubscriptionPlanCard(
                            product: product,
                            onPurchase: { await purchaseProduct(product) }
                        )
                    }
                }
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 16) {
            Text("Premium Features Include:")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "person.3.fill", text: "Unlimited family members", color: .blue)
                FeatureRow(icon: "chart.bar.fill", text: "Advanced analytics and reports", color: .blue)
                FeatureRow(icon: "bell.fill", text: "Smart notifications and reminders", color: .blue)
                FeatureRow(icon: "lock.fill", text: "Enhanced parental controls", color: .blue)
                FeatureRow(icon: "cloud.fill", text: "Automatic iCloud sync", color: .blue)
                FeatureRow(icon: "headphones", text: "Priority customer support", color: .blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )

            VStack(spacing: 8) {
                Text("Terms and Privacy")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    Button("Terms of Service") {
                        // Handle terms tap
                    }
                    .font(.caption)

                    Button("Privacy Policy") {
                        // Handle privacy tap
                    }
                    .font(.caption)
                }
            }
        }
    }

    private func loadProducts() async {
        await subscriptionService.fetchProducts()
    }

    private func activateTrial() {
        isActivatingTrial = true

        Task {
            // Request biometric authentication
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                do {
                    let success = try await context.evaluatePolicy(
                        .deviceOwnerAuthenticationWithBiometrics,
                        localizedReason: "Authenticate to start your free trial"
                    )

                    if success {
                        await performTrialActivation()
                    }
                } catch {
                    await handleTrialActivationError("Authentication failed: \(error.localizedDescription)")
                }
            } else {
                // Fallback to device passcode
                do {
                    let success = try await context.evaluatePolicy(
                        .deviceOwnerAuthentication,
                        localizedReason: "Authenticate to start your free trial"
                    )

                    if success {
                        await performTrialActivation()
                    }
                } catch {
                    await handleTrialActivationError("Authentication failed: \(error.localizedDescription)")
                }
            }

            await MainActor.run {
                isActivatingTrial = false
            }
        }
    }

    private func performTrialActivation() async {
        let result = await trialService.activateTrial(for: familyID)

        await MainActor.run {
            switch result {
            case .success:
                showTrialSuccess = true
            case .failed(let reason):
                switch reason {
                case .notEligible:
                    errorMessage = "You are not eligible for a free trial. This may be because you've already used a trial or have an active subscription."
                case .familyNotFound:
                    errorMessage = "Family account not found. Please try again."
                case .systemError:
                    errorMessage = "A system error occurred. Please try again later."
                }
                showError = true
            }
        }
    }

    private func handleTrialActivationError(_ message: String) async {
        await MainActor.run {
            errorMessage = message
            showError = true
        }
    }

    private func purchaseProduct(_ product: SubscriptionProduct) async {
        // Handle subscription purchase
        do {
            let result = try await subscriptionService.purchase(product.id)
            // Handle purchase result
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20, height: 20)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

struct SubscriptionPlanCard: View {
    let product: SubscriptionProduct
    let onPurchase: () async -> Void

    @State private var isPurchasing = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(product.subscriptionPeriod.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.priceFormatted)
                        .font(.title2)
                        .fontWeight(.bold)

                    if product.subscriptionPeriod.unit == .year {
                        Text("Best Value")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }
            }

            Button(action: {
                isPurchasing = true
                Task {
                    await onPurchase()
                    isPurchasing = false
                }
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    }

                    Text(isPurchasing ? "Processing..." : "Subscribe")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isPurchasing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    PaywallView(familyID: "test-family", familyRepository: MockFamilyRepository())
}

// Mock repository for preview
fileprivate class MockFamilyRepository: FamilyRepository {
    func createFamily(_ family: Family) async throws -> Family { family }
    func fetchFamily(id: String) async throws -> Family? { nil }
    func fetchFamilies(for userID: String) async throws -> [Family] { [] }
    func updateFamily(_ family: Family) async throws -> Family { family }
    func deleteFamily(id: String) async throws { }
}