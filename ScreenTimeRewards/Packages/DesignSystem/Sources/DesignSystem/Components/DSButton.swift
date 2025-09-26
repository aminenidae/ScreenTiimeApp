import SwiftUI

public struct DSButton: View {
    private let title: String
    private let style: ButtonStyle
    private let size: ButtonSize
    private let isEnabled: Bool
    private let isLoading: Bool
    private let icon: String?
    private let action: () -> Void

    public init(
        _ title: String,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: SpacingTokens.Icon.buttonIconSpacing) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(textColor)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .medium))
                }

                if !title.isEmpty {
                    Text(title)
                        .font(textFont)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundColor)
            .cornerRadius(SpacingTokens.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SpacingTokens.Radius.md)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .disabled(!isEnabled || isLoading)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .opacity(isEnabled ? 1.0 : 0.6)
        .animation(.easeInOut(duration: SpacingTokens.Animation.buttonPress), value: isEnabled)
    }

    // MARK: - Style Calculations
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ColorTokens.Primary.blue500
        case .secondary:
            return ColorTokens.Background.secondary
        case .tertiary:
            return Color.clear
        case .destructive:
            return ColorTokens.Semantic.error
        case .success:
            return ColorTokens.Semantic.success
        }
    }

    private var textColor: Color {
        switch style {
        case .primary, .destructive, .success:
            return ColorTokens.Text.inverse
        case .secondary, .tertiary:
            return ColorTokens.Text.primary
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .destructive, .success:
            return Color.clear
        case .secondary:
            return ColorTokens.Neutral.gray300
        case .tertiary:
            return ColorTokens.Primary.blue500
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive, .success, .secondary:
            return 0
        case .tertiary:
            return 1
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return 16
        case .medium: return SpacingTokens.Component.buttonPaddingHorizontal
        case .large: return 32
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 8
        case .medium: return SpacingTokens.Component.buttonPaddingVertical
        case .large: return 16
        }
    }

    private var textFont: Font {
        switch size {
        case .small: return TypographyTokens.Label.small
        case .medium: return TypographyTokens.Specialized.buttonLabel
        case .large: return TypographyTokens.Label.large
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }

    // MARK: - Enums
    public enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case destructive
        case success
    }

    public enum ButtonSize {
        case small
        case medium
        case large
    }
}

// MARK: - Convenience Initializers
extension DSButton {
    public static func primary(
        _ title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        icon: String? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(title, style: .primary, isEnabled: isEnabled, isLoading: isLoading, icon: icon, action: action)
    }

    public static func secondary(
        _ title: String,
        isEnabled: Bool = true,
        icon: String? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(title, style: .secondary, isEnabled: isEnabled, icon: icon, action: action)
    }

    public static func destructive(
        _ title: String,
        isEnabled: Bool = true,
        icon: String? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(title, style: .destructive, isEnabled: isEnabled, icon: icon, action: action)
    }
}

// MARK: - Previews
struct DSButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DSButton.primary("Primary Button", icon: "star.fill") { }
            DSButton.secondary("Secondary Button") { }
            DSButton("Tertiary Button", style: .tertiary) { }
            DSButton.destructive("Delete", icon: "trash") { }
            DSButton.primary("Loading", isLoading: true) { }
            DSButton.primary("Disabled", isEnabled: false) { }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}