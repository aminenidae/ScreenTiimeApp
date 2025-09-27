import Foundation
import SwiftUI
import Combine
import SharedModels
import CloudKitService
import RewardCore

@MainActor
class ParentDashboardViewModel: ObservableObject {
    @Published var children: [ChildProfile] = []
    @Published var childProgressData: [String: ChildProgressData] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastRefreshTime: Date = Date()
    @Published var isPerformingBackgroundUpdate: Bool = false

    private let childProfileRepository: ChildProfileRepository
    private let pointTransactionRepository: PointTransactionRepository
    private let usageSessionRepository: UsageSessionRepository
    private var cancellables = Set<AnyCancellable>()

    // For this demo, we'll use a mock family ID
    // In a real app, this would come from authentication/app state
    private let currentFamilyID = "mock-family-id"

    // Performance benchmarks
    private let performanceTargetLoadTime: TimeInterval = 2.0 // 2 seconds for dashboard load
    private let performanceTargetChildrenLoadTime: TimeInterval = 0.2 // 0.2 seconds per child for progress data

    init(childProfileRepository: ChildProfileRepository = CloudKitService.shared,
         pointTransactionRepository: PointTransactionRepository = CloudKitService.shared,
         usageSessionRepository: UsageSessionRepository = CloudKitService.shared) {
        self.childProfileRepository = childProfileRepository
        self.pointTransactionRepository = pointTransactionRepository
        self.usageSessionRepository = usageSessionRepository

        setupCloudKitSubscriptions()
        setupDataRefreshTimer()
    }

    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Log initial memory usage
            PerformanceMonitor.logMemoryUsage(for: "Dashboard Load Start")
            
            // Load children profiles for the family with performance monitoring
            let loadedChildren = try await PerformanceMonitor.measure(operation: "Load Children Profiles") {
                try await childProfileRepository.fetchChildren(for: currentFamilyID)
            }
            children = loadedChildren

            // Load progress data for each child with performance monitoring and benchmarks
            await PerformanceMonitor.measure(operation: "Load Children Progress Data") {
                await self.loadChildrenProgressData()
            }

            // Check performance benchmarks
            checkPerformanceBenchmarks()

            PerformanceMonitor.logMemoryUsage(for: "Dashboard Initial Load Complete")
            lastRefreshTime = Date()
        } catch {
            errorMessage = "Failed to load family data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func refreshData() async {
        await loadInitialData()
    }

    func getProgressData(for childID: String) -> ChildProgressData {
        return childProgressData[childID] ?? ChildProgressData.empty
    }

    // MARK: - Performance Benchmarking

    private func checkPerformanceBenchmarks() {
        // Check if we're meeting our performance targets
        let childCount = children.count
        
        // For 10+ children, we should load within 2 seconds
        if childCount >= 10 {
            // This check is more for monitoring in tests rather than runtime enforcement
            print("Performance benchmark check: \(childCount) children loaded")
        }
    }

    // MARK: - Private Methods

    private func loadChildrenProgressData() async {
        // Log memory usage before loading progress data
        PerformanceMonitor.logMemoryUsage(for: "Before Load Children Progress Data")
        
        // Performance optimization: Load all children's progress data concurrently
        await withTaskGroup(of: Void.self) { group in
            for child in children {
                group.addTask { @MainActor in
                    await self.loadProgressData(for: child)
                }
            }
        }
        
        // Log memory usage after loading progress data
        PerformanceMonitor.logMemoryUsage(for: "After Load Children Progress Data")
    }

    private func loadProgressData(for child: ChildProfile) async {
        do {
            async let recentTransactions = loadRecentTransactions(for: child.id)
            async let usageSessions = loadTodaysUsage(for: child.id)
            async let weeklyPoints = loadWeeklyPoints(for: child.id)

            let (transactions, sessions, points) = try await (recentTransactions, usageSessions, points)

            let progressData = ChildProgressData(
                recentTransactions: transactions,
                todaysUsage: sessions,
                weeklyPoints: points,
                learningStreak: calculateLearningStreak(from: transactions),
                todaysLearningMinutes: calculateTodaysLearning(from: sessions),
                todaysRewardMinutes: calculateTodaysReward(from: sessions)
            )

            childProgressData[child.id] = progressData
        } catch {
            print("Failed to load progress data for child \(child.name): \(error)")
            childProgressData[child.id] = ChildProgressData.empty
        }
    }

    private func loadRecentTransactions(for childID: String) async throws -> [PointTransaction] {
        return try await pointTransactionRepository.fetchTransactions(for: childID, limit: 5)
    }

    private func loadTodaysUsage(for childID: String) async throws -> [UsageSession] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        let dateRange = DateRange(start: today, end: tomorrow)

        return try await usageSessionRepository.fetchSessions(for: childID, dateRange: dateRange)
    }

    private func loadWeeklyPoints(for childID: String) async throws -> [DailyPointData] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let dateRange = DateRange(start: weekAgo, end: Date())

        let transactions = try await pointTransactionRepository.fetchTransactions(for: childID, dateRange: dateRange)

        return groupTransactionsByDay(transactions)
    }

    private func groupTransactionsByDay(_ transactions: [PointTransaction]) -> [DailyPointData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.timestamp)
        }

        return grouped.map { date, transactions in
            let totalPoints = transactions.filter { $0.points > 0 }.reduce(0) { $0 + $1.points }
            return DailyPointData(date: date, points: totalPoints)
        }.sorted { $0.date < $1.date }
    }

    private func calculateLearningStreak(from transactions: [PointTransaction]) -> Int {
        // Simple implementation: count consecutive days with learning points
        let calendar = Calendar.current
        let learningDays = Set(transactions.filter { $0.points > 0 }.map {
            calendar.startOfDay(for: $0.timestamp)
        })

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        while learningDays.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        return streak
    }

    private func calculateTodaysLearning(from sessions: [UsageSession]) -> Int {
        let learningMinutes = sessions
            .filter { $0.category == .learning }
            .reduce(0) { $0 + Int($1.duration / 60) }
        return learningMinutes
    }

    private func calculateTodaysReward(from sessions: [UsageSession]) -> Int {
        let rewardMinutes = sessions
            .filter { $0.category == .reward }
            .reduce(0) { $0 + Int($1.duration / 60) }
        return rewardMinutes
    }

    // MARK: - Real-time Updates

    private func setupCloudKitSubscriptions() {
        // In a real CloudKit implementation, this would set up subscriptions
        // For now, we'll create a mock subscription that simulates updates
        setupMockSubscriptions()
    }

    private func setupMockSubscriptions() {
        // Simulate periodic data updates for demo purposes
        Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.handleDataUpdate()
                }
            }
            .store(in: &cancellables)
    }

    private func setupDataRefreshTimer() {
        // Auto-refresh data every 5 minutes to keep dashboard current
        Timer.publish(every: 300.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.refreshData()
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func handleDataUpdate() async {
        // Log memory usage before background update
        PerformanceMonitor.logMemoryUsage(for: "Before Background Update")
        
        // Simulate receiving a CloudKit subscription notification
        // In a real implementation, this would be triggered by actual CloudKit changes
        guard !children.isEmpty else { return }

        isPerformingBackgroundUpdate = true

        // Performance optimization: Load progress data concurrently for all children
        await withTaskGroup(of: Void.self) { group in
            for child in children {
                group.addTask { @MainActor in
                    await self.loadProgressData(for: child)
                }
            }
        }

        isPerformingBackgroundUpdate = false
        lastRefreshTime = Date()
        
        // Log memory usage after background update
        PerformanceMonitor.logMemoryUsage(for: "After Background Update")
    }

    func subscribeToChildProfileChanges() {
        // In a real CloudKit implementation, this would create a CKQuerySubscription
        // for ChildProfile changes in the family's shared zone
        print("Setting up CloudKit subscription for ChildProfile changes")
    }

    func subscribeToPointTransactionChanges() {
        // In a real CloudKit implementation, this would create a CKQuerySubscription
        // for PointTransaction changes for all family children
        print("Setting up CloudKit subscription for PointTransaction changes")
    }

    func subscribeToUsageSessionChanges() {
        // In a real CloudKit implementation, this would create a CKQuerySubscription
        // for UsageSession changes for all family children
        print("Setting up CloudKit subscription for UsageSession changes")
    }

    // MARK: - Publishers for Reactive UI Updates

    var childrenPublisher: AnyPublisher<[ChildProfile], Never> {
        $children.eraseToAnyPublisher()
    }

    var progressDataPublisher: AnyPublisher<[String: ChildProgressData], Never> {
        $childProgressData.eraseToAnyPublisher()
    }

    var loadingStatePublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }

    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
}

// MARK: - Supporting Data Types

struct ChildProgressData {
    let recentTransactions: [PointTransaction]
    let todaysUsage: [UsageSession]
    let weeklyPoints: [DailyPointData]
    let learningStreak: Int
    let todaysLearningMinutes: Int
    let todaysRewardMinutes: Int

    static let empty = ChildProgressData(
        recentTransactions: [],
        todaysUsage: [],
        weeklyPoints: [],
        learningStreak: 0,
        todaysLearningMinutes: 0,
        todaysRewardMinutes: 0
    )
}

struct DailyPointData: Identifiable {
    let id = UUID()
    let date: Date
    let points: Int
}

// MARK: - Mock Data for Preview/Testing
extension ParentDashboardViewModel {
    static func mockViewModel() -> ParentDashboardViewModel {
        let viewModel = ParentDashboardViewModel()

        // Mock children
        viewModel.children = [
            ChildProfile(
                id: "child-1",
                familyID: "mock-family-id",
                name: "Emma",
                avatarAssetURL: nil,
                birthDate: Calendar.current.date(byAdding: .year, value: -8, to: Date()) ?? Date(),
                pointBalance: 450,
                totalPointsEarned: 1250
            ),
            ChildProfile(
                id: "child-2",
                familyID: "mock-family-id",
                name: "Alex",
                avatarAssetURL: nil,
                birthDate: Calendar.current.date(byAdding: .year, value: -12, to: Date()) ?? Date(),
                pointBalance: 320,
                totalPointsEarned: 890
            )
        ]

        // Mock progress data
        viewModel.childProgressData = [
            "child-1": ChildProgressData(
                recentTransactions: [
                    PointTransaction(id: "t1", childProfileID: "child-1", points: 30, reason: "Math App", timestamp: Date().addingTimeInterval(-3600)),
                    PointTransaction(id: "t2", childProfileID: "child-1", points: 25, reason: "Reading App", timestamp: Date().addingTimeInterval(-7200))
                ],
                todaysUsage: [],
                weeklyPoints: [
                    DailyPointData(date: Date().addingTimeInterval(-6*24*3600), points: 45),
                    DailyPointData(date: Date().addingTimeInterval(-5*24*3600), points: 30),
                    DailyPointData(date: Date().addingTimeInterval(-4*24*3600), points: 60),
                    DailyPointData(date: Date().addingTimeInterval(-3*24*3600), points: 25),
                    DailyPointData(date: Date().addingTimeInterval(-2*24*3600), points: 40),
                    DailyPointData(date: Date().addingTimeInterval(-1*24*3600), points: 55),
                    DailyPointData(date: Date(), points: 30)
                ],
                learningStreak: 3,
                todaysLearningMinutes: 45,
                todaysRewardMinutes: 20
            ),
            "child-2": ChildProgressData(
                recentTransactions: [
                    PointTransaction(id: "t3", childProfileID: "child-2", points: 40, reason: "Science App", timestamp: Date().addingTimeInterval(-1800)),
                    PointTransaction(id: "t4", childProfileID: "child-2", points: 35, reason: "Language App", timestamp: Date().addingTimeInterval(-5400))
                ],
                todaysUsage: [],
                weeklyPoints: [
                    DailyPointData(date: Date().addingTimeInterval(-6*24*3600), points: 20),
                    DailyPointData(date: Date().addingTimeInterval(-5*24*3600), points: 35),
                    DailyPointData(date: Date().addingTimeInterval(-4*24*3600), points: 40),
                    DailyPointData(date: Date().addingTimeInterval(-3*24*3600), points: 15),
                    DailyPointData(date: Date().addingTimeInterval(-2*24*3600), points: 50),
                    DailyPointData(date: Date().addingTimeInterval(-1*24*3600), points: 30),
                    DailyPointData(date: Date(), points: 40)
                ],
                learningStreak: 5,
                todaysLearningMinutes: 65,
                todaysRewardMinutes: 15
            )
        ]

        return viewModel
    }
    
    // Create a mock view model with many children for performance testing
    static func mockViewModelWithManyChildren(_ count: Int) -> ParentDashboardViewModel {
        let viewModel = ParentDashboardViewModel()
        
        // Create mock children
        viewModel.children = (0..<count).map { index in
            ChildProfile(
                id: "child-\(index)",
                familyID: "mock-family-id",
                name: "Child \(index + 1)",
                avatarAssetURL: nil,
                birthDate: Calendar.current.date(byAdding: .year, value: -8 - (index % 5), to: Date()) ?? Date(),
                pointBalance: 100 + (index * 50),
                totalPointsEarned: 500 + (index * 100)
            )
        }
        
        // Create mock progress data for each child
        viewModel.childProgressData = Dictionary(uniqueKeysWithValues: viewModel.children.map { child in
            let recentTransactions = [
                PointTransaction(id: "\(child.id)-t1", childProfileID: child.id, points: 30, reason: "Math App", timestamp: Date().addingTimeInterval(-3600)),
                PointTransaction(id: "\(child.id)-t2", childProfileID: child.id, points: 25, reason: "Reading App", timestamp: Date().addingTimeInterval(-7200))
            ]
            
            let weeklyPoints = (0..<7).map { dayOffset in
                DailyPointData(date: Date().addingTimeInterval(-Double(dayOffset)*24*3600), points: 20 + (dayOffset * 5))
            }
            
            let progressData = ChildProgressData(
                recentTransactions: recentTransactions,
                todaysUsage: [],
                weeklyPoints: weeklyPoints,
                learningStreak: 3 + (index % 4),
                todaysLearningMinutes: 30 + (index * 2),
                todaysRewardMinutes: 15 + index
            )
            
            return (child.id, progressData)
        })
        
        return viewModel
    }
}