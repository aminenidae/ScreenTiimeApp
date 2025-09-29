import SwiftUI
import DesignSystem

struct PurchaseSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    let productName: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            celebrationSection

            contentSection

            Spacer()

            actionButtonsSection
        }
        .padding(Spacing.lg)
        .background(DesignSystemColor.backgroundPrimary.color)
        .onAppear {
            playSuccessHaptics()
        }
    }

    private var celebrationSection: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystemColor.success.color.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystemColor.success.color)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0), value: true)

            VStack(spacing: Spacing.xs) {
                Text("🎉 Welcome to Premium!")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                         green: DesignSystemColor.textPrimary.green,
                                         blue: DesignSystemColor.textPrimary.blue))

                Text("Your free trial has started")
                    .font(.headline)
                    .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                         green: DesignSystemColor.textSecondary.green,
                                         blue: DesignSystemColor.textSecondary.blue))
            }
        }
    }

    private var contentSection: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.sm) {
                Text("You're all set!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                         green: DesignSystemColor.textPrimary.green,
                                         blue: DesignSystemColor.textPrimary.blue))

                Text("Your subscription to \(productName) is now active. You have 14 days to explore all premium features risk-free.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                         green: DesignSystemColor.textSecondary.green,
                                         blue: DesignSystemColor.textSecondary.blue))
            }

            premiumFeaturesSection
        }
    }

    private var premiumFeaturesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Premium Features Unlocked:")
                .font(.headline)
                .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                     green: DesignSystemColor.textPrimary.green,
                                     blue: DesignSystemColor.textPrimary.blue))

            VStack(alignment: .leading, spacing: Spacing.xs) {
                FeatureRow(icon: "star.fill", title: "Unlimited Screen Time Rewards", description: "No daily limits on points earning")
                FeatureRow(icon: "chart.bar.fill", title: "Advanced Analytics", description: "Detailed insights and progress reports")
                FeatureRow(icon: "icloud.fill", title: "Family Sync", description: "Seamless sync across all family devices")
                FeatureRow(icon: "bell.fill", title: "Smart Notifications", description: "Personalized reminders and achievements")
            }
        }
        .padding(Spacing.md)
        .background(Color(red: DesignSystemColor.backgroundSecondary.red,
                        green: DesignSystemColor.backgroundSecondary.green,
                        blue: DesignSystemColor.backgroundSecondary.blue))
        .cornerRadius(12)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: Spacing.sm) {
            Button(action: {
                onContinue()
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Continue to App")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(DesignSystemColor.primaryBrand.color)
                .cornerRadius(12)
            }

            Button("Manage Subscription") {
                openSubscriptionManagement()
            }
            .font(.subheadline)
            .foregroundColor(Color(red: DesignSystemColor.primaryBrand.red,
                                 green: DesignSystemColor.primaryBrand.green,
                                 blue: DesignSystemColor.primaryBrand.blue))
        }
    }

    // MARK: - Helper Methods

    private func playSuccessHaptics() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
        #endif
    }

    private func openSubscriptionManagement() {
        #if os(iOS)
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: DesignSystemColor.success.red,
                                     green: DesignSystemColor.success.green,
                                     blue: DesignSystemColor.success.blue))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                         green: DesignSystemColor.textPrimary.green,
                                         blue: DesignSystemColor.textPrimary.blue))

                Text(description)
                    .font(.caption)
                    .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                         green: DesignSystemColor.textSecondary.green,
                                         blue: DesignSystemColor.textSecondary.blue))
            }

            Spacer()
        }
    }
}

struct PurchaseSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseSuccessView(
            productName: "Screen Time Rewards Premium",
            onContinue: {}
        )
    }
}