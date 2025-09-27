import Foundation
import Combine
import SharedModels

@MainActor
public class ReportsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public var reportsData: ReportsData?
    @Published public var selectedPeriod: ReportPeriod = .week
    @Published public var customDateRange: DateRange?
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var selectedChild: ChildProfile?
    @Published public var hasActiveSubscription = false
    @Published public var showUpgradePrompt = false

    // MARK: - Private Properties

    private let usageSessionRepository: UsageSessionRepository
    private let pointTransactionRepository: PointTransactionRepository
    private let appCategorizationRepository: AppCategorizationRepository
    private let childProfileRepository: ChildProfileRepository
    private let subscriptionRepository: SubscriptionEntitlementRepository?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        usageSessionRepository: UsageSessionRepository,
        pointTransactionRepository: PointTransactionRepository,
        appCategorizationRepository: AppCategorizationRepository,
        childProfileRepository: ChildProfileRepository,
        subscriptionRepository: SubscriptionEntitlementRepository? = nil
    ) {
        self.usageSessionRepository = usageSessionRepository
        self.pointTransactionRepository = pointTransactionRepository
        self.appCategorizationRepository = appCategorizationRepository
        self.childProfileRepository = childProfileRepository
        self.subscriptionRepository = subscriptionRepository
    }

    // MARK: - Public Methods

    public func loadReportsData() {
        guard let selectedChild = selectedChild else {
            errorMessage = "No child profile selected"
            return
        }

        Task {
            await loadReportsData(for: selectedChild)
        }
    }

    public func selectPeriod(_ period: ReportPeriod) {
        selectedPeriod = period
        customDateRange = nil
        loadReportsData()
    }

    public func selectCustomDateRange(_ dateRange: DateRange) {
        selectedPeriod = .custom
        customDateRange = dateRange
        loadReportsData()
    }

    public func selectChild(_ child: ChildProfile) {
        selectedChild = child
        loadReportsData()
    }

    public func refreshData() {
        loadReportsData()
    }

    public func requestPremiumFeature() {
        if !hasActiveSubscription {
            showUpgradePrompt = true
        }
    }

    public func dismissUpgradePrompt() {
        showUpgradePrompt = false
    }

    public func canAccessPremiumPeriod(_ period: ReportPeriod) -> Bool {
        // Basic users can only access limited periods
        if hasActiveSubscription {
            return true
        }

        // Basic users can access today and this week, but not month or custom ranges > 7 days
        switch period {
        case .today, .week:
            return true
        case .month, .custom:
            return false
        }
    }

    // MARK: - Private Methods

    private func loadReportsData(for child: ChildProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            let dateRange = customDateRange ?? selectedPeriod.dateRange

            // Check subscription status for premium features
            let hasAdvancedFeatures = await checkAdvancedFeaturesAccess(for: child.familyID)
            await MainActor.run {
                self.hasActiveSubscription = hasAdvancedFeatures
            }

            // Fetch data from repositories
            async let sessions = fetchUsageSessions(for: child.id, dateRange: dateRange, hasAdvancedFeatures: hasAdvancedFeatures)
            async let transactions = fetchPointTransactions(for: child.id, dateRange: dateRange, hasAdvancedFeatures: hasAdvancedFeatures)
            async let categorizations = fetchAppCategorizations(for: child.id)

            let (usageSessions, pointTransactions, appCategorizations) = try await (sessions, transactions, categorizations)

            // Calculate analytics
            let summary = AnalyticsCalculator.calculateReportSummary(
                sessions: usageSessions,
                transactions: pointTransactions
            )

            let categoryBreakdown = AnalyticsCalculator.calculateCategoryBreakdown(
                sessions: usageSessions,
                transactions: pointTransactions,
                categorizations: appCategorizations
            )

            let trends = AnalyticsCalculator.calculateTrendAnalysis(
                sessions: usageSessions,
                transactions: pointTransactions,
                dateRange: dateRange
            )

            let appDetails = AnalyticsCalculator.calculateAppUsageDetails(
                sessions: usageSessions,
                transactions: pointTransactions,
                categorizations: appCategorizations
            )

            // Create reports data
            let reports = ReportsData(
                period: selectedPeriod,
                dateRange: dateRange,
                summary: summary,
                categoryBreakdown: categoryBreakdown,
                trends: trends,
                appDetails: appDetails
            )

            reportsData = reports
            isLoading = false

        } catch {
            errorMessage = "Failed to load reports data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func checkAdvancedFeaturesAccess(for familyID: String) async -> Bool {
        guard let subscriptionRepository = subscriptionRepository else {
            return false // No subscription service means basic features only
        }

        do {
            let entitlements = try await subscriptionRepository.fetchEntitlements(for: familyID)
            return entitlements.contains { $0.isActive }
        } catch {
            return false // Error accessing subscription = basic features only
        }
    }

    private func fetchUsageSessions(
        for childID: String,
        dateRange: DateRange,
        hasAdvancedFeatures: Bool
    ) async throws -> [UsageSession] {
        // Apply premium restrictions if needed
        let effectiveDateRange = hasAdvancedFeatures ? dateRange : restrictToBasicPeriod(dateRange)

        return try await usageSessionRepository.fetchSessions(
            for: childID,
            dateRange: effectiveDateRange
        )
    }

    private func fetchPointTransactions(
        for childID: String,
        dateRange: DateRange,
        hasAdvancedFeatures: Bool
    ) async throws -> [PointTransaction] {
        // Apply premium restrictions if needed
        let effectiveDateRange = hasAdvancedFeatures ? dateRange : restrictToBasicPeriod(dateRange)

        return try await pointTransactionRepository.fetchTransactions(
            for: childID,
            dateRange: effectiveDateRange
        )
    }

    private func fetchAppCategorizations(for childID: String) async throws -> [AppCategorization] {
        return try await appCategorizationRepository.fetchAppCategorizations(for: childID)
    }

    private func restrictToBasicPeriod(_ dateRange: DateRange) -> DateRange {
        // Basic tier: Last 7 days only
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        let restrictedStart = max(dateRange.start, sevenDaysAgo)
        return DateRange(start: restrictedStart, end: dateRange.end)
    }

    // MARK: - Computed Properties

    public var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if let customRange = customDateRange {
            return "\(formatter.string(from: customRange.start)) - \(formatter.string(from: customRange.end))"
        } else {
            return selectedPeriod.rawValue
        }
    }

    public var hasAdvancedFeatures: Bool {
        return hasActiveSubscription
    }

    public var isDataAvailable: Bool {
        reportsData != nil && !isLoading
    }

    public var isEmpty: Bool {
        guard let data = reportsData else { return true }
        return data.summary.totalTimeMinutes == 0
    }

    // MARK: - Helper Methods for UI

    public func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }

    public func formatPoints(_ points: Int) -> String {
        if points >= 1000 {
            let thousands = Double(points) / 1000.0
            return String(format: "%.1fK", thousands)
        } else {
            return "\(points)"
        }
    }

    public func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.1f%%", percentage)
    }

    public func trendIcon(for direction: TrendDirection) -> String {
        switch direction {
        case .up:
            return "arrow.up.circle.fill"
        case .down:
            return "arrow.down.circle.fill"
        case .stable:
            return "minus.circle.fill"
        }
    }

    public func trendColor(for direction: TrendDirection) -> String {
        switch direction {
        case .up:
            return "green"
        case .down:
            return "red"
        case .stable:
            return "gray"
        }
    }
}