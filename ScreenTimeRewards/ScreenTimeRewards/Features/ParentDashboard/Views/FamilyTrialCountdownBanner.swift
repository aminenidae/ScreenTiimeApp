import SwiftUI
import SubscriptionService

struct FamilyTrialCountdownBanner: View {
    let familyID: String
    
    @StateObject private var featureGateService = FeatureGateService.shared
    @State private var daysRemaining: Int? = nil
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let days = daysRemaining, isLoading == false {
                TrialCountdownBanner(daysRemaining: days) {
                    // Handle subscription action
                    handleSubscribe()
                }
            } else if isLoading {
                // Show loading state
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Checking subscription status...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            // If not in trial, show nothing
        }
        .task {
            await loadTrialStatus()
        }
    }
    
    private func loadTrialStatus() async {
        isLoading = true
        daysRemaining = await featureGateService.getTrialDaysRemaining(for: familyID)
        isLoading = false
    }
    
    private func handleSubscribe() {
        // TODO: Implement subscription flow
        print("Subscribe button tapped")
    }
}

#Preview {
    FamilyTrialCountdownBanner(familyID: "test-family")
}