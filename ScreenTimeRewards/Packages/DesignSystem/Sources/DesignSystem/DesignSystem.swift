import SwiftUI
import SharedModels
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Design System Public API

// All design system components are automatically available within the same module
// No need for re-exports since all components are part of the DesignSystem module

/// Main Design System configuration and utilities
public struct DesignSystem {

    // MARK: - Configuration
    public static let version = "1.0.0"
    public static let minimumIOSVersion = "15.0"

    // MARK: - Theme Configuration
    public static var currentTheme: Theme = .light

    public enum Theme {
        case light
        case dark
        case auto // Follow system appearance

        public var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .auto: return nil
            }
        }
    }

    // MARK: - Accessibility Configuration
    public struct AccessibilityConfig {
        public static var preferredContentSizeCategory: ContentSizeCategory = .medium
        public static var isReduceMotionEnabled = false
        public static var isHighContrastEnabled = false

        public static func configure() {
            // Configure accessibility settings based on system preferences
            // This would be called during app initialization
        }
    }

    // MARK: - Animation Configuration
    public struct AnimationConfig {
        public static var globalAnimationScale: Double = 1.0

        public static func scaleAnimation(duration: Double) -> Double {
            return duration * globalAnimationScale
        }

        public static func disableAnimationsForTesting() {
            globalAnimationScale = 0.0
        }

        public static func enableAnimations() {
            globalAnimationScale = 1.0
        }
    }

    // MARK: - Preview Helpers
    public struct Preview {
        public static func sampleChildProfile() -> SharedModels.ChildProfile {
            SharedModels.ChildProfile(
                name: "Emma",
                parentID: UUID(),
                pointBalance: 1250
            )
        }

        public static func sampleReward() -> SharedModels.Reward {
            SharedModels.Reward(
                title: "Extra Screen Time",
                description: "30 minutes of additional screen time",
                pointCost: 100,
                parentID: UUID()
            )
        }

        public static func sampleScreenTimeSession() -> SharedModels.ScreenTimeSession {
            SharedModels.ScreenTimeSession(
                childID: UUID(),
                appName: "Reading App",
                duration: 1800,
                pointsEarned: 90
            )
        }
    }

    // MARK: - Debug Tools
    #if DEBUG
    public struct Debug {
        public static var showComponentBorders = false
        public static var logComponentRenders = false

        public static func enableDebugMode() {
            showComponentBorders = true
            logComponentRenders = true
        }

        public static func disableDebugMode() {
            showComponentBorders = false
            logComponentRenders = false
        }
    }
    #endif

    // MARK: - Utility Functions
    public static func applyGlobalTheme() -> some View {
        EmptyView()
            .preferredColorScheme(currentTheme.colorScheme)
    }

    public static func configureAppearance() {
        // Configure global app appearance
        // This should be called during app launch

        #if canImport(UIKit)
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(ColorTokens.Background.primary)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(ColorTokens.Text.primary),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(ColorTokens.Background.primary)

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        #endif
    }
}

// MARK: - Design System Environment
private struct DesignSystemEnvironmentKey: EnvironmentKey {
    static let defaultValue = DesignSystem.self
}

extension EnvironmentValues {
    public var designSystem: DesignSystem.Type {
        get { self[DesignSystemEnvironmentKey.self] }
        set { self[DesignSystemEnvironmentKey.self] = newValue }
    }
}