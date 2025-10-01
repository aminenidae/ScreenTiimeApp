import SwiftUI
import DesignSystem
import SharedModels

struct PurchaseErrorView: View {
    let error: AppError
    let onRetry: () -> Void
    let onCancel: () -> Void
    let onContactSupport: () -> Void
    @State private var showingDetails = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            errorIconSection

            errorMessageSection

            if shouldShowRetryOption {
                retrySection
            }

            supportSection

            if showingDetails {
                errorDetailsSection
            }

            actionButtonsSection
        }
        .padding(Spacing.lg)
        .background(DesignSystemColor.backgroundPrimary.color)
    }

    private var errorIconSection: some View {
        ZStack {
            Circle()
                .fill(DesignSystemColor.error.color.opacity(0.2))
                .frame(width: 80, height: 80)

            Image(systemName: errorIcon)
                .font(.system(size: 32))
                .foregroundColor(DesignSystemColor.error.color)
        }
    }

    private var errorMessageSection: some View {
        VStack(spacing: Spacing.sm) {
            Text(errorTitle)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                     green: DesignSystemColor.textPrimary.green,
                                     blue: DesignSystemColor.textPrimary.blue))

            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                     green: DesignSystemColor.textSecondary.green,
                                     blue: DesignSystemColor.textSecondary.blue))

            if let suggestion = errorSuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                         green: DesignSystemColor.textSecondary.green,
                                         blue: DesignSystemColor.textSecondary.blue))
                    .padding(.top, Spacing.xs)
            }
        }
    }

    private var retrySection: some View {
        VStack(spacing: Spacing.sm) {
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(red: DesignSystemColor.primaryBrand.red,
                                     green: DesignSystemColor.primaryBrand.green,
                                     blue: DesignSystemColor.primaryBrand.blue))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: DesignSystemColor.primaryBrand.red,
                                    green: DesignSystemColor.primaryBrand.green,
                                    blue: DesignSystemColor.primaryBrand.blue), lineWidth: 1)
                )
                .cornerRadius(8)
            }
        }
    }

    private var supportSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("Need Help?")
                .font(.headline)
                .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                     green: DesignSystemColor.textPrimary.green,
                                     blue: DesignSystemColor.textPrimary.blue))

            VStack(spacing: Spacing.xs) {
                Button("Contact Support") {
                    onContactSupport()
                }
                .font(.subheadline)
                .foregroundColor(Color(red: DesignSystemColor.primaryBrand.red,
                                     green: DesignSystemColor.primaryBrand.green,
                                     blue: DesignSystemColor.primaryBrand.blue))

                Button("View Technical Details") {
                    showingDetails.toggle()
                }
                .font(.caption)
                .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                     green: DesignSystemColor.textSecondary.green,
                                     blue: DesignSystemColor.textSecondary.blue))
            }
        }
        .padding(Spacing.md)
        .background(Color(red: DesignSystemColor.backgroundSecondary.red,
                        green: DesignSystemColor.backgroundSecondary.green,
                        blue: DesignSystemColor.backgroundSecondary.blue))
        .cornerRadius(12)
    }

    private var errorDetailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Technical Details:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: DesignSystemColor.textPrimary.red,
                                     green: DesignSystemColor.textPrimary.green,
                                     blue: DesignSystemColor.textPrimary.blue))

            Text("Error Code: \(errorCode)")
                .font(.caption)
                .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                     green: DesignSystemColor.textSecondary.green,
                                     blue: DesignSystemColor.textSecondary.blue))

            Text("Description: \(error.localizedDescription)")
                .font(.caption)
                .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                                     green: DesignSystemColor.textSecondary.green,
                                     blue: DesignSystemColor.textSecondary.blue))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.sm)
        .background(Color(red: DesignSystemColor.backgroundSecondary.red,
                        green: DesignSystemColor.backgroundSecondary.green,
                        blue: DesignSystemColor.backgroundSecondary.blue))
        .cornerRadius(8)
    }

    private var actionButtonsSection: some View {
        Button("Close") {
            onCancel()
        }
        .font(.subheadline)
        .foregroundColor(Color(red: DesignSystemColor.textSecondary.red,
                             green: DesignSystemColor.textSecondary.green,
                             blue: DesignSystemColor.textSecondary.blue))
    }

    // MARK: - Computed Properties

    private var errorIcon: String {
        switch error {
        case .networkError:
            return "wifi.slash"
        case .unauthorized:
            return "person.fill.xmark"
        case .operationNotAllowed:
            return "hand.raised.fill"
        case .storeKitNotAvailable:
            return "app.badge.checkmark"
        case .purchaseFailed:
            return "creditcard.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }

    private var errorTitle: String {
        switch error {
        case .networkError:
            return "Connection Issue"
        case .unauthorized:
            return "Authentication Required"
        case .operationNotAllowed:
            return "Purchase Not Allowed"
        case .storeKitNotAvailable:
            return "App Store Unavailable"
        case .purchaseFailed:
            return "Purchase Failed"
        case .productNotFound:
            return "Product Not Available"
        case .invalidOperation:
            return "Invalid Request"
        case .systemError:
            return "System Error"
        default:
            return "Something Went Wrong"
        }
    }

    private var errorMessage: String {
        switch error {
        case .networkError:
            return "Please check your internet connection and try again."
        case .unauthorized:
            return "Please sign in to your Apple ID to make purchases."
        case .operationNotAllowed:
            return "Purchases are currently disabled on this device. Check your Screen Time restrictions."
        case .storeKitNotAvailable:
            return "The App Store is currently unavailable. Please try again later."
        case .purchaseFailed:
            return "Your purchase could not be completed at this time."
        case .productNotFound:
            return "The requested subscription plan is not available."
        case .invalidOperation:
            return "There was an issue processing your request."
        case .systemError:
            return "A system error occurred while processing your request."
        default:
            return "An unexpected error occurred. Please try again."
        }
    }

    private var errorSuggestion: String? {
        switch error {
        case .networkError:
            return "Make sure you're connected to Wi-Fi or cellular data."
        case .unauthorized:
            return "Go to Settings > App Store to sign in or update your Apple ID."
        case .operationNotAllowed:
            return "Check Settings > Screen Time > Content & Privacy Restrictions."
        case .storeKitNotAvailable:
            return "The issue should resolve automatically once App Store services are restored."
        default:
            return nil
        }
    }

    private var shouldShowRetryOption: Bool {
        switch error {
        case .networkError, .storeKitNotAvailable, .systemError:
            return true
        default:
            return false
        }
    }

    private var errorCode: String {
        switch error {
        case .networkError:
            return "NET_001"
        case .unauthorized:
            return "AUTH_001"
        case .operationNotAllowed:
            return "OP_001"
        case .storeKitNotAvailable:
            return "SK_001"
        case .purchaseFailed:
            return "PUR_001"
        case .productNotFound:
            return "PRD_001"
        case .invalidOperation:
            return "INV_001"
        case .systemError:
            return "SYS_001"
        default:
            return "UNK_001"
        }
    }
}

struct PurchaseErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PurchaseErrorView(
                error: .networkError("Connection failed"),
                onRetry: {},
                onCancel: {},
                onContactSupport: {}
            )
            .previewDisplayName("Network Error")

            PurchaseErrorView(
                error: .operationNotAllowed("Purchase restricted"),
                onRetry: {},
                onCancel: {},
                onContactSupport: {}
            )
            .previewDisplayName("Operation Not Allowed")
        }
    }
}