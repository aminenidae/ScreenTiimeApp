import Foundation
import SharedModels
import SubscriptionService
import RewardCore

@MainActor
class SubscriptionAnalyticsDashboardViewModel: ObservableObject {
    @Published var subscriptionMetrics: SubscriptionMetrics?
    @Published var cohortAnalyses: [CohortAnalysis] = []
    @Published var revenueReports: [RevenueReport] = []
    @Published var optimizationInsights: [OptimizationInsight] = []
    @Published var abTestResults: [ABTestResults] = []
    @Published var isLoading = false
    @Published var error: String?

    private let subscriptionAnalyticsService: SubscriptionAnalyticsService
    private let cohortAnalysisService: CohortAnalysisService
    private let revenueReportingService: RevenueReportingService
    private let optimizationInsightsEngine: OptimizationInsightsEngine
    private let abTestingService: ABTestingService

    init() {
        // Initialize services with mock implementations for now
        let mockRepository = MockAnalyticsRepository()

        self.subscriptionAnalyticsService = SubscriptionAnalyticsService(
            analyticsRepository: mockRepository
        )

        self.cohortAnalysisService = CohortAnalysisService(
            analyticsRepository: mockRepository
        )

        self.revenueReportingService = RevenueReportingService(
            analyticsRepository: mockRepository
        )

        self.abTestingService = ABTestingService(
            analyticsRepository: mockRepository
        )

        self.optimizationInsightsEngine = OptimizationInsightsEngine(
            analyticsRepository: mockRepository,
            subscriptionAnalyticsService: subscriptionAnalyticsService,
            cohortAnalysisService: cohortAnalysisService,
            abTestingService: abTestingService
        )
    }

    // MARK: - Data Loading

    func loadDashboardData() {
        Task {
            await loadAllAnalytics()
        }
    }

    private func loadAllAnalytics() async {
        isLoading = true
        error = nil

        do {
            let dateRange = DateRange.last30Days()

            // Load all analytics in parallel
            async let metricsTask = loadSubscriptionMetrics(dateRange: dateRange)
            async let cohortTask = loadCohortAnalysis(dateRange: dateRange)
            async let revenueTask = loadRevenueReports()
            async let insightsTask = loadOptimizationInsights(dateRange: dateRange)

            _ = await (metricsTask, cohortTask, revenueTask, insightsTask)

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    private func loadSubscriptionMetrics(dateRange: DateRange) async {
        do {
            subscriptionMetrics = try await subscriptionAnalyticsService.generateSubscriptionMetrics(dateRange: dateRange)
        } catch {
            print("Error loading subscription metrics: \(error)")
        }
    }

    private func loadCohortAnalysis(dateRange: DateRange) async {
        do {
            cohortAnalyses = try await cohortAnalysisService.generateCohortAnalysis(
                startDate: dateRange.startDate,
                endDate: dateRange.endDate,
                cohortPeriod: .weekly
            )
        } catch {
            print("Error loading cohort analysis: \(error)")
        }
    }

    private func loadRevenueReports() async {
        do {
            let calendar = Calendar.current
            let now = Date()

            // Load last 3 months of revenue reports
            var reports: [RevenueReport] = []

            for i in 0..<3 {
                let date = calendar.date(byAdding: .month, value: -i, to: now) ?? now
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)

                let report = try await revenueReportingService.generateMonthlyReport(
                    for: month,
                    year: year
                )
                reports.append(report)
            }

            revenueReports = reports.sorted { $0.startDate > $1.startDate }
        } catch {
            print("Error loading revenue reports: \(error)")
        }
    }

    private func loadOptimizationInsights(dateRange: DateRange) async {
        do {
            optimizationInsights = try await optimizationInsightsEngine.generateComprehensiveInsights(
                dateRange: dateRange,
                pricingTests: ["pricing_test_v1", "pricing_test_v2"],
                featureTests: ["feature_gate_test_v1"]
            )
        } catch {
            print("Error loading optimization insights: \(error)")
        }
    }

    // MARK: - Refresh Actions

    func refreshMetrics() {
        Task {
            await loadSubscriptionMetrics(dateRange: DateRange.last30Days())
        }
    }

    func refreshCohorts() {
        Task {
            await loadCohortAnalysis(dateRange: DateRange.last30Days())
        }
    }

    func refreshRevenue() {
        Task {
            await loadRevenueReports()
        }
    }

    func refreshInsights() {
        Task {
            await loadOptimizationInsights(dateRange: DateRange.last30Days())
        }
    }

    // MARK: - Computed Properties

    var totalMRR: String {
        guard let metrics = subscriptionMetrics else { return "$0" }
        return formatCurrency(metrics.monthlyRecurringRevenue)
    }

    var totalARR: String {
        guard let metrics = subscriptionMetrics else { return "$0" }
        return formatCurrency(metrics.annualRecurringRevenue)
    }

    var trialToPageConversion: String {
        guard let metrics = subscriptionMetrics else { return "0%" }
        return "\(String(format: "%.1f", metrics.trialToPaidConversion * 100))%"
    }

    var churnRate: String {
        guard let metrics = subscriptionMetrics else { return "0%" }
        return "\(String(format: "%.1f", metrics.churnRate * 100))%"
    }

    var averageRevenue: String {
        guard let metrics = subscriptionMetrics else { return "$0" }
        return formatCurrency(metrics.averageRevenuePerUser)
    }

    var lifetimeValue: String {
        guard let metrics = subscriptionMetrics else { return "$0" }
        return formatCurrency(metrics.customerLifetimeValue)
    }

    // MARK: - Helper Methods

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Mock Services

class MockAnalyticsRepository: AnalyticsRepository {
    func saveEvent(_ event: AnalyticsEvent) async throws {
        // Mock implementation
    }

    func fetchEvents(for userID: String, dateRange: DateRange?) async throws -> [AnalyticsEvent] {
        // Return mock events for testing
        return createMockEvents()
    }

    func saveAggregation(_ aggregation: AnalyticsAggregation) async throws {
        // Mock implementation
    }

    func fetchAggregations(for aggregationType: AggregationType, dateRange: DateRange?) async throws -> [AnalyticsAggregation] {
        // Mock implementation
        return []
    }

    func saveConsent(_ consent: AnalyticsConsent) async throws {
        // Mock implementation
    }

    func fetchConsent(for familyID: String) async throws -> AnalyticsConsent? {
        // Mock implementation
        return nil
    }

    private func createMockEvents() -> [AnalyticsEvent] {
        let now = Date()
        let calendar = Calendar.current

        var events: [AnalyticsEvent] = []

        // Create mock subscription events
        for i in 0..<100 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now

            // Paywall impressions
            events.append(AnalyticsEvent(
                eventType: .subscriptionEvent(
                    eventType: .paywallImpression,
                    metadata: [
                        "paywall_id": "main_paywall",
                        "trigger": "feature_gate",
                        "family_id": "family_\(i % 20)"
                    ]
                ),
                timestamp: date,
                anonymizedUserID: "anon_user_\(i % 20)",
                sessionID: "session_\(i)",
                appVersion: "1.0.0",
                osVersion: "iOS 15.0",
                deviceModel: "iPhone"
            ))

            // Trial starts (20% conversion)
            if i % 5 == 0 {
                events.append(AnalyticsEvent(
                    eventType: .subscriptionEvent(
                        eventType: .trialStart,
                        metadata: [
                            "tier": "family_plus",
                            "family_id": "family_\(i % 20)",
                            "acquisition_channel": i % 3 == 0 ? "organic" : "referral"
                        ]
                    ),
                    timestamp: date,
                    anonymizedUserID: "anon_user_\(i % 20)",
                    sessionID: "session_\(i)",
                    appVersion: "1.0.0",
                    osVersion: "iOS 15.0",
                    deviceModel: "iPhone"
                ))
            }

            // Purchases (30% of trials convert)
            if i % 15 == 0 {
                events.append(AnalyticsEvent(
                    eventType: .subscriptionEvent(
                        eventType: .purchase,
                        metadata: [
                            "product_id": "family_plus_monthly",
                            "price": "9.99",
                            "currency": "USD",
                            "tier": "family_plus",
                            "was_in_trial": "true",
                            "family_id": "family_\(i % 20)"
                        ]
                    ),
                    timestamp: date,
                    anonymizedUserID: "anon_user_\(i % 20)",
                    sessionID: "session_\(i)",
                    appVersion: "1.0.0",
                    osVersion: "iOS 15.0",
                    deviceModel: "iPhone"
                ))
            }

            // Feature gate encounters
            if i % 3 == 0 {
                events.append(AnalyticsEvent(
                    eventType: .subscriptionEvent(
                        eventType: .featureGateEncounter,
                        metadata: [
                            "feature": "advanced_reports",
                            "gate_trigger": "report_access",
                            "user_response": i % 10 == 0 ? "upgrade" : "dismiss"
                        ]
                    ),
                    timestamp: date,
                    anonymizedUserID: "anon_user_\(i % 20)",
                    sessionID: "session_\(i)",
                    appVersion: "1.0.0",
                    osVersion: "iOS 15.0",
                    deviceModel: "iPhone"
                ))
            }
        }

        return events
    }
}

