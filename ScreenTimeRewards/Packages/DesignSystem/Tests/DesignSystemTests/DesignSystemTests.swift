import XCTest
import SwiftUI
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {

    func testColorTokensExist() {
        // Test that all color tokens are accessible
        XCTAssertNotNil(ColorTokens.Primary.blue500)
        XCTAssertNotNil(ColorTokens.Secondary.purple500)
        XCTAssertNotNil(ColorTokens.Neutral.black)
        XCTAssertNotNil(ColorTokens.Neutral.white)
        XCTAssertNotNil(ColorTokens.Gamification.points)
    }

    func testTypographyTokensExist() {
        // Test that all typography tokens are accessible
        XCTAssertNotNil(TypographyTokens.Display.large)
        XCTAssertNotNil(TypographyTokens.Heading.h1)
        XCTAssertNotNil(TypographyTokens.Body.medium)
        XCTAssertNotNil(TypographyTokens.Specialized.pointsDisplay)
    }

    func testSpacingTokensValues() {
        // Test spacing token values follow 4pt grid
        XCTAssertEqual(SpacingTokens.xs, 4)
        XCTAssertEqual(SpacingTokens.sm, 8)
        XCTAssertEqual(SpacingTokens.md, 16)
        XCTAssertEqual(SpacingTokens.lg, 24)
        XCTAssertEqual(SpacingTokens.xl, 32)
        XCTAssertEqual(SpacingTokens.xxl, 48)
        XCTAssertEqual(SpacingTokens.xxxl, 64)
    }

    func testIconSystemConstants() {
        // Test that icon system constants are not empty
        XCTAssertFalse(IconSystem.Navigation.dashboard.isEmpty)
        XCTAssertFalse(IconSystem.Gamification.points.isEmpty)
        XCTAssertFalse(IconSystem.Status.success.isEmpty)
        XCTAssertFalse(IconSystem.AppCategory.educational.isEmpty)
    }

    func testDesignSystemConfiguration() {
        // Test design system configuration
        XCTAssertEqual(DesignSystem.version, "1.0.0")
        XCTAssertEqual(DesignSystem.minimumIOSVersion, "15.0")
        XCTAssertEqual(DesignSystem.currentTheme, .light)
    }

    func testAnimationConfiguration() {
        // Test animation configuration
        XCTAssertEqual(DesignSystem.AnimationConfig.globalAnimationScale, 1.0)

        // Test animation scaling
        let scaledDuration = DesignSystem.AnimationConfig.scaleAnimation(duration: 0.3)
        XCTAssertEqual(scaledDuration, 0.3)

        // Test disabling animations
        DesignSystem.AnimationConfig.disableAnimationsForTesting()
        XCTAssertEqual(DesignSystem.AnimationConfig.globalAnimationScale, 0.0)

        // Re-enable for other tests
        DesignSystem.AnimationConfig.enableAnimations()
        XCTAssertEqual(DesignSystem.AnimationConfig.globalAnimationScale, 1.0)
    }

    func testButtonStyleEnums() {
        // Test button style enum cases
        let primaryStyle = DSButton.ButtonStyle.primary
        let secondaryStyle = DSButton.ButtonStyle.secondary
        let tertiaryStyle = DSButton.ButtonStyle.tertiary
        let destructiveStyle = DSButton.ButtonStyle.destructive
        let successStyle = DSButton.ButtonStyle.success

        XCTAssertNotEqual(primaryStyle, secondaryStyle)
        XCTAssertNotEqual(secondaryStyle, tertiaryStyle)
        XCTAssertNotEqual(tertiaryStyle, destructiveStyle)
        XCTAssertNotEqual(destructiveStyle, successStyle)
    }

    func testCardStyleEnums() {
        // Test card style enum cases
        let defaultStyle = DSCard.CardStyle.default
        let secondaryStyle = DSCard.CardStyle.secondary
        let highlightedStyle = DSCard.CardStyle.highlighted
        let warningStyle = DSCard.CardStyle.warning
        let errorStyle = DSCard.CardStyle.error
        let successStyle = DSCard.CardStyle.success

        XCTAssertNotEqual(defaultStyle, secondaryStyle)
        XCTAssertNotEqual(secondaryStyle, highlightedStyle)
        XCTAssertNotEqual(highlightedStyle, warningStyle)
        XCTAssertNotEqual(warningStyle, errorStyle)
        XCTAssertNotEqual(errorStyle, successStyle)
    }

    func testProgressRingDataInitialization() {
        // Test multi-progress ring data initialization
        let ringData = DSMultiProgressRing.RingData(
            progress: 0.75,
            color: ColorTokens.Primary.blue500,
            animated: true,
            showInCenter: true,
            centerTitle: "75%",
            centerSubtitle: "Complete"
        )

        XCTAssertEqual(ringData.progress, 0.75)
        XCTAssertTrue(ringData.animated)
        XCTAssertTrue(ringData.showInCenter)
        XCTAssertEqual(ringData.centerTitle, "75%")
        XCTAssertEqual(ringData.centerSubtitle, "Complete")
    }

    func testPointsDisplayTrend() {
        // Test points display trend initialization
        let positiveTrend = DSPointsCard.Trend(text: "+12%", isPositive: true)
        let negativeTrend = DSPointsCard.Trend(text: "-5%", isPositive: false)

        XCTAssertEqual(positiveTrend.text, "+12%")
        XCTAssertTrue(positiveTrend.isPositive)
        XCTAssertEqual(positiveTrend.icon, "arrow.up.right")

        XCTAssertEqual(negativeTrend.text, "-5%")
        XCTAssertFalse(negativeTrend.isPositive)
        XCTAssertEqual(negativeTrend.icon, "arrow.down.right")
    }

    func testShadowConfiguration() {
        // Test shadow configurations
        let elevation1 = SpacingTokens.Shadow.elevation1
        let elevation2 = SpacingTokens.Shadow.elevation2
        let elevation3 = SpacingTokens.Shadow.elevation3
        let elevation4 = SpacingTokens.Shadow.elevation4

        XCTAssertLessThan(elevation1.radius, elevation2.radius)
        XCTAssertLessThan(elevation2.radius, elevation3.radius)
        XCTAssertLessThan(elevation3.radius, elevation4.radius)

        XCTAssertLessThan(elevation1.y, elevation2.y)
        XCTAssertLessThan(elevation2.y, elevation3.y)
        XCTAssertLessThan(elevation3.y, elevation4.y)
    }

    func testBorderRadiusProgression() {
        // Test that border radius values progress logically
        XCTAssertEqual(SpacingTokens.Radius.none, 0)
        XCTAssertLessThan(SpacingTokens.Radius.xs, SpacingTokens.Radius.sm)
        XCTAssertLessThan(SpacingTokens.Radius.sm, SpacingTokens.Radius.md)
        XCTAssertLessThan(SpacingTokens.Radius.md, SpacingTokens.Radius.lg)
        XCTAssertLessThan(SpacingTokens.Radius.lg, SpacingTokens.Radius.xl)
        XCTAssertLessThan(SpacingTokens.Radius.xl, SpacingTokens.Radius.xxl)
        XCTAssertGreaterThan(SpacingTokens.Radius.full, SpacingTokens.Radius.xxl)
    }

    #if DEBUG
    func testDebugConfiguration() {
        // Test debug configuration (only available in debug builds)
        XCTAssertFalse(DesignSystem.Debug.showComponentBorders)
        XCTAssertFalse(DesignSystem.Debug.logComponentRenders)

        DesignSystem.Debug.enableDebugMode()
        XCTAssertTrue(DesignSystem.Debug.showComponentBorders)
        XCTAssertTrue(DesignSystem.Debug.logComponentRenders)

        DesignSystem.Debug.disableDebugMode()
        XCTAssertFalse(DesignSystem.Debug.showComponentBorders)
        XCTAssertFalse(DesignSystem.Debug.logComponentRenders)
    }
    #endif

    func testThemeConfiguration() {
        // Test theme configuration
        let lightTheme = DesignSystem.Theme.light
        let darkTheme = DesignSystem.Theme.dark
        let autoTheme = DesignSystem.Theme.auto

        XCTAssertEqual(lightTheme.colorScheme, .light)
        XCTAssertEqual(darkTheme.colorScheme, .dark)
        XCTAssertNil(autoTheme.colorScheme)
    }
}