import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public enum SpacingTokens {

    // MARK: - Base Spacing Scale (4pt grid)
    public static let none: CGFloat = 0
    public static let xs: CGFloat = 4      // 0.25rem
    public static let sm: CGFloat = 8      // 0.5rem
    public static let md: CGFloat = 16     // 1rem
    public static let lg: CGFloat = 24     // 1.5rem
    public static let xl: CGFloat = 32     // 2rem
    public static let xxl: CGFloat = 48    // 3rem
    public static let xxxl: CGFloat = 64   // 4rem

    // MARK: - Component Specific Spacing
    public enum Component {
        // Padding inside components
        public static let buttonPaddingVertical: CGFloat = 12
        public static let buttonPaddingHorizontal: CGFloat = 24
        public static let cardPadding: CGFloat = 16
        public static let inputPadding: CGFloat = 12
        public static let chipPadding: CGFloat = 8

        // Margins between components
        public static let sectionSpacing: CGFloat = 32
        public static let itemSpacing: CGFloat = 16
        public static let groupSpacing: CGFloat = 8
        public static let listItemSpacing: CGFloat = 12
    }

    // MARK: - Layout Spacing
    public enum Layout {
        // Screen margins
        public static let screenMargin: CGFloat = 20
        public static let safeAreaMargin: CGFloat = 16

        // Container spacing
        public static let containerPadding: CGFloat = 20
        public static let cardMargin: CGFloat = 16
        public static let modalPadding: CGFloat = 24

        // Grid spacing
        public static let gridGap: CGFloat = 16
        public static let columnGap: CGFloat = 12
        public static let rowGap: CGFloat = 16
    }

    // MARK: - Icon Spacing
    public enum Icon {
        public static let small: CGFloat = 16
        public static let medium: CGFloat = 24
        public static let large: CGFloat = 32
        public static let extraLarge: CGFloat = 48
        public static let hero: CGFloat = 64

        // Icon with text spacing
        public static let textSpacing: CGFloat = 8
        public static let buttonIconSpacing: CGFloat = 6
    }

    // MARK: - Border Radius
    public enum Radius {
        public static let none: CGFloat = 0
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 20
        public static let xxl: CGFloat = 24
        public static let full: CGFloat = 9999 // For circular elements
    }

    // MARK: - Shadow
    public enum Shadow {
        public static let elevation1 = Shadow(
            color: .black.opacity(0.05),
            radius: 1,
            x: 0,
            y: 1
        )

        public static let elevation2 = Shadow(
            color: .black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )

        public static let elevation3 = Shadow(
            color: .black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )

        public static let elevation4 = Shadow(
            color: .black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )

        public struct Shadow {
            public let color: Color
            public let radius: CGFloat
            public let x: CGFloat
            public let y: CGFloat

            public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
                self.color = color
                self.radius = radius
                self.x = x
                self.y = y
            }
        }
    }

    // MARK: - Animation Timing
    public enum Animation {
        public static let fast: Double = 0.2
        public static let normal: Double = 0.3
        public static let slow: Double = 0.5
        public static let verySlow: Double = 0.8

        // Specialized animations
        public static let buttonPress: Double = 0.1
        public static let modalPresentation: Double = 0.4
        public static let loadingAnimation: Double = 1.0
        public static let progressAnimation: Double = 0.6
    }
}