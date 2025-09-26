import SwiftUI

// MARK: - Card Style Enum
public enum DSCardStyle {
    case `default`
    case secondary
    case highlighted
    case warning
    case error
    case success
}

public struct DSCard<Content: View>: View {
    private let content: Content
    private let style: DSCardStyle
    private let padding: EdgeInsets

    public init(
        style: DSCardStyle = .default,
        padding: EdgeInsets = EdgeInsets(
            top: SpacingTokens.Component.cardPadding,
            leading: SpacingTokens.Component.cardPadding,
            bottom: SpacingTokens.Component.cardPadding,
            trailing: SpacingTokens.Component.cardPadding
        ),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.padding = padding
    }

    public var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(SpacingTokens.Radius.lg)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpacingTokens.Radius.lg)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    // MARK: - Style Calculations
    private var backgroundColor: Color {
        switch style {
        case .default:
            return ColorTokens.Background.primary
        case .secondary:
            return ColorTokens.Background.secondary
        case .highlighted:
            return ColorTokens.Primary.blue50
        case .warning:
            return ColorTokens.Accent.orange500.opacity(0.1)
        case .error:
            return ColorTokens.Semantic.error.opacity(0.1)
        case .success:
            return ColorTokens.Semantic.success.opacity(0.1)
        }
    }

    private var borderColor: Color {
        switch style {
        case .default, .secondary:
            return ColorTokens.Neutral.gray200
        case .highlighted:
            return ColorTokens.Primary.blue200
        case .warning:
            return ColorTokens.Accent.orange500.opacity(0.3)
        case .error:
            return ColorTokens.Semantic.error.opacity(0.3)
        case .success:
            return ColorTokens.Semantic.success.opacity(0.3)
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .default, .secondary:
            return 0
        case .highlighted, .warning, .error, .success:
            return 1
        }
    }

    private var shadowColor: Color {
        SpacingTokens.Shadow.elevation2.color
    }

    private var shadowRadius: CGFloat {
        SpacingTokens.Shadow.elevation2.radius
    }

    private var shadowX: CGFloat {
        SpacingTokens.Shadow.elevation2.x
    }

    private var shadowY: CGFloat {
        SpacingTokens.Shadow.elevation2.y
    }
}

// MARK: - Convenience Initializers
extension DSCard {
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.init(style: .default, content: content)
    }
}

// MARK: - Specialized Card Components
public struct DSInfoCard: View {
    private let title: String
    private let description: String?
    private let icon: String?
    private let style: DSCardStyle
    private let action: (() -> Void)?

    public init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        style: DSCardStyle = .default,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.style = style
        self.action = action
    }

    public var body: some View {
        DSCard(style: style) {
            HStack(spacing: SpacingTokens.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: SpacingTokens.Icon.large, weight: .medium))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    Text(title)
                        .font(TypographyTokens.Heading.h5)
                        .foregroundColor(ColorTokens.Text.primary)

                    if let description = description {
                        Text(description)
                            .font(TypographyTokens.Body.small)
                            .foregroundColor(ColorTokens.Text.secondary)
                    }
                }

                Spacer()

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ColorTokens.Text.tertiary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }

    private var iconColor: Color {
        switch style {
        case .default, .secondary, .highlighted:
            return ColorTokens.Primary.blue500
        case .warning:
            return ColorTokens.Accent.orange500
        case .error:
            return ColorTokens.Semantic.error
        case .success:
            return ColorTokens.Semantic.success
        }
    }
}

// MARK: - Previews
struct DSCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                DSCard {
                    Text("Default Card")
                        .font(TypographyTokens.Body.medium)
                }

                DSCard(style: .highlighted) {
                    Text("Highlighted Card")
                        .font(TypographyTokens.Body.medium)
                }

                DSInfoCard(
                    title: "Points Earned",
                    description: "You've earned 150 points today",
                    icon: "star.fill"
                )

                DSInfoCard(
                    title: "Achievement Unlocked",
                    description: "Reading Master badge earned!",
                    icon: "trophy.fill",
                    style: .success
                )

                DSInfoCard(
                    title: "Time Limit Warning",
                    description: "Only 30 minutes left",
                    icon: "clock.fill",
                    style: .warning
                )
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}