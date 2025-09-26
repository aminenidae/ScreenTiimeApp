import XCTest
@testable import RewardCore
@testable import SharedModels

final class RewardCoreTests: XCTestCase {

    func testCalculatePoints_EducationalApp_ReturnsCorrectPoints() {
        let core = RewardCore.shared
        let childID = UUID()

        // 30 minutes = 1800 seconds, educational app = 2 points per minute
        let session = ScreenTimeSession(
            childID: childID,
            appName: "Educational App",
            duration: 1800,
            pointsEarned: 0
        )

        let points = core.calculatePoints(for: session, category: .educational)

        XCTAssertEqual(points, 60) // 30 minutes * 2 points per minute
    }

    func testCalculatePoints_ReadingApp_ReturnsCorrectPoints() {
        let core = RewardCore.shared
        let childID = UUID()

        // 20 minutes = 1200 seconds, reading app = 3 points per minute
        let session = ScreenTimeSession(
            childID: childID,
            appName: "Reading App",
            duration: 1200,
            pointsEarned: 0
        )

        let points = core.calculatePoints(for: session, category: .reading)

        XCTAssertEqual(points, 60) // 20 minutes * 3 points per minute
    }

    func testCalculatePoints_GamesApp_ReturnsZeroPoints() {
        let core = RewardCore.shared
        let childID = UUID()

        let session = ScreenTimeSession(
            childID: childID,
            appName: "Game App",
            duration: 1800,
            pointsEarned: 0
        )

        let points = core.calculatePoints(for: session, category: .games)

        XCTAssertEqual(points, 0) // Games earn 0 points per minute
    }

    func testCalculateDailyPoints_MultipleSessions_ReturnsSum() {
        let core = RewardCore.shared
        let childID = UUID()

        let sessions = [
            ScreenTimeSession(childID: childID, appName: "App1", duration: 1800, pointsEarned: 60),
            ScreenTimeSession(childID: childID, appName: "App2", duration: 1200, pointsEarned: 40),
            ScreenTimeSession(childID: childID, appName: "App3", duration: 600, pointsEarned: 20)
        ]

        let totalPoints = core.calculateDailyPoints(for: sessions)

        XCTAssertEqual(totalPoints, 120)
    }

    func testCalculateDailyPoints_EmptyArray_ReturnsZero() {
        let core = RewardCore.shared
        let emptySessionsAray: [ScreenTimeSession] = []

        let totalPoints = core.calculateDailyPoints(for: emptySessionsAray)

        XCTAssertEqual(totalPoints, 0)
    }

    func testCanRedeem_SufficientPoints_ReturnsValid() {
        let core = RewardCore.shared
        let parentID = UUID()

        let childProfile = ChildProfile(
            name: "Test Child",
            parentID: parentID,
            pointBalance: 150
        )

        let reward = Reward(
            title: "Extra Screen Time",
            description: "30 minutes extra",
            pointCost: 100,
            parentID: parentID
        )

        let result = core.canRedeem(reward: reward, for: childProfile)

        if case .valid = result {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected valid redemption")
        }
    }

    func testCanRedeem_InsufficientPoints_ReturnsInsufficientPoints() {
        let core = RewardCore.shared
        let parentID = UUID()

        let childProfile = ChildProfile(
            name: "Test Child",
            parentID: parentID,
            pointBalance: 50
        )

        let reward = Reward(
            title: "Expensive Reward",
            description: "Costs a lot",
            pointCost: 100,
            parentID: parentID
        )

        let result = core.canRedeem(reward: reward, for: childProfile)

        if case .insufficientPoints(let required, let available) = result {
            XCTAssertEqual(required, 100)
            XCTAssertEqual(available, 50)
        } else {
            XCTFail("Expected insufficient points error")
        }
    }

    func testCanRedeem_InactiveReward_ReturnsRewardUnavailable() {
        let core = RewardCore.shared
        let parentID = UUID()

        let childProfile = ChildProfile(
            name: "Test Child",
            parentID: parentID,
            pointBalance: 150
        )

        let reward = Reward(
            title: "Inactive Reward",
            description: "Not available",
            pointCost: 100,
            isActive: false,
            parentID: parentID
        )

        let result = core.canRedeem(reward: reward, for: childProfile)

        if case .rewardUnavailable = result {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected reward unavailable")
        }
    }

    func testRedeemReward_ValidRedemption_ReturnsSuccess() {
        let core = RewardCore.shared
        let parentID = UUID()

        let childProfile = ChildProfile(
            name: "Test Child",
            parentID: parentID,
            pointBalance: 150
        )

        let reward = Reward(
            title: "Valid Reward",
            description: "Can be redeemed",
            pointCost: 100,
            parentID: parentID
        )

        let result = core.redeemReward(reward, for: childProfile)

        if case .success(let transactionID) = result {
            XCTAssertNotNil(transactionID)
        } else {
            XCTFail("Expected successful redemption")
        }
    }

    func testGetAvailableAchievements_ReturnsNonEmptyArray() {
        let core = RewardCore.shared
        let parentID = UUID()

        let childProfile = ChildProfile(
            name: "Test Child",
            parentID: parentID
        )

        let achievements = core.getAvailableAchievements(for: childProfile)

        XCTAssertFalse(achievements.isEmpty)
        XCTAssertEqual(achievements.count, 2) // Sample achievements
    }

    func testCalculateGoalProgress_ReturnsValidProgress() {
        let core = RewardCore.shared
        let childID = UUID()
        let parentID = UUID()

        let childProfile = ChildProfile(
            name: "Test Child",
            parentID: parentID
        )

        let goal = Goal(
            id: UUID(),
            childID: childID,
            title: "Read 10 books",
            targetValue: 10,
            currentValue: 3
        )

        let progress = core.calculateGoalProgress(for: childProfile, goal: goal)

        XCTAssertEqual(progress.goalID, goal.id)
        XCTAssertEqual(progress.targetValue, 10)
        XCTAssertFalse(progress.isCompleted)
    }

    func testCalculateCurrentStreak_ReturnsZero() {
        // Placeholder test since streak calculation is not implemented yet
        let core = RewardCore.shared
        let parentID = UUID()

        let childProfile = ChildProfile(
            name: "Test Child",
            parentID: parentID
        )

        let streak = core.calculateCurrentStreak(for: childProfile, sessions: [])

        XCTAssertEqual(streak, 0)
    }
}