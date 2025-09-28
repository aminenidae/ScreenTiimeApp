import SwiftUI
import SharedModels
import RewardCore

struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsDashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeaderView()
                    
                    // Feature Usage Section
                    FeatureUsageSection(aggregations: viewModel.aggregations)
                    
                    // Performance Metrics Section
                    PerformanceMetricsSection(aggregations: viewModel.aggregations)
                    
                    // Retention Metrics Section
                    RetentionMetricsSection(aggregations: viewModel.aggregations)
                    
                    // Export Options
                    ExportOptionsSection()
                }
                .padding()
            }
            .navigationTitle("Analytics Dashboard")
            .onAppear {
                viewModel.loadAnalyticsData()
            }
        }
    }
}

// MARK: - Header View
private struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analytics Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Understand usage patterns and improve the app experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Feature Usage Section
private struct FeatureUsageSection: View {
    let aggregations: [AnalyticsAggregation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Feature Usage")
            
            if aggregations.isEmpty {
                EmptyStateView(message: "No feature usage data available")
            } else {
                ForEach(aggregations.prefix(5), id: \.id) { aggregation in
                    FeatureUsageChart(aggregation: aggregation)
                }
            }
        }
    }
}

private struct FeatureUsageChart: View {
    let aggregation: AnalyticsAggregation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(aggregation.aggregationType.rawValue.capitalized) Feature Usage")
                .font(.headline)
            
            // Simple bar chart representation
            ForEach(Array(aggregation.featureUsageCounts.sorted { $0.value > $1.value }.prefix(3)), id: \.key) { feature, count in
                HStack {
                    Text(feature)
                    Spacer()
                    Text("\(count)")
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Performance Metrics Section
private struct PerformanceMetricsSection: View {
    let aggregations: [AnalyticsAggregation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Performance Metrics")
            
            if aggregations.isEmpty {
                EmptyStateView(message: "No performance data available")
            } else {
                ForEach(aggregations.prefix(3), id: \.id) { aggregation in
                    PerformanceMetricsCard(aggregation: aggregation)
                }
            }
        }
    }
}

private struct PerformanceMetricsCard: View {
    let aggregation: AnalyticsAggregation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(aggregation.aggregationType.rawValue.capitalized) Performance")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                MetricRow(
                    title: "Avg. Launch Time",
                    value: "\(String(format: "%.2f", aggregation.performanceMetrics.averageAppLaunchTime))s",
                    indicator: aggregation.performanceMetrics.averageAppLaunchTime < 2.0 ? .good : .warning
                )
                
                MetricRow(
                    title: "Crash Rate",
                    value: "\(String(format: "%.1f", aggregation.performanceMetrics.crashRate))%",
                    indicator: aggregation.performanceMetrics.crashRate < 5.0 ? .good : .warning
                )
                
                MetricRow(
                    title: "Battery Impact",
                    value: "\(String(format: "%.1f", aggregation.performanceMetrics.averageBatteryImpact))%",
                    indicator: aggregation.performanceMetrics.averageBatteryImpact < 5.0 ? .good : .warning
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Retention Metrics Section
private struct RetentionMetricsSection: View {
    let aggregations: [AnalyticsAggregation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Retention Metrics")
            
            if aggregations.isEmpty {
                EmptyStateView(message: "No retention data available")
            } else {
                ForEach(aggregations.prefix(3), id: \.id) { aggregation in
                    RetentionMetricsCard(aggregation: aggregation)
                }
            }
        }
    }
}

private struct RetentionMetricsCard: View {
    let aggregation: AnalyticsAggregation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(aggregation.aggregationType.rawValue.capitalized) Retention")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                MetricRow(
                    title: "Day 1 Retention",
                    value: "\(String(format: "%.1f", aggregation.retentionMetrics.dayOneRetention))%",
                    indicator: aggregation.retentionMetrics.dayOneRetention > 80.0 ? .good : .warning
                )
                
                MetricRow(
                    title: "Day 7 Retention",
                    value: "\(String(format: "%.1f", aggregation.retentionMetrics.daySevenRetention))%",
                    indicator: aggregation.retentionMetrics.daySevenRetention > 60.0 ? .good : .warning
                )
                
                MetricRow(
                    title: "Day 30 Retention",
                    value: "\(String(format: "%.1f", aggregation.retentionMetrics.dayThirtyRetention))%",
                    indicator: aggregation.retentionMetrics.dayThirtyRetention > 40.0 ? .good : .warning
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Export Options Section
private struct ExportOptionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Export Data")
            
            HStack {
                Button(action: {
                    // Export to CSV
                }) {
                    Label("Export to CSV", systemImage: "arrow.down.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    // Export to PDF
                }) {
                    Label("Export to PDF", systemImage: "doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Helper Views
private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.top)
    }
}

private struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.largeTitle)
                .foregroundColor(.secondary)
                .padding()
            
            Text(message)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct MetricRow: View {
    enum Indicator {
        case good, warning, bad
    }
    
    let title: String
    let value: String
    let indicator: Indicator
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 8, height: 8)
                
                Text(value)
                    .fontWeight(.medium)
            }
        }
    }
    
    private var indicatorColor: Color {
        switch indicator {
        case .good:
            return .green
        case .warning:
            return .orange
        case .bad:
            return .red
        }
    }
}

// MARK: - Preview
struct AnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsDashboardView()
    }
}