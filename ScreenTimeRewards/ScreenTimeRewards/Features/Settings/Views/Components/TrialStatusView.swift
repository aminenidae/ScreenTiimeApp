import SwiftUI
import SubscriptionService
import SharedModels
import DesignSystem

@available(iOS 15.0, *)
struct TrialStatusView: View {
    @StateObject private var trialService: TrialEligibilityService
    @State private var trialStatus: TrialStatus = .notStarted
    @State private var isLoading = true

    private let familyID: String

    init(familyID: String, familyRepository: FamilyRepository) {
        self.familyID = familyID
        self._trialService = StateObject(wrappedValue: TrialEligibilityService(familyRepository: familyRepository))
    }

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else {
                statusContent
            }
        }
        .task {
            await loadTrialStatus()
        }
    }

    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Checking trial status...")
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var statusContent: some View {
        switch trialStatus {
        case .notStarted:
            EmptyView()

        case .active(let daysRemaining):
            activeTrialView(daysRemaining: daysRemaining)

        case .expired:
            expiredTrialView
        }
    }

    private func activeTrialView(daysRemaining: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.green)
                Text("Free Trial Active")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(spacing: 8) {
                HStack {
                    Text("Days remaining:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(daysRemaining)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(daysRemaining <= 3 ? .orange : .green)
                }

                ProgressView(value: Double(14 - daysRemaining), total: 14.0)
                    .tint(daysRemaining <= 3 ? .orange : .green)

                HStack {
                    Text("Started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Expires")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if daysRemaining <= 3 {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Trial ending soon!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        Spacer()
                    }

                    Button("Subscribe Now") {
                        // Handle subscription action
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(daysRemaining <= 3 ? Color.orange : Color.green, lineWidth: 2)
        )
    }

    private var expiredTrialView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.red)
                Text("Trial Expired")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                Spacer()
            }

            Text("Your 14-day free trial has ended. Subscribe to continue using premium features.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            Button("Subscribe to Continue") {
                // Handle subscription action
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(Color.red, lineWidth: 2)
        )
    }

    private func loadTrialStatus() async {
        isLoading = true
        trialStatus = await trialService.getTrialStatus(for: familyID)
        isLoading = false
    }
}

// MARK: - Trial Status Badge for Navigation

@available(iOS 15.0, *)
struct TrialStatusBadge: View {
    let trialStatus: TrialStatus

    var body: some View {
        switch trialStatus {
        case .notStarted:
            EmptyView()

        case .active(let daysRemaining):
            HStack(spacing: 4) {
                Image(systemName: "gift.fill")
                    .font(.caption)
                Text("Trial: \(daysRemaining)d")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(daysRemaining <= 3 ? .orange : .green)
            )

        case .expired:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                Text("Expired")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.red)
            )
        }
    }
}

// MARK: - Trial Status Service

@available(iOS 15.0, *)
@MainActor
class TrialStatusService: ObservableObject {
    @Published var currentStatus: TrialStatus = .notStarted
    @Published var isLoading = false

    private let trialService: TrialEligibilityService
    private let familyID: String

    init(familyID: String, familyRepository: FamilyRepository) {
        self.familyID = familyID
        self.trialService = TrialEligibilityService(familyRepository: familyRepository)
    }

    func refreshStatus() async {
        isLoading = true
        currentStatus = await trialService.getTrialStatus(for: familyID)
        isLoading = false
    }

    var shouldShowBadge: Bool {
        switch currentStatus {
        case .notStarted:
            return false
        case .active, .expired:
            return true
        }
    }

    var badgeView: some View {
        TrialStatusBadge(trialStatus: currentStatus)
    }
}

#Preview("Active Trial") {
    VStack {
        TrialStatusView(familyID: "test-family", familyRepository: MockFamilyRepository())

        TrialStatusBadge(trialStatus: .active(daysRemaining: 7))

        TrialStatusBadge(trialStatus: .active(daysRemaining: 2))

        TrialStatusBadge(trialStatus: .expired)
    }
    .padding()
}

// Mock repository for preview
fileprivate class MockFamilyRepository: FamilyRepository {
    func createFamily(_ family: Family) async throws -> Family { family }
    func fetchFamily(id: String) async throws -> Family? {
        let metadata = SubscriptionMetadata(
            trialStartDate: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            trialEndDate: Date().addingTimeInterval(86400 * 7), // 7 days from now
            hasUsedTrial: true,
            isActive: true
        )
        return Family(
            id: id,
            name: "Test Family",
            createdAt: Date(),
            ownerUserID: "user1",
            sharedWithUserIDs: [],
            childProfileIDs: [],
            subscriptionMetadata: metadata
        )
    }
    func fetchFamilies(for userID: String) async throws -> [Family] { [] }
    func updateFamily(_ family: Family) async throws -> Family { family }
    func deleteFamily(id: String) async throws { }
}