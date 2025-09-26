import SwiftUI

// MARK: - Card Style Modifier
public struct DSCardModifier: ViewModifier {
    private let style: DSCardStyle
    private let padding: EdgeInsets

    public init(
        style: DSCardStyle = .default,
        padding: EdgeInsets = EdgeInsets(
            top: SpacingTokens.Component.cardPadding,
            leading: SpacingTokens.Component.cardPadding,
            bottom: SpacingTokens.Component.cardPadding,
            trailing: SpacingTokens.Component.cardPadding
        )
    ) {
        self.style = style
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(SpacingTokens.Radius.lg)
            .shadow(
                color: SpacingTokens.Shadow.elevation2.color,
                radius: SpacingTokens.Shadow.elevation2.radius,
                x: SpacingTokens.Shadow.elevation2.x,
                y: SpacingTokens.Shadow.elevation2.y
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpacingTokens.Radius.lg)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

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
}

// MARK: - Button Style Modifier
public struct DSButtonStyleModifier: ViewModifier {
    private let style: DSButton.ButtonStyle
    private let size: DSButton.ButtonSize
    private let isEnabled: Bool

    public init(
        style: DSButton.ButtonStyle = .primary,
        size: DSButton.ButtonSize = .medium,
        isEnabled: Bool = true
    ) {
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
    }

    public func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundColor)
            .cornerRadius(SpacingTokens.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SpacingTokens.Radius.md)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(isEnabled ? 1.0 : 0.95)
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.easeInOut(duration: SpacingTokens.Animation.buttonPress), value: isEnabled)
    }

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
}

// MARK: - Screen Container Modifier
public struct DSScreenContainerModifier: ViewModifier {
    private let backgroundColor: Color
    private let includesSafeArea: Bool

    public init(
        backgroundColor: Color = ColorTokens.Background.primary,
        includesSafeArea: Bool = false
    ) {
        self.backgroundColor = backgroundColor
        self.includesSafeArea = includesSafeArea
    }

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, SpacingTokens.Layout.screenMargin)
            .background(
                backgroundColor
                    .ignoresSafeArea(.all, edges: includesSafeArea ? .all : [])
            )
    }
}

// MARK: - Loading Modifier
public struct DSLoadingModifier: ViewModifier {
    private let isLoading: Bool
    private let style: LoadingStyle

    public init(isLoading: Bool, style: LoadingStyle = .overlay) {
        self.isLoading = isLoading
        self.style = style
    }

    public func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading && style == .overlay ? 2 : 0)

            if isLoading {
                switch style {
                case .overlay:
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: ColorTokens.Primary.blue500))

                case .inline:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ColorTokens.Primary.blue500))

                case .minimal:
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: ColorTokens.Primary.blue500))
                }
            }
        }
        .animation(.easeInOut(duration: SpacingTokens.Animation.normal), value: isLoading)
    }

    public enum LoadingStyle {
        case overlay
        case inline
        case minimal
    }
}

// MARK: - Empty State Modifier
public struct DSEmptyStateModifier: ViewModifier {
    private let isEmpty: Bool
    private let title: String
    private let message: String?
    private let icon: String?
    private let action: (() -> Void)?
    private let actionTitle: String?

    public init(
        isEmpty: Bool,
        title: String,
        message: String? = nil,
        icon: String? = nil,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.isEmpty = isEmpty
        self.title = title
        self.message = message
        self.icon = icon
        self.action = action
        self.actionTitle = actionTitle
    }

    public func body(content: Content) -> some View {
        if isEmpty {
            VStack(spacing: SpacingTokens.lg) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: SpacingTokens.Icon.extraLarge, weight: .light))
                        .foregroundColor(ColorTokens.Text.tertiary)
                }

                VStack(spacing: SpacingTokens.sm) {
                    Text(title)
                        .font(TypographyTokens.Heading.h4)
                        .foregroundColor(ColorTokens.Text.primary)
                        .multilineTextAlignment(.center)

                    if let message = message {
                        Text(message)
                            .font(TypographyTokens.Body.medium)
                            .foregroundColor(ColorTokens.Text.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                if let action = action, let actionTitle = actionTitle {
                    DSButton.primary(actionTitle, action: action)
                }
            }
            .padding(.horizontal, SpacingTokens.xl)
        } else {
            content
        }
    }
}

// MARK: - View Extensions
extension View {
    public func dsCard(
        style: DSCardStyle = .default,
        padding: EdgeInsets = EdgeInsets(
            top: SpacingTokens.Component.cardPadding,
            leading: SpacingTokens.Component.cardPadding,
            bottom: SpacingTokens.Component.cardPadding,
            trailing: SpacingTokens.Component.cardPadding
        )
    ) -> some View {
        modifier(DSCardModifier(style: style, padding: padding))
    }

    public func dsButtonStyle(
        _ style: DSButton.ButtonStyle = .primary,
        size: DSButton.ButtonSize = .medium,
        isEnabled: Bool = true
    ) -> some View {
        modifier(DSButtonStyleModifier(style: style, size: size, isEnabled: isEnabled))
    }

    public func dsScreenContainer(
        backgroundColor: Color = ColorTokens.Background.primary,
        includesSafeArea: Bool = false
    ) -> some View {
        modifier(DSScreenContainerModifier(backgroundColor: backgroundColor, includesSafeArea: includesSafeArea))
    }

    public func dsLoading(
        _ isLoading: Bool,
        style: DSLoadingModifier.LoadingStyle = .overlay
    ) -> some View {
        modifier(DSLoadingModifier(isLoading: isLoading, style: style))
    }

    public func dsEmptyState(
        isEmpty: Bool,
        title: String,
        message: String? = nil,
        icon: String? = nil,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) -> some View {
        modifier(DSEmptyStateModifier(
            isEmpty: isEmpty,
            title: title,
            message: message,
            icon: icon,
            action: action,
            actionTitle: actionTitle
        ))
    }
}

// MARK: - Previews
struct ViewModifiers_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Card Modifier")
                    .dsCard(style: .highlighted)

                Text("Button Style")
                    .dsButtonStyle(.primary)

                VStack {
                    Text("Screen Container Content")
                }
                .frame(height: 100)
                .dsScreenContainer()

                Text("Empty State Example")
                    .dsEmptyState(
                        isEmpty: true,
                        title: "No Items",
                        message: "You haven't added any items yet.",
                        icon: "tray",
                        action: {},
                        actionTitle: "Add Item"
                    )
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}