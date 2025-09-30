import SwiftUI
import SharedModels
import SubscriptionService

struct SubscriptionAnalyticsDashboardView: View {
    @StateObject private var viewModel = SubscriptionAnalyticsDashboardViewModel()
    @AppStorage("currentFamilyID") private var currentFamilyID = "default-family"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HeaderView()

                    if viewModel.isLoading {
                        LoadingView()
                    } else if let error = viewModel.error {
                        ErrorView(error: error) {
                            viewModel.loadDashboardData()
                        }
                    } else {
                        DashboardContent(viewModel: viewModel, familyID: currentFamilyID)
                    }
                }
                .padding()
            }
            .navigationTitle("Subscription Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewModel.loadDashboardData()
                    }
                }
            }
            .onAppear {
                viewModel.loadDashboardData()
            }
        }
    }
}

// MARK: - Header View

private struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subscription Analytics")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Optimize conversion rates and maximize revenue")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Dashboard Content

private struct DashboardContent: View {
    let viewModel: SubscriptionAnalyticsDashboardViewModel
    let familyID: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Key Metrics Overview
            KeyMetricsSection(viewModel: viewModel)

            // Conversion Funnel
            ConversionFunnelSection(viewModel: viewModel)

            // Revenue Reports
            RevenueSection(viewModel: viewModel)

            // Cohort Analysis
            CohortAnalysisSection(viewModel: viewModel)

            // Optimization Insights
            OptimizationInsightsSection(viewModel: viewModel)

            // Export Options - Gated Feature
            ExportSection(familyID: familyID)
        }
    }
}

// MARK: - Key Metrics Section

private struct KeyMetricsSection: View {
    let viewModel: SubscriptionAnalyticsDashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Key Metrics", icon: "chart.bar.fill")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "MRR",
                    value: viewModel.totalMRR,
                    subtitle: "Monthly Recurring Revenue",
                    color: .green
                )

                MetricCard(
                    title: "ARR",
                    value: viewModel.totalARR,
                    subtitle: "Annual Recurring Revenue",
                    color: .blue
                )

                MetricCard(
                    title: "Trial → Paid",
                    value: viewModel.trialToPageConversion,
                    subtitle: "Conversion Rate",
                    color: .orange
                )

                MetricCard(
                    title: "Churn Rate",
                    value: viewModel.churnRate,
                    subtitle: "Monthly Churn",
                    color: .red
                )

                MetricCard(
                    title: "ARPU",
                    value: viewModel.averageRevenue,
                    subtitle: "Avg Revenue Per User",
                    color: .purple
                )

                MetricCard(
                    title: "LTV",
                    value: viewModel.lifetimeValue,
                    subtitle: "Customer Lifetime Value",
                    color: .indigo
                )
            }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Conversion Funnel Section

private struct ConversionFunnelSection: View {
    let viewModel: SubscriptionAnalyticsDashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Conversion Funnel", icon: "chart.line.downtrend.xyaxis")

            if let metrics = viewModel.subscriptionMetrics {
                ConversionFunnelChart(conversionRates: metrics.conversionRates)
            } else {
                EmptyStateCard(message: "Conversion funnel data loading...")
            }
        }
    }
}

private struct ConversionFunnelChart: View {
    let conversionRates: [String: Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(conversionRates.keys.sorted()), id: \.self) { stage in
                if let rate = conversionRates[stage] {
                    FunnelStageRow(
                        stage: formatStageName(stage),
                        rate: rate,
                        color: stageColor(stage)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formatStageName(_ stage: String) -> String {
        return stage.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func stageColor(_ stage: String) -> Color {
        switch stage {
        case "impression_to_trial": return .blue
        case "trial_to_purchase": return .green
        case "impression_to_purchase": return .orange
        default: return .gray
        }
    }
}

private struct FunnelStageRow: View {
    let stage: String
    let rate: Double
    let color: Color

    var body: some View {
        HStack {
            Text(stage)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            Text("\(String(format: "%.1f", rate * 100))%")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Revenue Section

private struct RevenueSection: View {
    let viewModel: SubscriptionAnalyticsDashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Revenue Reports", icon: "dollarsign.circle.fill")

            if !viewModel.revenueReports.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.revenueReports) { report in
                        RevenueReportCard(report: report)
                    }
                }
            } else {
                EmptyStateCard(message: "No revenue reports available")
            }
        }
    }
}

private struct RevenueReportCard: View {
    let report: RevenueReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatReportPeriod(report))
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                VStack(alignment: .trailing) {
                    Text(formatCurrency(report.netRevenue))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Net Revenue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    Text("Total Revenue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(report.totalRevenue))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Refunds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(report.refunds))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formatReportPeriod(_ report: RevenueReport) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: report.startDate)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Cohort Analysis Section

private struct CohortAnalysisSection: View {
    let viewModel: SubscriptionAnalyticsDashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Cohort Analysis", icon: "person.3.fill")

            if !viewModel.cohortAnalyses.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.cohortAnalyses) { cohort in
                        CohortCard(cohort: cohort)
                    }
                }
            } else {
                EmptyStateCard(message: "No cohort data available")
            }
        }
    }
}

private struct CohortCard: View {
    let cohort: CohortAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatCohortDate(cohort.cohortStartDate))
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(cohort.cohortSize) users")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let channel = cohort.acquisitionChannel {
                Text("Primary Channel: \(channel.capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Show top conversion rates by channel
            if !cohort.conversionRateByChannel.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Conversion by Channel")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    ForEach(Array(cohort.conversionRateByChannel.prefix(3)), id: \.key) { channel, rate in
                        HStack {
                            Text(channel.capitalized)
                                .font(.caption2)
                            Spacer()
                            Text("\(String(format: "%.1f", rate * 100))%")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formatCohortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "Week of \(formatter.string(from: date))"
    }
}

// MARK: - Optimization Insights Section

private struct OptimizationInsightsSection: View {
    let viewModel: SubscriptionAnalyticsDashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Optimization Insights", icon: "lightbulb.fill")

            if !viewModel.optimizationInsights.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.optimizationInsights) { insight in
                        InsightCard(insight: insight)
                    }
                }
            } else {
                EmptyStateCard(message: "No optimization insights available")
            }
        }
    }
}

private struct InsightCard: View {
    let insight: OptimizationInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(insight.title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                ImpactBadge(impact: insight.impact)
            }

            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !insight.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Recommendations:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    ForEach(Array(insight.recommendations.prefix(3)), id: \.self) { recommendation in
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(recommendation)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct ImpactBadge: View {
    let impact: InsightImpact

    var body: some View {
        Text(impact.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(impactColor.opacity(0.2))
            .foregroundColor(impactColor)
            .cornerRadius(6)
    }

    private var impactColor: Color {
        switch impact {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

// MARK: - Export Section

private struct ExportSection: View {
    let familyID: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Export Analytics", icon: "square.and.arrow.up.fill")
                .premiumBadge(for: .exportReports, familyID: familyID)

            HStack(spacing: 12) {
                ExportButton(
                    title: "Export CSV",
                    icon: "doc.text",
                    familyID: familyID
                )

                ExportButton(
                    title: "Export PDF",
                    icon: "doc.richtext",
                    familyID: familyID
                )
            }
        }
    }
}

private struct ExportButton: View {
    let title: String
    let icon: String
    let familyID: String

    var body: some View {
        Button(action: {
            // Export action
        }) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
        .featureGated(.exportReports, for: familyID) {
            // Handle paywall presentation
        }
    }
}

// MARK: - Helper Views

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading analytics data...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct ErrorView: View {
    let error: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text("Error loading analytics")
                .font(.headline)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct EmptyStateCard: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct SubscriptionAnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionAnalyticsDashboardView()
    }
}