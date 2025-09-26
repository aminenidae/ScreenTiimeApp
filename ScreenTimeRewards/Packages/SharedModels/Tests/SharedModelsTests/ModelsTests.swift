import XCTest
@testable import SharedModels

final class ModelsTests: XCTestCase {

    func testChildProfileInitialization() {
        let parentID = UUID()
        let child = ChildProfile(
            name: "Test Child",
            parentID: parentID,
            pointBalance: 100
        )

        XCTAssertEqual(child.name, "Test Child")
        XCTAssertEqual(child.parentID, parentID)
        XCTAssertEqual(child.pointBalance, 100)
        XCTAssertNotNil(child.id)
    }

    func testParentProfileInitialization() {
        let parent = ParentProfile(
            name: "Test Parent",
            email: "parent@test.com"
        )

        XCTAssertEqual(parent.name, "Test Parent")
        XCTAssertEqual(parent.email, "parent@test.com")
        XCTAssertNotNil(parent.id)
    }

    func testRewardInitialization() {
        let parentID = UUID()
        let reward = Reward(
            title: "Extra Screen Time",
            description: "30 minutes of extra screen time",
            pointCost: 50,
            parentID: parentID
        )

        XCTAssertEqual(reward.title, "Extra Screen Time")
        XCTAssertEqual(reward.pointCost, 50)
        XCTAssertTrue(reward.isActive)
        XCTAssertEqual(reward.parentID, parentID)
    }

    func testScreenTimeSessionInitialization() {
        let childID = UUID()
        let session = ScreenTimeSession(
            childID: childID,
            appName: "Reading App",
            duration: 1800, // 30 minutes
            pointsEarned: 90
        )

        XCTAssertEqual(session.childID, childID)
        XCTAssertEqual(session.appName, "Reading App")
        XCTAssertEqual(session.duration, 1800)
        XCTAssertEqual(session.pointsEarned, 90)
    }

    func testAppCategoryPointsPerMinute() {
        XCTAssertEqual(AppCategory.educational.pointsPerMinute, 2)
        XCTAssertEqual(AppCategory.reading.pointsPerMinute, 3)
        XCTAssertEqual(AppCategory.games.pointsPerMinute, 0)
    }

    func testAppCategoryDisplayNames() {
        XCTAssertEqual(AppCategory.educational.displayName, "Educational")
        XCTAssertEqual(AppCategory.creative.displayName, "Creative")
        XCTAssertEqual(AppCategory.productivity.displayName, "Productivity")
    }
}