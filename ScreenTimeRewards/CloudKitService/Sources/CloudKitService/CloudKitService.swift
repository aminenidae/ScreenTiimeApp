import Foundation
import SharedModels

/// Main CloudKit service that provides access to all repository implementations
public class CloudKitService {
    public static let shared = CloudKitService()

    // Repository instances
    private let _childProfileRepository: ChildProfileRepository
    private let _appCategorizationRepository: AppCategorizationRepository
    private let _usageSessionRepository: UsageSessionRepository
    private let _pointTransactionRepository: PointTransactionRepository
    private let _pointToTimeRedemptionRepository: PointToTimeRedemptionRepository

    private init() {
        // Initialize all repository implementations
        self._childProfileRepository = MockChildProfileRepository()
        self._appCategorizationRepository = AppCategorizationRepository()
        self._usageSessionRepository = UsageSessionRepository()
        self._pointTransactionRepository = PointTransactionRepository()
        self._pointToTimeRedemptionRepository = PointToTimeRedemptionRepository()
    }
}

// MARK: - Repository Protocol Conformance

@available(iOS 15.0, macOS 10.15, *)
extension CloudKitService: ChildProfileRepository {
    public func createChild(_ child: ChildProfile) async throws -> ChildProfile {
        return try await _childProfileRepository.createChild(child)
    }

    public func fetchChild(id: String) async throws -> ChildProfile? {
        return try await _childProfileRepository.fetchChild(id: id)
    }

    public func fetchChildren(for familyID: String) async throws -> [ChildProfile] {
        return try await _childProfileRepository.fetchChildren(for: familyID)
    }

    public func updateChild(_ child: ChildProfile) async throws -> ChildProfile {
        return try await _childProfileRepository.updateChild(child)
    }

    public func deleteChild(id: String) async throws {
        try await _childProfileRepository.deleteChild(id: id)
    }
}

@available(iOS 15.0, macOS 10.15, *)
extension CloudKitService: SharedModels.AppCategorizationRepository {
    public func createAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization {
        // Map to the existing method
        try await _appCategorizationRepository.saveCategorization(categorization)
        return categorization
    }

    public func fetchAppCategorization(id: String) async throws -> AppCategorization? {
        // In a real implementation, this would fetch by ID
        // For now, return nil as the existing implementation doesn't support ID-based fetch
        return nil
    }

    public func fetchAppCategorizations(for childID: String) async throws -> [AppCategorization] {
        return try await _appCategorizationRepository.fetchCategorizations(for: childID)
    }

    public func updateAppCategorization(_ categorization: AppCategorization) async throws -> AppCategorization {
        // Map to save method (update is same as save in this implementation)
        try await _appCategorizationRepository.saveCategorization(categorization)
        return categorization
    }

    public func deleteAppCategorization(id: String) async throws {
        try await _appCategorizationRepository.deleteCategorization(with: id)
    }
}

@available(iOS 15.0, macOS 10.15, *)
extension CloudKitService: SharedModels.UsageSessionRepository {
    public func createSession(_ session: UsageSession) async throws -> UsageSession {
        return try await _usageSessionRepository.createSession(session)
    }

    public func fetchSession(id: String) async throws -> UsageSession? {
        return try await _usageSessionRepository.fetchSession(id: id)
    }

    public func fetchSessions(for childID: String, dateRange: DateRange?) async throws -> [UsageSession] {
        return try await _usageSessionRepository.fetchSessions(for: childID, dateRange: dateRange)
    }

    public func updateSession(_ session: UsageSession) async throws -> UsageSession {
        return try await _usageSessionRepository.updateSession(session)
    }

    public func deleteSession(id: String) async throws {
        try await _usageSessionRepository.deleteSession(id: id)
    }
}

@available(iOS 15.0, macOS 10.15, *)
extension CloudKitService: SharedModels.PointTransactionRepository {
    public func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction {
        return try await _pointTransactionRepository.createTransaction(transaction)
    }

    public func fetchTransaction(id: String) async throws -> PointTransaction? {
        return try await _pointTransactionRepository.fetchTransaction(id: id)
    }

    public func fetchTransactions(for childID: String, limit: Int?) async throws -> [PointTransaction] {
        return try await _pointTransactionRepository.fetchTransactions(for: childID, limit: limit)
    }

    public func fetchTransactions(for childID: String, dateRange: DateRange?) async throws -> [PointTransaction] {
        return try await _pointTransactionRepository.fetchTransactions(for: childID, dateRange: dateRange)
    }

    public func deleteTransaction(id: String) async throws {
        try await _pointTransactionRepository.deleteTransaction(id: id)
    }
}

@available(iOS 15.0, macOS 10.15, *)
extension CloudKitService: SharedModels.PointToTimeRedemptionRepository {
    public func createPointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption {
        return try await _pointToTimeRedemptionRepository.createPointToTimeRedemption(redemption)
    }

    public func fetchPointToTimeRedemption(id: String) async throws -> PointToTimeRedemption? {
        return try await _pointToTimeRedemptionRepository.fetchPointToTimeRedemption(id: id)
    }

    public func fetchPointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption] {
        return try await _pointToTimeRedemptionRepository.fetchPointToTimeRedemptions(for: childID)
    }

    public func fetchActivePointToTimeRedemptions(for childID: String) async throws -> [PointToTimeRedemption] {
        return try await _pointToTimeRedemptionRepository.fetchActivePointToTimeRedemptions(for: childID)
    }

    public func updatePointToTimeRedemption(_ redemption: PointToTimeRedemption) async throws -> PointToTimeRedemption {
        return try await _pointToTimeRedemptionRepository.updatePointToTimeRedemption(redemption)
    }

    public func deletePointToTimeRedemption(id: String) async throws {
        try await _pointToTimeRedemptionRepository.deletePointToTimeRedemption(id: id)
    }
}

// MARK: - Mock Child Profile Repository

/// Temporary mock implementation for ChildProfileRepository
/// In a real app, this would be implemented with actual CloudKit operations
private class MockChildProfileRepository: ChildProfileRepository {
    private var mockChildren: [String: ChildProfile] = [:]

    func createChild(_ child: ChildProfile) async throws -> ChildProfile {
        mockChildren[child.id] = child
        print("Mock: Created child profile: \(child.name)")
        return child
    }

    func fetchChild(id: String) async throws -> ChildProfile? {
        if let existing = mockChildren[id] {
            return existing
        }

        // Return a mock child for demo purposes
        if id == "mock-child-id" {
            let mockChild = ChildProfile(
                id: id,
                familyID: "mock-family-id",
                name: "Demo Child",
                avatarAssetURL: nil,
                birthDate: Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date(),
                pointBalance: 450,
                totalPointsEarned: 1250
            )
            mockChildren[id] = mockChild
            return mockChild
        }

        return nil
    }

    func fetchChildren(for familyID: String) async throws -> [ChildProfile] {
        return Array(mockChildren.values.filter { $0.familyID == familyID })
    }

    func updateChild(_ child: ChildProfile) async throws -> ChildProfile {
        mockChildren[child.id] = child
        print("Mock: Updated child profile: \(child.name), Balance: \(child.pointBalance)")
        return child
    }

    func deleteChild(id: String) async throws {
        mockChildren.removeValue(forKey: id)
        print("Mock: Deleted child profile: \(id)")
    }
}