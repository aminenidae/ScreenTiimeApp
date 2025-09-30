# Reporting and Analytics Dashboard Specification

## Overview

This document provides detailed requirements and specifications for implementing comprehensive reporting and analytics dashboard features (Epic 4) which are essential for providing parents with insights into their children's digital habits and the effectiveness of the reward system.

## Dashboard Architecture

### 1. Data Models

#### UsageReport Model
```swift
struct UsageReport: Codable {
    let id: String
    let familyID: String
    let childID: String
    let period: ReportPeriod
    let startDate: Date
    let endDate: Date
    let totalUsageTime: TimeInterval
    let learningAppUsage: AppUsageSummary
    let rewardAppUsage: AppUsageSummary
    let uncategorizedAppUsage: AppUsageSummary
    let pointsEarned: Int
    let pointsRedeemed: Int
    let rewardTimeUsed: TimeInterval
    let createdAt: Date
    let updatedAt: Date
}

struct AppUsageSummary: Codable {
    let totalTime: TimeInterval
    let appCount: Int
    let topApps: [AppUsageDetail]
    let averageSessionDuration: TimeInterval
}

struct AppUsageDetail: Codable, Identifiable {
    let id: String
    let appName: String
    let appIcon: Data? // Base64 encoded image data
    let bundleID: String
    let totalTime: TimeInterval
    let sessionCount: Int
    let averageSessionDuration: TimeInterval
    let firstUsed: Date
    let lastUsed: Date
}
```

#### GoalProgressReport Model
```swift
struct GoalProgressReport: Codable {
    let id: String
    let familyID: String
    let childID: String
    let period: ReportPeriod
    let startDate: Date
    let endDate: Date
    let learningGoals: [LearningGoalProgress]
    let achievementBadges: [AchievementBadge]
    let streakData: StreakData
    let comparisonData: ComparisonData
    let createdAt: Date
}

struct LearningGoalProgress: Codable {
    let goalID: String
    let goalName: String
    let targetValue: Double
    let currentValue: Double
    let unit: GoalUnit
    let progressPercentage: Double
    let isCompleted: Bool
    let completionDate: Date?
}

enum GoalUnit: String, Codable {
    case minutes
    case hours
    case points
    case sessions
}

struct AchievementBadge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: Data? // Base64 encoded image data
    let earnedDate: Date
    let criteria: String
}

struct StreakData: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let streakStartDate: Date?
    let streakEndDate: Date?
    let dailyUsage: [DailyUsage]
}

struct DailyUsage: Codable {
    let date: Date
    let learningTime: TimeInterval
    let rewardTime: TimeInterval
    let pointsEarned: Int
}

struct ComparisonData: Codable {
    let thisPeriod: UsageMetrics
    let previousPeriod: UsageMetrics
    let changePercentage: Double
}

struct UsageMetrics: Codable {
    let totalLearningTime: TimeInterval
    let totalRewardTime: TimeInterval
    let totalPointsEarned: Int
    let totalPointsRedeemed: Int
    let appCount: Int
}
```

#### AnalyticsEvent Model
```swift
struct AnalyticsEvent: Codable {
    let id: String
    let familyID: String
    let childID: String?
    let eventType: AnalyticsEventType
    let timestamp: Date
    let metadata: [String: AnyCodable]
    let sessionID: String
    let deviceInfo: DeviceInfo
}

enum AnalyticsEventType: String, Codable {
    case appLaunch
    case appClose
    case pointEarned
    case rewardRedeemed
    case goalCompleted
    case badgeEarned
    case parentAction
    case systemEvent
}

struct DeviceInfo: Codable {
    let deviceModel: String
    let osVersion: String
    let appVersion: String
    let locale: String
}
```

### 2. Report Generation Service

#### ReportService
```swift
class ReportService {
    private let cloudKitService: CloudKitService
    private let analyticsService: AnalyticsService
    
    init(cloudKitService: CloudKitService, analyticsService: AnalyticsService) {
        self.cloudKitService = cloudKitService
        self.analyticsService = analyticsService
    }
    
    func generateUsageReport(
        for childID: String,
        period: ReportPeriod,
        dateRange: DateRange? = nil
    ) async throws -> UsageReport {
        let (startDate, endDate) = getDateRange(for: period, customRange: dateRange)
        
        // Fetch usage sessions for the period
        let usageSessions = try await cloudKitService.fetchUsageSessions(
            childID: childID,
            startDate: startDate,
            endDate: endDate
        )
        
        // Categorize usage by app type
        let categorizedUsage = categorizeUsageSessions(usageSessions)
        
        // Calculate point transactions
        let pointTransactions = try await cloudKitService.fetchPointTransactions(
            childID: childID,
            startDate: startDate,
            endDate: endDate
        )
        
        let pointsEarned = pointTransactions.filter { $0.type == .earned }.map { $0.amount }.reduce(0, +)
        let pointsRedeemed = pointTransactions.filter { $0.type == .redeemed }.map { $0.amount }.reduce(0, +)
        
        // Calculate reward redemptions
        let rewardRedemptions = try await cloudKitService.fetchRewardRedemptions(
            childID: childID,
            startDate: startDate,
            endDate: endDate
        )
        
        let rewardTimeUsed = rewardRedemptions.map { $0.timeAllocated }.reduce(0, +)
        
        return UsageReport(
            id: UUID().uuidString,
            familyID: getCurrentFamilyID(),
            childID: childID,
            period: period,
            startDate: startDate,
            endDate: endDate,
            totalUsageTime: usageSessions.map { $0.duration }.reduce(0, +),
            learningAppUsage: categorizedUsage.learning,
            rewardAppUsage: categorizedUsage.reward,
            uncategorizedAppUsage: categorizedUsage.uncategorized,
            pointsEarned: pointsEarned,
            pointsRedeemed: pointsRedeemed,
            rewardTimeUsed: rewardTimeUsed,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func generateGoalProgressReport(
        for childID: String,
        period: ReportPeriod,
        dateRange: DateRange? = nil
    ) async throws -> GoalProgressReport {
        let (startDate, endDate) = getDateRange(for: period, customRange: dateRange)
        
        // Fetch learning goals
        let learningGoals = try await cloudKitService.fetchLearningGoals(for: childID)
        
        // Calculate progress for each goal
        var goalProgress: [LearningGoalProgress] = []
        for goal in learningGoals {
            let progress = try await calculateGoalProgress(
                goal: goal,
                childID: childID,
                startDate: startDate,
                endDate: endDate
            )
            goalProgress.append(progress)
        }
        
        // Fetch achievement badges
        let badges = try await cloudKitService.fetchAchievementBadges(
            childID: childID,
            startDate: startDate,
            endDate: endDate
        )
        
        // Calculate streak data
        let streakData = try await calculateStreakData(
            childID: childID,
            startDate: startDate,
            endDate: endDate
        )
        
        // Calculate comparison data
        let comparisonData = try await calculateComparisonData(
            childID: childID,
            currentPeriod: (startDate, endDate),
            previousPeriod: getPreviousPeriod(for: period, currentDate: startDate)
        )
        
        return GoalProgressReport(
            id: UUID().uuidString,
            familyID: getCurrentFamilyID(),
            childID: childID,
            period: period,
            startDate: startDate,
            endDate: endDate,
            learningGoals: goalProgress,
            achievementBadges: badges,
            streakData: streakData,
            comparisonData: comparisonData,
            createdAt: Date()
        )
    }
    
    func exportReport(_ report: UsageReport, format: ExportFormat) async throws -> Data {
        switch format {
        case .pdf:
            return try generatePDFReport(from: report)
        case .csv:
            return try generateCSVReport(from: report)
        case .json:
            return try JSONEncoder().encode(report)
        }
    }
    
    private func categorizeUsageSessions(_ sessions: [UsageSession]) -> CategorizedUsage {
        var learningSessions: [UsageSession] = []
        var rewardSessions: [UsageSession] = []
        var uncategorizedSessions: [UsageSession] = []
        
        for session in sessions {
            switch session.appCategory {
            case .learning:
                learningSessions.append(session)
            case .reward:
                rewardSessions.append(session)
            case .uncategorized:
                uncategorizedSessions.append(session)
            }
        }
        
        return CategorizedUsage(
            learning: summarizeAppUsage(learningSessions),
            reward: summarizeAppUsage(rewardSessions),
            uncategorized: summarizeAppUsage(uncategorizedSessions)
        )
    }
    
    private func summarizeAppUsage(_ sessions: [UsageSession]) -> AppUsageSummary {
        let appUsageMap = Dictionary(grouping: sessions, by: { $0.appBundleID })
        
        let appDetails = appUsageMap.map { (bundleID, sessions) in
            let appName = sessions.first?.appName ?? "Unknown App"
            let appIcon = sessions.first?.appIcon
            let totalTime = sessions.map { $0.duration }.reduce(0, +)
            let sessionCount = sessions.count
            let averageSession = sessionCount > 0 ? totalTime / Double(sessionCount) : 0
            let firstUsed = sessions.map { $0.startTime }.min() ?? Date()
            let lastUsed = sessions.map { $0.startTime }.max() ?? Date()
            
            return AppUsageDetail(
                id: bundleID,
                appName: appName,
                appIcon: appIcon,
                bundleID: bundleID,
                totalTime: totalTime,
                sessionCount: sessionCount,
                averageSessionDuration: averageSession,
                firstUsed: firstUsed,
                lastUsed: lastUsed
            )
        }.sorted { $0.totalTime > $1.totalTime }
        
        let totalTime = sessions.map { $0.duration }.reduce(0, +)
        let appCount = appUsageMap.count
        let topApps = Array(appDetails.prefix(5)) // Top 5 apps
        let averageSessionDuration = sessions.isEmpty ? 0 : totalTime / Double(sessions.count)
        
        return AppUsageSummary(
            totalTime: totalTime,
            appCount: appCount,
            topApps: topApps,
            averageSessionDuration: averageSessionDuration
        )
    }
    
    private func calculateGoalProgress(
        goal: LearningGoal,
        childID: String,
        startDate: Date,
        endDate: Date
    ) async throws -> LearningGoalProgress {
        // Implementation depends on goal type
        switch goal.goalType {
        case .timeBased(let targetMinutes):
            let totalTime = try await calculateTotalLearningTime(
                childID: childID,
                startDate: startDate,
                endDate: endDate
            )
            let currentValue = totalTime / 60 // Convert to minutes
            let progress = min(100.0, (currentValue / Double(targetMinutes)) * 100)
            
            return LearningGoalProgress(
                goalID: goal.id,
                goalName: goal.name,
                targetValue: Double(targetMinutes),
                currentValue: currentValue,
                unit: .minutes,
                progressPercentage: progress,
                isCompleted: currentValue >= Double(targetMinutes),
                completionDate: currentValue >= Double(targetMinutes) ? Date() : nil
            )
            
        case .pointBased(let targetPoints):
            let totalPoints = try await calculateTotalPointsEarned(
                childID: childID,
                startDate: startDate,
                endDate: endDate
            )
            let progress = min(100.0, (Double(totalPoints) / Double(targetPoints)) * 100)
            
            return LearningGoalProgress(
                goalID: goal.id,
                goalName: goal.name,
                targetValue: Double(targetPoints),
                currentValue: Double(totalPoints),
                unit: .points,
                progressPercentage: progress,
                isCompleted: totalPoints >= targetPoints,
                completionDate: totalPoints >= targetPoints ? Date() : nil
            )
        }
    }
}

struct CategorizedUsage {
    let learning: AppUsageSummary
    let reward: AppUsageSummary
    let uncategorized: AppUsageSummary
}

enum ReportPeriod: String, CaseIterable, Codable {
    case daily
    case weekly
    case monthly
    case quarterly
    case yearly
    case custom
}

struct DateRange {
    let start: Date
    let end: Date
}

enum ExportFormat {
    case pdf
    case csv
    case json
}
```

### 3. Dashboard UI Components

#### ParentDashboardView
```swift
struct ParentDashboardView: View {
    @StateObject private var viewModel = ParentDashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with family info
                    HeaderView(family: viewModel.currentFamily)
                    
                    // Quick Stats Overview
                    QuickStatsView(stats: viewModel.quickStats)
                    
                    // Children Overview
                    ChildrenOverviewView(children: viewModel.children)
                    
                    // Recent Activity Feed
                    ActivityFeedView(activities: viewModel.recentActivities)
                    
                    // Weekly Usage Chart
                    WeeklyUsageChartView(usageData: viewModel.weeklyUsageData)
                    
                    // Top Apps Section
                    TopAppsSectionView(topApps: viewModel.topApps)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Reports") {
                        ReportsListView()
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
        .onAppear {
            viewModel.loadDashboardData()
        }
    }
}
```

#### ReportsListView
```swift
struct ReportsListView: View {
    @StateObject private var viewModel = ReportsListViewModel()
    
    var body: some View {
        List {
            Section("Usage Reports") {
                ForEach(viewModel.usageReports) { report in
                    NavigationLink(destination: UsageReportDetailView(report: report)) {
                        UsageReportRowView(report: report)
                    }
                }
            }
            
            Section("Goal Progress Reports") {
                ForEach(viewModel.goalReports) { report in
                    NavigationLink(destination: GoalProgressReportDetailView(report: report)) {
                        GoalProgressReportRowView(report: report)
                    }
                }
            }
            
            Section("Export Options") {
                Button("Export All Data") {
                    viewModel.exportAllData()
                }
                
                Button("Generate Custom Report") {
                    viewModel.generateCustomReport()
                }
            }
        }
        .navigationTitle("Reports")
        .onAppear {
            viewModel.loadReports()
        }
    }
}
```

#### UsageReportDetailView
```swift
struct UsageReportDetailView: View {
    let report: UsageReport
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Report Header
                ReportHeaderView(report: report)
                
                // Tab Selection
                Picker("Report Sections", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Learning Apps").tag(1)
                    Text("Reward Apps").tag(2)
                    Text("Points").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content based on selected tab
                switch selectedTab {
                case 0:
                    OverviewTabView(report: report)
                case 1:
                    AppUsageTabView(usageSummary: report.learningAppUsage, category: "Learning")
                case 2:
                    AppUsageTabView(usageSummary: report.rewardAppUsage, category: "Reward")
                case 3:
                    PointsTabView(report: report)
                default:
                    OverviewTabView(report: report)
                }
            }
            .padding()
        }
        .navigationTitle("Usage Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Export") {
                    Button("PDF") { exportReport(.pdf) }
                    Button("CSV") { exportReport(.csv) }
                    Button("JSON") { exportReport(.json) }
                }
            }
        }
    }
    
    private func exportReport(_ format: ExportFormat) {
        // Implementation for exporting report
    }
}
```

### 4. Analytics Collection Service

#### AnalyticsService
```swift
class AnalyticsService {
    private let cloudKitService: CloudKitService
    private let sessionID: String
    private var eventBuffer: [AnalyticsEvent] = []
    private let bufferFlushInterval: TimeInterval = 30 // seconds
    
    init(cloudKitService: CloudKitService) {
        self.cloudKitService = cloudKitService
        self.sessionID = UUID().uuidString
        
        // Start buffer flush timer
        Timer.scheduledTimer(withTimeInterval: bufferFlushInterval, repeats: true) { _ in
            Task {
                await self.flushEventBuffer()
            }
        }
    }
    
    func trackEvent(
        type: AnalyticsEventType,
        childID: String? = nil,
        metadata: [String: Any] = [:]
    ) {
        let event = AnalyticsEvent(
            id: UUID().uuidString,
            familyID: getCurrentFamilyID(),
            childID: childID,
            eventType: type,
            timestamp: Date(),
            metadata: metadata.mapValues { AnyCodable($0) },
            sessionID: sessionID,
            deviceInfo: getDeviceInfo()
        )
        
        // Add to buffer
        eventBuffer.append(event)
        
        // Flush immediately for important events
        if isImportantEvent(type) {
            Task {
                await flushEventBuffer()
            }
        }
    }
    
    private func flushEventBuffer() async {
        guard !eventBuffer.isEmpty else { return }
        
        do {
            try await cloudKitService.saveAnalyticsEvents(eventBuffer)
            eventBuffer.removeAll()
        } catch {
            print("Failed to flush analytics events: \(error)")
            // Keep events in buffer for retry
        }
    }
    
    private func isImportantEvent(_ type: AnalyticsEventType) -> Bool {
        switch type {
        case .pointEarned, .rewardRedeemed, .goalCompleted, .badgeEarned:
            return true
        default:
            return false
        }
    }
    
    private func getDeviceInfo() -> DeviceInfo {
        return DeviceInfo(
            deviceModel: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            locale: Locale.current.identifier
        )
    }
}
```

## Implementation Sequence

### Phase 1: Data Collection & Basic Reporting (Week 13)
1. **Analytics Collection**
   - Implement AnalyticsService for tracking user events
   - Add event tracking to core app flows
   - Create CloudKit storage for analytics data

2. **Basic Report Generation**
   - Implement ReportService with usage report generation
   - Create data models for reports
   - Add basic querying capabilities

### Phase 2: Dashboard UI Implementation (Week 13)
1. **Parent Dashboard**
   - Implement ParentDashboardView with quick stats
   - Add children overview section
   - Create activity feed display

2. **Report List View**
   - Implement ReportsListView for browsing reports
   - Add report row views with summaries
   - Create navigation to detailed reports

### Phase 3: Detailed Reporting (Week 13)
1. **Usage Report Details**
   - Implement UsageReportDetailView with tabbed interface
   - Add app usage visualization
   - Create points tracking display

2. **Goal Progress Reports**
   - Implement goal progress tracking
   - Add achievement badge display
   - Create streak visualization

### Phase 4: Advanced Features & Export (Week 14)
1. **Export Functionality**
   - Implement PDF generation for reports
   - Add CSV export capabilities
   - Create JSON export option

2. **Advanced Analytics**
   - Add comparison data between periods
   - Implement trend analysis
   - Create predictive insights

## Visualization Components

### 1. Charts and Graphs

#### UsageChartView
```swift
struct UsageChartView: View {
    let data: [DailyUsage]
    let dataType: UsageDataType
    
    var body: some View {
        Chart(data) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value(dataType.title, getValue(for: dataType, from: day))
            )
            .foregroundStyle(dataType.color)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
    
    private func getValue(for type: UsageDataType, from day: DailyUsage) -> Double {
        switch type {
        case .learningTime:
            return day.learningTime / 3600 // Convert to hours
        case .rewardTime:
            return day.rewardTime / 3600 // Convert to hours
        case .pointsEarned:
            return Double(day.pointsEarned)
        }
    }
}

enum UsageDataType {
    case learningTime
    case rewardTime
    case pointsEarned
    
    var title: String {
        switch self {
        case .learningTime: return "Learning Time (hours)"
        case .rewardTime: return "Reward Time (hours)"
        case .pointsEarned: return "Points Earned"
        }
    }
    
    var color: Color {
        switch self {
        case .learningTime: return .green
        case .rewardTime: return .blue
        case .pointsEarned: return .yellow
        }
    }
}
```

### 2. Progress Indicators

#### GoalProgressView
```swift
struct GoalProgressView: View {
    let goal: LearningGoalProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.goalName)
                    .font(.headline)
                Spacer()
                Text("\(Int(goal.progressPercentage))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: goal.progressPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
            
            HStack {
                Text("\(Int(goal.currentValue)) \(goal.unit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(goal.targetValue)) \(goal.unit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if goal.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Goal Completed!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
```

## Performance Requirements

1. **Report Generation Time**: <5 seconds for standard reports
2. **Dashboard Load Time**: <3 seconds with 10 children
3. **Data Visualization**: Smooth rendering with 100+ data points
4. **Export Performance**: <10 seconds for PDF generation

## Security Considerations

1. **Data Privacy**
   - COPPA compliance for children's data
   - End-to-end encryption for sensitive analytics
   - Proper data retention policies

2. **Access Control**
   - Parent-only access to detailed reports
   - Child-appropriate data display
   - Secure data transmission

3. **Data Integrity**
   - Immutable analytics events
   - Backup and recovery procedures
   - Audit logging for data access

## Testing Strategy

### Unit Tests
- Test report generation algorithms
- Validate data aggregation logic
- Test export functionality
- Verify analytics event tracking

### Integration Tests
- End-to-end report generation
- Dashboard data flow validation
- Export integration testing
- CloudKit synchronization testing

### Performance Tests
- Report generation time measurement
- Dashboard loading performance
- Chart rendering with large datasets
- Export processing time

### User Acceptance Tests
- Dashboard usability testing
- Report clarity and usefulness
- Export functionality validation
- Accessibility compliance

## Dependencies

1. **CloudKit Infrastructure**: Existing CloudKit integration from Epic 1
2. **Usage Tracking**: DeviceActivityMonitor implementation from Epic 2
3. **Point System**: Point tracking implementation from Epic 2
4. **Family Data Model**: Existing family and child models

## Success Metrics

### Functional Metrics
- Reports generated accurately with 99.9% data integrity
- Dashboard loads in <3 seconds for average family
- Export functionality works for 99% of requests
- Analytics events captured for 95% of user actions

### User Experience Metrics
- 80% of parents view reports weekly
- 70% of parents export data monthly
- Dashboard satisfaction rating >4/5
- Report clarity rating >4/5

### Performance Metrics
- Average report generation time <5 seconds
- Dashboard load time <3 seconds
- Export processing time <10 seconds
- Chart rendering smoothness >60 FPS

## Future Extensibility

1. **Machine Learning Insights**: Predictive analytics for usage patterns
2. **Social Features**: Family leaderboard and challenges
3. **Integration APIs**: Third-party educational platform integration
4. **Advanced Export**: Integration with educational institutions' systems