import SwiftUI
import SharedModels

public struct ReportsView: View {
    @StateObject private var viewModel: ReportsViewModel
    @State private var selectedTab: ReportTab = .overview
    @State private var showingDatePicker = false
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()

    public init(viewModel: ReportsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Period Selector
                ReportsPeriodSelector(
                    selectedPeriod: $viewModel.selectedPeriod,
                    hasActiveSubscription: viewModel.hasActiveSubscription,
                    onPeriodChange: { period in
                        if !viewModel.canAccessPremiumPeriod(period) {
                            viewModel.requestPremiumFeature()
                        } else if period == .custom {
                            showingDatePicker = true
                        } else {
                            viewModel.selectPeriod(period)
                        }
                    }
                )
                .padding(.horizontal)

                if viewModel.isLoading {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.refreshData()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isEmpty {
                    EmptyStateView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Tab Navigation
                    TabView(selection: $selectedTab) {
                        OverviewTabView(reportsData: viewModel.reportsData)
                            .tabItem {
                                Image(systemName: "chart.bar.fill")
                                Text("Overview")
                            }
                            .tag(ReportTab.overview)

                        CategoriesTabView(reportsData: viewModel.reportsData)
                            .tabItem {
                                Image(systemName: "square.grid.2x2.fill")
                                Text("Categories")
                            }
                            .tag(ReportTab.categories)

                        TrendsTabView(reportsData: viewModel.reportsData)
                            .tabItem {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("Trends")
                            }
                            .tag(ReportTab.trends)
                    }
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        if viewModel.hasActiveSubscription {
                            // TODO: Implement share functionality
                            print("Implement share functionality")
                        } else {
                            viewModel.requestPremiumFeature()
                        }
                    }
                    .disabled(viewModel.reportsData == nil)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                CustomDateRangePickerView(
                    startDate: $customStartDate,
                    endDate: $customEndDate,
                    onSave: { start, end in
                        let dateRange = AnalyticsCalculator.createCustomDateRange(start: start, end: end)
                        viewModel.selectCustomDateRange(dateRange)
                        showingDatePicker = false
                    },
                    onCancel: {
                        showingDatePicker = false
                    }
                )
            }
            .sheet(isPresented: $viewModel.showUpgradePrompt) {
                UpgradePromptView(
                    onUpgrade: {
                        // In a real app, this would navigate to subscription flow
                        print("Navigate to subscription upgrade")
                        viewModel.dismissUpgradePrompt()
                    },
                    onCancel: {
                        viewModel.dismissUpgradePrompt()
                    }
                )
            }
        }
        .onAppear {
            if viewModel.selectedChild != nil {
                viewModel.loadReportsData()
            }
        }
    }
}

// MARK: - Report Tabs

enum ReportTab: String, CaseIterable {
    case overview = "Overview"
    case categories = "Categories"
    case trends = "Trends"
}

// MARK: - Period Selector

struct ReportsPeriodSelector: View {
    @Binding var selectedPeriod: ReportPeriod
    let hasActiveSubscription: Bool
    let onPeriodChange: (ReportPeriod) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ReportPeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        period: period,
                        isSelected: selectedPeriod == period,
                        isPremium: isPremiumPeriod(period),
                        hasAccess: hasActiveSubscription || !isPremiumPeriod(period),
                        action: { onPeriodChange(period) }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private func isPremiumPeriod(_ period: ReportPeriod) -> Bool {
        switch period {
        case .today, .week:
            return false
        case .month, .custom:
            return true
        }
    }
}

struct PeriodButton: View {
    let period: ReportPeriod
    let isSelected: Bool
    let isPremium: Bool
    let hasAccess: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(period.rawValue)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(textColor)

                if isPremium && !hasAccess {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(textColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: isPremium && !hasAccess ? 1 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isPremium && !hasAccess ? 0.7 : 1.0)
    }

    private var textColor: Color {
        if isPremium && !hasAccess {
            return .secondary
        }
        return isSelected ? .white : .primary
    }

    private var backgroundColor: Color {
        if isPremium && !hasAccess {
            return Color.gray.opacity(0.1)
        }
        return isSelected ? Color.blue : Color.gray.opacity(0.2)
    }

    private var borderColor: Color {
        return Color.orange.opacity(0.6)
    }
}

// MARK: - Overview Tab

struct OverviewTabView: View {
    let reportsData: ReportsData?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let data = reportsData {
                    ReportsSummaryCard(summary: data.summary)
                    CategoryQuickView(breakdown: data.categoryBreakdown)
                    TrendQuickView(trends: data.trends)
                }
            }
            .padding()
        }
    }
}

// MARK: - Categories Tab

struct CategoriesTabView: View {
    let reportsData: ReportsData?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let data = reportsData {
                    CategoryBreakdownView(breakdown: data.categoryBreakdown)
                    AppUsageListView(appDetails: data.appDetails)
                }
            }
            .padding()
        }
    }
}

// MARK: - Trends Tab

struct TrendsTabView: View {
    let reportsData: ReportsData?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let data = reportsData {
                    TrendAnalysisView(trends: data.trends)
                    WeeklyComparisonView(comparison: data.trends.weeklyComparison)
                    StreakView(streakData: data.trends.streakData)
                }
            }
            .padding()
        }
    }
}

// MARK: - Custom Date Range Picker

struct CustomDateRangePickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onSave: (Date, Date) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)

                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(.compact)

                Spacer()
            }
            .padding()
            .navigationTitle("Custom Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(startDate, endDate)
                    }
                    .disabled(startDate > endDate)
                }
            }
        }
    }
}

// MARK: - Loading and Error States

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading reports...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
        }
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Error Loading Reports")
                .font(.headline)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("No Data Available")
                .font(.headline)

            Text("No usage data found for the selected period. Check back after some app usage has been recorded.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Upgrade Prompt

struct UpgradePromptView: View {
    let onUpgrade: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 16) {
                    Text("Unlock Advanced Reports")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Get access to detailed historical data, monthly views, custom date ranges, and comprehensive analytics.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    FeatureRow(icon: "calendar", text: "Monthly and custom date ranges")
                    FeatureRow(icon: "chart.bar.fill", text: "Detailed trend analysis")
                    FeatureRow(icon: "square.and.arrow.up", text: "Advanced export options")
                    FeatureRow(icon: "clock.arrow.circlepath", text: "Complete historical data")
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 12) {
                    Button("Upgrade to Premium") {
                        onUpgrade()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)

                    Button("Maybe Later") {
                        onCancel()
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Premium Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onCancel()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

#Preview {
    // Create mock view model for preview
    let mockUsageRepo = MockUsageSessionRepository()
    let mockPointRepo = MockPointTransactionRepository()
    let mockAppRepo = MockAppCategorizationRepository()
    let mockChildRepo = MockChildProfileRepository()

    let viewModel = ReportsViewModel(
        usageSessionRepository: mockUsageRepo,
        pointTransactionRepository: mockPointRepo,
        appCategorizationRepository: mockAppRepo,
        childProfileRepository: mockChildRepo
    )

    return ReportsView(viewModel: viewModel)
}

// MARK: - Mock Repositories for Preview

class MockUsageSessionRepository: UsageSessionRepository {
    func createSession(_ session: UsageSession) async throws -> UsageSession { session }
    func fetchSession(id: String) async throws -> UsageSession? { nil }
    func fetchSessions(for childID: String, dateRange: DateRange?) async throws -> [UsageSession] { [] }
    func updateSession(_ session: UsageSession) async throws -> UsageSession { session }
    func deleteSession(id: String) async throws { }
}

class MockPointTransactionRepository: PointTransactionRepository {
    func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction { transaction }
    func fetchTransaction(id: String) async throws -> PointTransaction? { nil }
    func fetchTransactions(for childID: String, limit: Int?) async throws -> [PointTransaction] { [] }
    func fetchTransactions(for childID: String, dateRange: DateRange?) async throws -> [PointTransaction] { [] }
    func deleteTransaction(id: String) async throws { }
}

class MockAppCategorizationRepository: AppCategorizationRepository {
    func createAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization { categorization }
    func fetchAppCategorization(id: String) async throws -> AppCategorization? { nil }
    func fetchAppCategorizations(for childID: String) async throws -> [AppCategorization] { [] }
    func updateAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization { categorization }
    func deleteAppCategorization(id: String) async throws { }
}

class MockChildProfileRepository: ChildProfileRepository {
    func createChild(_ child: ChildProfile) async throws -> ChildProfile { child }
    func fetchChild(id: String) async throws -> ChildProfile? { nil }
    func fetchChildren(for familyID: String) async throws -> [ChildProfile] { [] }
    func updateChild(_ child: ChildProfile) async throws -> ChildProfile { child }
    func deleteChild(id: String) async throws { }
}