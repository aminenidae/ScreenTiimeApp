import SwiftUI

public enum TypographyTokens {

    // MARK: - Font Families
    public enum FontFamily {
        @available(iOS 16.0, *)
        public static let display = Font.system(.largeTitle, design: .rounded, weight: .bold)
        @available(iOS 16.0, *)
        public static let heading = Font.system(.title, design: .default, weight: .semibold)
        @available(iOS 16.0, *)
        public static let body = Font.system(.body, design: .default, weight: .regular)
        @available(iOS 16.0, *)
        public static let caption = Font.system(.caption, design: .default, weight: .medium)
    }

    // MARK: - Display Styles
    public enum Display {
        public static let large = Font.system(size: 57, weight: .bold, design: .rounded)
        public static let medium = Font.system(size: 45, weight: .bold, design: .rounded)
        public static let small = Font.system(size: 36, weight: .bold, design: .rounded)
    }

    // MARK: - Heading Styles
    public enum Heading {
        public static let h1 = Font.system(size: 32, weight: .bold, design: .default)
        public static let h2 = Font.system(size: 28, weight: .bold, design: .default)
        public static let h3 = Font.system(size: 24, weight: .semibold, design: .default)
        public static let h4 = Font.system(size: 20, weight: .semibold, design: .default)
        public static let h5 = Font.system(size: 18, weight: .medium, design: .default)
        public static let h6 = Font.system(size: 16, weight: .medium, design: .default)
    }

    // MARK: - Body Styles
    public enum Body {
        public static let large = Font.system(size: 18, weight: .regular, design: .default)
        public static let medium = Font.system(size: 16, weight: .regular, design: .default)
        public static let small = Font.system(size: 14, weight: .regular, design: .default)
        public static let extraSmall = Font.system(size: 12, weight: .regular, design: .default)
    }

    // MARK: - Label Styles
    public enum Label {
        public static let large = Font.system(size: 16, weight: .medium, design: .default)
        public static let medium = Font.system(size: 14, weight: .medium, design: .default)
        public static let small = Font.system(size: 12, weight: .medium, design: .default)
        public static let extraSmall = Font.system(size: 10, weight: .medium, design: .default)
    }

    // MARK: - Caption Styles
    public enum Caption {
        public static let large = Font.system(size: 14, weight: .regular, design: .default)
        public static let medium = Font.system(size: 12, weight: .regular, design: .default)
        public static let small = Font.system(size: 10, weight: .regular, design: .default)
    }

    // MARK: - Specialized Styles
    public enum Specialized {
        public static let pointsDisplay = Font.system(size: 24, weight: .bold, design: .rounded)
        public static let achievementTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
        public static let buttonLabel = Font.system(size: 16, weight: .semibold, design: .default)
        public static let tabLabel = Font.system(size: 12, weight: .medium, design: .default)
        public static let navigationTitle = Font.system(size: 20, weight: .semibold, design: .default)
    }

    // MARK: - Line Heights
    public enum LineHeight {
        public static let tight: CGFloat = 1.1
        public static let normal: CGFloat = 1.4
        public static let relaxed: CGFloat = 1.6
        public static let loose: CGFloat = 1.8
    }

    // MARK: - Letter Spacing
    public enum LetterSpacing {
        public static let tight: CGFloat = -0.5
        public static let normal: CGFloat = 0
        public static let wide: CGFloat = 0.5
        public static let extraWide: CGFloat = 1.0
    }
}
