import SwiftUI
import SharedModels
import DesignSystem

struct ChildDashboardView: View {
    @StateObject private var viewModel = ChildDashboardViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress Ring Section
                        progressRingSection
                        
                        // Points Display Section
                        pointsDisplaySection

                        // Rewards Section
                        rewardsSection

                        // Point History Section
                        pointHistorySection

                        // Recent Activity Section
                        recentActivitySection

                        Spacer()
                    }
                    .padding()
                }
                
                // Floating Points Notification
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingPointsNotificationView(
                            points: viewModel.floatingPointsNotification,
                            isVisible: $viewModel.showFloatingNotification
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("My Dashboard")
            .refreshable {
                await viewModel.refreshData()
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }

    private var progressRingSection: some View {
        VStack {
            ProgressRingView(
                currentPoints: viewModel.currentPoints,
                goalPoints: viewModel.dailyGoal
            )
            .frame(width: 120, height: 120)
            
            Text("Daily Goal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var pointsDisplaySection: some View {
        PointsBalanceView(
            points: viewModel.currentPoints,
            animationScale: viewModel.pointsAnimationScale
        )
    }

    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Rewards")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.availableRewards.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "gift.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No rewards available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Ask your parents to set up rewards!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.availableRewards) { reward in
                            RewardCardView(
                                reward: reward,
                                hasSufficientPoints: viewModel.currentPoints >= reward.pointCost
                            ) {
                                // Handle reward redemption
                                viewModel.redeemReward(reward)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var pointHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Point Activity")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.recentTransactions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "star.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Start using learning apps to earn points!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentTransactions) { transaction in
                        pointTransactionRow(transaction)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func pointTransactionRow(_ transaction: PointTransaction) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.reason)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text(transaction.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                if transaction.points > 0 {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }

                Text("\(transaction.points > 0 ? "+" : "")\(transaction.points)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(transaction.points > 0 ? .green : .red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Progress")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.recentSessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "book.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No learning sessions yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Open a learning app to start earning points!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentSessions) { session in
                        sessionRow(session)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func sessionRow(_ session: ScreenTimeSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.appBundleID.components(separatedBy: ".").last?.capitalized ?? "Unknown App")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text("\(Int(session.duration / 60)) minutes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text("+\(session.pointsEarned)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }

                Text(session.startTime, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ChildDashboardView()
}