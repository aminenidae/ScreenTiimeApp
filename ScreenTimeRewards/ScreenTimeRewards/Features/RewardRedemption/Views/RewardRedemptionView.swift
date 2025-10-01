import SwiftUI
import SharedModels
import DesignSystem

struct RewardRedemptionView: View {
    @StateObject private var viewModel = RewardRedemptionViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Points Header
                pointsHeaderView

                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredRewardApps.isEmpty {
                    emptyStateView
                } else {
                    rewardAppsListView
                }

                Spacer()
            }
            .navigationTitle("Redeem Points")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search reward apps...")
        }
        .task {
            await viewModel.loadRewardApps()
        }
        .alert("Redemption Result", isPresented: $viewModel.showingRedemptionAlert) {
            Button("OK") {
                viewModel.showingRedemptionAlert = false
                if viewModel.redemptionSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(viewModel.redemptionMessage)
        }
    }

    private var pointsHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)

                Text("\(viewModel.currentPoints)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("points available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }

            if let selectedApp = viewModel.selectedRewardApp {
                HStack {
                    Text("Converting to: \(selectedApp.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Clear") {
                        viewModel.selectedRewardApp = nil
                        viewModel.conversionAmount = 0
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading reward apps...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Reward Apps Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Ask your parent to set up reward apps in the categorization settings.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var rewardAppsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Category filter
                categoryFilterView

                // Apps grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(viewModel.filteredRewardApps, id: \.appBundleID) { categorization in
                        rewardAppCard(categorization)
                    }
                }
                .padding(.horizontal)

                // Conversion section
                if viewModel.selectedRewardApp != nil {
                    conversionSection
                        .padding()
                }
            }
            .padding(.vertical)
        }
    }

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(["All"] + AppCategory.allCases.map { $0.rawValue }, id: \.self) { category in
                    Button(action: {
                        viewModel.selectedCategory = category == "All" ? nil : AppCategory(rawValue: category)
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelectedCategory(category) ? Color.blue : Color(.secondarySystemBackground))
                            )
                            .foregroundColor(isSelectedCategory(category) ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func isSelectedCategory(_ category: String) -> Bool {
        if category == "All" {
            return viewModel.selectedCategory == nil
        }
        return viewModel.selectedCategory?.rawValue == category
    }

    private func rewardAppCard(_ categorization: AppCategorization) -> some View {
        VStack(spacing: 12) {
            // App icon placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "app.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                )

            // App name
            Text(categorization.appBundleID.components(separatedBy: ".").last?.capitalized ?? "Unknown App")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Points per hour
            Text("\(categorization.pointsPerHour) pts/hr")
                .font(.caption)
                .foregroundColor(.secondary)

            // Conversion rate (example: 10 points = 1 minute)
            Text("10 pts = 1 min")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.selectedRewardApp?.id == categorization.id ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture {
            viewModel.selectRewardApp(categorization)
        }
    }

    private var conversionSection: some View {
        VStack(spacing: 16) {
            Text("Convert Points to Screen Time")
                .font(.headline)
                .foregroundColor(.primary)

            // Amount selector
            VStack(spacing: 12) {
                Text("Points to convert:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    Button("-") {
                        viewModel.adjustConversionAmount(-10)
                    }
                    .buttonStyle(AdjustmentButtonStyle())
                    .disabled(viewModel.conversionAmount <= 10)

                    VStack(spacing: 4) {
                        Text("\(viewModel.conversionAmount)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(minWidth: 80)

                    Button("+") {
                        viewModel.adjustConversionAmount(10)
                    }
                    .buttonStyle(AdjustmentButtonStyle())
                    .disabled(viewModel.conversionAmount >= viewModel.currentPoints)
                }

                // Conversion preview
                if viewModel.conversionAmount > 0 {
                    VStack(spacing: 4) {
                        Text("= \(viewModel.conversionAmount / 10) minutes screen time")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)

                        Text("Expires in 24 hours")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
            )

            // Redeem button
            Button(action: {
                Task {
                    await viewModel.redeemPoints()
                }
            }) {
                HStack {
                    if viewModel.isProcessingRedemption {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    }

                    Text(viewModel.isProcessingRedemption ? "Processing..." : "Redeem Points")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.canRedeem ? Color.blue : Color.gray)
                )
                .foregroundColor(.white)
            }
            .disabled(!viewModel.canRedeem || viewModel.isProcessingRedemption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Custom Button Style

struct AdjustmentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.bold)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(Color(.systemGray5))
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .foregroundColor(.primary)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    RewardRedemptionView()
}