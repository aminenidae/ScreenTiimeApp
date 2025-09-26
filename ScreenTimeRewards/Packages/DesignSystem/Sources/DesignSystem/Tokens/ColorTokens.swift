import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public enum ColorTokens {

    // MARK: - Primary Colors
    public enum Primary {
        public static let blue500 = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
        public static let blue400 = Color(red: 0.2, green: 0.58, blue: 1.0)
        public static let blue300 = Color(red: 0.4, green: 0.68, blue: 1.0)
        public static let blue200 = Color(red: 0.6, green: 0.78, blue: 1.0)
        public static let blue100 = Color(red: 0.8, green: 0.88, blue: 1.0)
        public static let blue50 = Color(red: 0.95, green: 0.98, blue: 1.0)
    }

    // MARK: - Secondary Colors
    public enum Secondary {
        public static let purple500 = Color(red: 0.35, green: 0.18, blue: 0.98) // #5856D6
        public static let purple400 = Color(red: 0.45, green: 0.38, blue: 0.98)
        public static let purple300 = Color(red: 0.55, green: 0.48, blue: 0.98)
        public static let purple200 = Color(red: 0.75, green: 0.68, blue: 0.98)
        public static let purple100 = Color(red: 0.85, green: 0.78, blue: 0.98)
        public static let purple50 = Color(red: 0.95, green: 0.93, blue: 0.99)
    }

    // MARK: - Accent Colors
    public enum Accent {
        public static let green500 = Color(red: 0.2, green: 0.78, blue: 0.35) // #34C759
        public static let orange500 = Color(red: 1.0, green: 0.58, blue: 0.0) // #FF9500
        public static let red500 = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
        public static let yellow500 = Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00
    }

    // MARK: - Semantic Colors
    public enum Semantic {
        public static let success = Accent.green500
        public static let warning = Accent.orange500
        public static let error = Accent.red500
        public static let info = Primary.blue500
    }

    // MARK: - Neutral Colors
    public enum Neutral {
        public static let black = Color(red: 0.0, green: 0.0, blue: 0.0) // #000000
        public static let gray900 = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
        public static let gray800 = Color(red: 0.17, green: 0.17, blue: 0.18) // #2C2C2E
        public static let gray700 = Color(red: 0.24, green: 0.24, blue: 0.26) // #3A3A3C
        public static let gray600 = Color(red: 0.35, green: 0.35, blue: 0.38) // #58585A
        public static let gray500 = Color(red: 0.46, green: 0.46, blue: 0.50) // #767680
        public static let gray400 = Color(red: 0.68, green: 0.68, blue: 0.70) // #AEAEB2
        public static let gray300 = Color(red: 0.78, green: 0.78, blue: 0.80) // #C7C7CC
        public static let gray200 = Color(red: 0.90, green: 0.90, blue: 0.92) // #E5E5EA
        public static let gray100 = Color(red: 0.95, green: 0.95, blue: 0.97) // #F2F2F7
        public static let white = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF
    }

    // MARK: - Background Colors
    public enum Background {
        public static let primary = Neutral.white
        public static let secondary = Neutral.gray100
        public static let tertiary = Neutral.gray200
        public static let inverse = Neutral.gray900
    }

    // MARK: - Text Colors
    public enum Text {
        public static let primary = Neutral.black
        public static let secondary = Neutral.gray600
        public static let tertiary = Neutral.gray500
        public static let inverse = Neutral.white
        public static let disabled = Neutral.gray400
    }

    // MARK: - Gamification Colors
    public enum Gamification {
        public static let gold = Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD700
        public static let silver = Color(red: 0.75, green: 0.75, blue: 0.75) // #C0C0C0
        public static let bronze = Color(red: 0.8, green: 0.5, blue: 0.2) // #CD7F32
        public static let points = Primary.blue500
        public static let achievement = Accent.green500
        public static let streak = Accent.orange500
    }
}