import SwiftUI
import SharedModels

struct UnauthorizedActionAlert: ViewModifier {
    @Binding var isPresented: Bool
    let action: PermissionAction
    let message: String?

    func body(content: Content) -> some View {
        content
            .alert("Permission Denied", isPresented: $isPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(message ?? PermissionError.unauthorized(action: action).localizedDescription)
            }
    }
}

extension View {
    func unauthorizedActionAlert(
        isPresented: Binding<Bool>,
        action: PermissionAction,
        message: String? = nil
    ) -> some View {
        modifier(UnauthorizedActionAlert(
            isPresented: isPresented,
            action: action,
            message: message
        ))
    }
}

// MARK: - Permission-aware UI Components

struct PermissionAwareButton: View {
    let title: String
    let action: () -> Void
    let hasPermission: Bool
    let permissionAction: PermissionAction
    let isDisabled: Bool

    @State private var showUnauthorizedAlert = false

    init(
        title: String,
        hasPermission: Bool,
        permissionAction: PermissionAction,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.hasPermission = hasPermission
        self.permissionAction = permissionAction
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(title) {
            if hasPermission && !isDisabled {
                action()
            } else if !hasPermission {
                showUnauthorizedAlert = true
            }
        }
        .disabled(isDisabled)
        .opacity(hasPermission && !isDisabled ? 1.0 : 0.6)
        .unauthorizedActionAlert(
            isPresented: $showUnauthorizedAlert,
            action: permissionAction
        )
    }
}

// MARK: - Owner-only control wrapper

struct OwnerOnlyControl<Content: View>: View {
    let isOwner: Bool
    let content: Content

    init(isOwner: Bool, @ViewBuilder content: () -> Content) {
        self.isOwner = isOwner
        self.content = content()
    }

    var body: some View {
        if isOwner {
            content
        }
    }
}

// MARK: - Role-based visibility modifier

struct RoleBasedVisibility: ViewModifier {
    let userRole: PermissionRole?
    let requiredRole: PermissionRole

    func body(content: Content) -> some View {
        Group {
            if let role = userRole, role == requiredRole || role == .owner {
                content
            }
        }
    }
}

extension View {
    func visibleFor(role: PermissionRole, userRole: PermissionRole?) -> some View {
        modifier(RoleBasedVisibility(userRole: userRole, requiredRole: role))
    }

    func ownerOnly(isOwner: Bool) -> some View {
        Group {
            if isOwner {
                self
            }
        }
    }
}