import SwiftUI

public struct DSProgressRing: View {
    private let progress: Double
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let primaryColor: Color
    private let backgroundColor: Color
    private let showPercentage: Bool
    private let animated: Bool

    @State private var animatedProgress: Double = 0

    public init(
        progress: Double,
        size: CGFloat = 120,
        lineWidth: CGFloat = 12,
        primaryColor: Color = ColorTokens.Primary.blue500,
        backgroundColor: Color = ColorTokens.Neutral.gray200,
        showPercentage: Bool = true,
        animated: Bool = true
    ) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.showPercentage = showPercentage
        self.animated = animated
    }

    public var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    primaryColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            // Percentage text
            if showPercentage {
                VStack(spacing: 2) {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(TypographyTokens.Specialized.pointsDisplay)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTokens.Text.primary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            if animated {
                withAnimation(.easeInOut(duration: SpacingTokens.Animation.progressAnimation)) {
                    animatedProgress = progress
                }
            } else {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newProgress in
            if animated {
                withAnimation(.easeInOut(duration: SpacingTokens.Animation.normal)) {
                    animatedProgress = newProgress
                }
            } else {
                animatedProgress = newProgress
            }
        }
    }
}

public struct DSGoalProgressRing: View {
    private let currentValue: Int
    private let goalValue: Int
    private let title: String
    private let subtitle: String?
    private let size: CGFloat
    private let color: Color

    public init(
        currentValue: Int,
        goalValue: Int,
        title: String,
        subtitle: String? = nil,
        size: CGFloat = 120,
        color: Color = ColorTokens.Primary.blue500
    ) {
        self.currentValue = max(0, currentValue)
        self.goalValue = max(1, goalValue)
        self.title = title
        self.subtitle = subtitle
        self.size = size
        self.color = color
    }

    private var progress: Double {
        Double(currentValue) / Double(goalValue)
    }

    public var body: some View {
        VStack(spacing: SpacingTokens.sm) {
            DSProgressRing(
                progress: progress,
                size: size,
                primaryColor: color,
                showPercentage: false
            )
            .overlay(
                VStack(spacing: 2) {
                    Text("\(currentValue)")
                        .font(TypographyTokens.Specialized.pointsDisplay)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTokens.Text.primary)

                    Text("/ \(goalValue)")
                        .font(TypographyTokens.Caption.medium)
                        .foregroundColor(ColorTokens.Text.secondary)
                }
            )

            VStack(spacing: 2) {
                Text(title)
                    .font(TypographyTokens.Label.medium)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTokens.Text.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(TypographyTokens.Caption.small)
                        .foregroundColor(ColorTokens.Text.secondary)
                }
            }
            .multilineTextAlignment(.center)
        }
    }
}

public struct DSMultiProgressRing: View {
    private let rings: [RingData]
    private let size: CGFloat
    private let spacing: CGFloat

    public init(rings: [RingData], size: CGFloat = 120, spacing: CGFloat = 8) {
        self.rings = rings
        self.size = size
        self.spacing = spacing
    }

    public var body: some View {
        ZStack {
            ForEach(Array(rings.enumerated()), id: \.offset) { index, ring in
                let ringSize = size - CGFloat(index) * spacing * 2
                let lineWidth = max(4, ringSize / 15)

                DSProgressRing(
                    progress: ring.progress,
                    size: ringSize,
                    lineWidth: lineWidth,
                    primaryColor: ring.color,
                    showPercentage: false,
                    animated: ring.animated
                )
            }

            // Center content
            if let centerContent = rings.first(where: { $0.showInCenter }) {
                VStack(spacing: 2) {
                    Text(centerContent.centerTitle ?? "")
                        .font(TypographyTokens.Heading.h4)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTokens.Text.primary)

                    if let centerSubtitle = centerContent.centerSubtitle {
                        Text(centerSubtitle)
                            .font(TypographyTokens.Caption.medium)
                            .foregroundColor(ColorTokens.Text.secondary)
                    }
                }
                .multilineTextAlignment(.center)
            }
        }
    }

    public struct RingData {
        public let progress: Double
        public let color: Color
        public let animated: Bool
        public let showInCenter: Bool
        public let centerTitle: String?
        public let centerSubtitle: String?

        public init(
            progress: Double,
            color: Color,
            animated: Bool = true,
            showInCenter: Bool = false,
            centerTitle: String? = nil,
            centerSubtitle: String? = nil
        ) {
            self.progress = progress
            self.color = color
            self.animated = animated
            self.showInCenter = showInCenter
            self.centerTitle = centerTitle
            self.centerSubtitle = centerSubtitle
        }
    }
}

// MARK: - Previews
struct DSProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            DSProgressRing(progress: 0.75)

            DSGoalProgressRing(
                currentValue: 150,
                goalValue: 200,
                title: "Points Today",
                subtitle: "75% complete"
            )

            DSMultiProgressRing(
                rings: [
                    .init(progress: 0.8, color: ColorTokens.Semantic.success, showInCenter: true, centerTitle: "80%", centerSubtitle: "Complete"),
                    .init(progress: 0.6, color: ColorTokens.Primary.blue500),
                    .init(progress: 0.4, color: ColorTokens.Accent.orange500)
                ]
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}