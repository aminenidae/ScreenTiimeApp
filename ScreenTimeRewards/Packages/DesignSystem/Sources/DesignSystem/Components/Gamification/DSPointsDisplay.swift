import SwiftUI

public struct DSPointsDisplay: View {
    private let points: Int
    private let style: DisplayStyle
    private let animated: Bool
    private let showPlus: Bool

    @State private var animatedPoints: Int = 0
    @State private var scale: CGFloat = 1.0

    public init(
        points: Int,
        style: DisplayStyle = .large,
        animated: Bool = true,
        showPlus: Bool = false
    ) {
        self.points = points
        self.style = style
        self.animated = animated
        self.showPlus = showPlus
    }

    public var body: some View {
        HStack(spacing: SpacingTokens.xs) {
            Image(systemName: IconSystem.Gamification.points)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundColor(ColorTokens.Gamification.points)

            Text("\(showPlus && animatedPoints > 0 ? "+" : "")\(animatedPoints)")
                .font(textFont)
                .fontWeight(.bold)
                .foregroundColor(textColor)
        }
        .scaleEffect(scale)
        .onAppear {
            if animated {
                animatePoints()
            } else {
                animatedPoints = points
            }
        }
        .onChange(of: points) { newPoints in
            if animated {
                animatePoints()
                // Bounce animation for point changes
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            } else {
                animatedPoints = newPoints
            }
        }
    }

    private func animatePoints() {
        let duration = SpacingTokens.Animation.progressAnimation
        let steps = 30
        let stepValue = Double(points - animatedPoints) / Double(steps)
        let stepDuration = duration / Double(steps)

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                animatedPoints = animatedPoints + Int(stepValue)
                if i == steps {
                    animatedPoints = points // Ensure final value is exact
                }
            }
        }
    }

    private var iconSize: CGFloat {
        switch style {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        case .hero: return 32
        }
    }

    private var textFont: Font {
        switch style {
        case .small: return TypographyTokens.Label.medium
        case .medium: return TypographyTokens.Heading.h5
        case .large: return TypographyTokens.Specialized.pointsDisplay
        case .hero: return TypographyTokens.Display.small
        }
    }

    private var textColor: Color {
        switch style {
        case .small, .medium: return ColorTokens.Text.primary
        case .large, .hero: return ColorTokens.Gamification.points
        }
    }

    public enum DisplayStyle {
        case small
        case medium
        case large
        case hero
    }
}

public struct DSPointsCard: View {
    private let currentPoints: Int
    private let title: String
    private let subtitle: String?
    private let trend: Trend?
    private let action: (() -> Void)?

    public init(
        currentPoints: Int,
        title: String,
        subtitle: String? = nil,
        trend: Trend? = nil,
        action: (() -> Void)? = nil
    ) {
        self.currentPoints = currentPoints
        self.title = title
        self.subtitle = subtitle
        self.trend = trend
        self.action = action
    }

    public var body: some View {
        DSCard(style: .highlighted) {
            VStack(alignment: .leading, spacing: SpacingTokens.md) {
                HStack {
                    VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                        Text(title)
                            .font(TypographyTokens.Heading.h5)
                            .foregroundColor(ColorTokens.Text.primary)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(TypographyTokens.Caption.medium)
                                .foregroundColor(ColorTokens.Text.secondary)
                        }
                    }

                    Spacer()

                    if action != nil {
                        Button(action: { action?() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ColorTokens.Text.tertiary)
                        }
                    }
                }

                HStack(alignment: .bottom) {
                    DSPointsDisplay(points: currentPoints, style: .large)

                    Spacer()

                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(trend.color)

                            Text(trend.text)
                                .font(TypographyTokens.Caption.small)
                                .foregroundColor(trend.color)
                        }
                    }
                }
            }
        }
    }

    public struct Trend {
        public let text: String
        public let isPositive: Bool

        public init(text: String, isPositive: Bool) {
            self.text = text
            self.isPositive = isPositive
        }

        var icon: String {
            isPositive ? "arrow.up.right" : "arrow.down.right"
        }

        var color: Color {
            isPositive ? ColorTokens.Semantic.success : ColorTokens.Semantic.error
        }
    }
}

public struct DSAchievementBadge: View {
    private let title: String
    private let icon: String
    private let color: Color
    private let isUnlocked: Bool
    private let size: BadgeSize

    public init(
        title: String,
        icon: String,
        color: Color = ColorTokens.Gamification.achievement,
        isUnlocked: Bool = true,
        size: BadgeSize = .medium
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isUnlocked = isUnlocked
        self.size = size
    }

    public var body: some View {
        VStack(spacing: SpacingTokens.sm) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color : ColorTokens.Neutral.gray300)
                    .frame(width: circleSize, height: circleSize)

                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : ColorTokens.Text.tertiary)
            }

            Text(title)
                .font(textFont)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? ColorTokens.Text.primary : ColorTokens.Text.tertiary)
                .multilineTextAlignment(.center)
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
    }

    private var circleSize: CGFloat {
        switch size {
        case .small: return 40
        case .medium: return 60
        case .large: return 80
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 16
        case .medium: return 24
        case .large: return 32
        }
    }

    private var textFont: Font {
        switch size {
        case .small: return TypographyTokens.Caption.small
        case .medium: return TypographyTokens.Caption.medium
        case .large: return TypographyTokens.Label.medium
        }
    }

    public enum BadgeSize {
        case small
        case medium
        case large
    }
}

// MARK: - Previews
struct DSPointsDisplay_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            DSPointsDisplay(points: 1250, style: .hero)

            DSPointsCard(
                currentPoints: 850,
                title: "Total Points",
                subtitle: "This week",
                trend: .init(text: "+12%", isPositive: true)
            )

            HStack(spacing: 16) {
                DSAchievementBadge(
                    title: "Reading\nMaster",
                    icon: "book.fill",
                    color: ColorTokens.Gamification.gold
                )

                DSAchievementBadge(
                    title: "Math\nWhiz",
                    icon: "x.squareroot",
                    color: ColorTokens.Gamification.silver,
                    isUnlocked: false
                )
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}