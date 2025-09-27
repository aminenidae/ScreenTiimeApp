import Foundation
#if canImport(FamilyControls)
import FamilyControls
#endif
#if canImport(OSLog)
import OSLog
#endif

// MARK: - Authorization Service Protocol

#if canImport(FamilyControls)
/// Protocol for Family Controls authorization operations
@available(iOS 15.0, *)
public protocol FamilyControlsAuthorizationServiceProtocol {
    /// Current authorization status
    @available(iOS 15.0, *)
    var authorizationStatus: AuthorizationStatus { get }

    /// Requests authorization for Family Controls
    /// - Returns: Authorization status after request
    @available(iOS 15.0, *)
    func requestAuthorization() async throws -> AuthorizationStatus

    /// Checks if the current user is a parent
    /// - Returns: True if user has parent privileges
    @available(iOS 15.0, *)
    func isParent() -> Bool

    /// Checks if the current user is a child
    /// - Returns: True if user is in child role
    @available(iOS 15.0, *)
    func isChild() -> Bool
}
#else
/// Protocol for Family Controls authorization operations
public protocol FamilyControlsAuthorizationServiceProtocol {
    /// Current authorization status
    var authorizationStatus: Any { get }

    /// Requests authorization for Family Controls
    /// - Returns: Authorization status after request
    func requestAuthorization() async throws -> Any

    /// Checks if the current user is a parent
    /// - Returns: True if user has parent privileges
    func isParent() -> Bool

    /// Checks if the current user is a child
    /// - Returns: True if user is in child role
    func isChild() -> Bool
}
#endif

// MARK: - Authorization Service Implementation

#if canImport(FamilyControls)
/// Service for managing Family Controls authorization
@available(iOS 15.0, *)
public class FamilyControlsAuthorizationService: FamilyControlsAuthorizationServiceProtocol {
    // MARK: - Properties

    private let authorizationCenter: AuthorizationCenter
    #if canImport(OSLog)
    private let logger = Logger(subsystem: "com.screentimerewards.familycontrolskit", category: "authorization")
    #else
    private let logger: Any = "Logger not available"
    #endif

    // Authorization status caching
    private var cachedAuthorizationStatus: AuthorizationStatus?
    private var lastStatusCheck: Date?
    private let statusCacheInterval: TimeInterval

    // MARK: - Initialization

    public init(authorizationCenter: AuthorizationCenter = .shared, cacheInterval: TimeInterval = 300) { // Default 5 minutes
        self.authorizationCenter = authorizationCenter
        self.statusCacheInterval = cacheInterval
    }

    // MARK: - Protocol Implementation

    public var authorizationStatus: AuthorizationStatus {
        // Use cached status if available and recent
        if let cached = cachedAuthorizationStatus,
           let lastCheck = lastStatusCheck,
           Date().timeIntervalSince(lastCheck) < statusCacheInterval {
            return cached
        }

        // Fetch fresh status and cache it
        let status = authorizationCenter.authorizationStatus
        cachedAuthorizationStatus = status
        lastStatusCheck = Date()

        return status
    }

    public func requestAuthorization() async throws -> AuthorizationStatus {
        #if canImport(OSLog)
        logger.info("Requesting Family Controls authorization")
        #endif

        do {
            if #available(iOS 16.0, *) {
                try await authorizationCenter.requestAuthorization(for: .individual)
            } else {
                // Fallback for iOS 15.0
                throw FamilyControlsAuthorizationError.unavailableOnVersion
            }
            let status = authorizationCenter.authorizationStatus

            #if canImport(OSLog)
            logger.info("Authorization request completed with status: \(String(describing: status))")
            #endif

            switch status {
            case .notDetermined:
                #if canImport(OSLog)
                logger.warning("Authorization status is still not determined after request")
                #endif
                throw FamilyControlsAuthorizationError.requestFailed
            case .denied:
                #if canImport(OSLog)
                logger.error("Family Controls authorization was denied")
                #endif
                throw FamilyControlsAuthorizationError.authorizationDenied
            case .approved:
                #if canImport(OSLog)
                logger.info("Family Controls authorization approved")
                #endif
                return status
            @unknown default:
                #if canImport(OSLog)
                logger.error("Unknown authorization status: \(String(describing: status))")
                #endif
                throw FamilyControlsAuthorizationError.unknown
            }
        } catch {
            #if canImport(OSLog)
            logger.error("Authorization request failed: \(error.localizedDescription)")
            #endif

            if let fcError = error as? FamilyControlsAuthorizationError {
                throw fcError
            } else {
                throw FamilyControlsAuthorizationError.requestFailed
            }
        }
    }

    public func isParent() -> Bool {
        // Check if we have authorization - parents typically have authorization
        let hasAuthorization = authorizationStatus == .approved

        #if canImport(OSLog)
        logger.debug("Parent role check - authorization status: \(String(describing: self.authorizationStatus)), isParent: \(hasAuthorization)")
        #endif

        return hasAuthorization
    }

    public func isChild() -> Bool {
        // Children typically don't have Family Controls authorization
        let isChildRole = authorizationStatus == .denied || authorizationStatus == .notDetermined

        #if canImport(OSLog)
        logger.debug("Child role check - authorization status: \(String(describing: self.authorizationStatus)), isChild: \(isChildRole)")
        #endif

        return isChildRole
    }

    // MARK: - Additional Authorization Methods

    /// Clears cached authorization status to force fresh check
    public func clearAuthorizationCache() {
        cachedAuthorizationStatus = nil
        lastStatusCheck = nil
        #if canImport(OSLog)
        logger.debug("Authorization status cache cleared")
        #endif
    }

    /// Checks if authorization is required
    public func isAuthorizationRequired() -> Bool {
        return authorizationStatus == .notDetermined
    }

    /// Checks if authorization was explicitly denied by user
    public func wasAuthorizationDenied() -> Bool {
        return authorizationStatus == .denied
    }

    /// Checks if app is currently authorized to use Family Controls
    public func isAuthorized() -> Bool {
        return authorizationStatus == .approved
    }

    /// Provides user-friendly status description
    public func getAuthorizationStatusDescription() -> String {
        switch authorizationStatus {
        case .notDetermined:
            return "Family Controls authorization not yet requested"
        case .denied:
            return "Family Controls authorization denied by user"
        case .approved:
            return "Family Controls authorization granted"
        @unknown default:
            return "Unknown authorization status"
        }
    }

    /// Provides guidance for user on how to resolve authorization issues
    public func getAuthorizationGuidance() -> String {
        switch authorizationStatus {
        case .notDetermined:
            return "Please grant Family Controls permission when prompted to enable screen time monitoring features."
        case .denied:
            return "To enable family controls features, please go to Settings > Screen Time and allow this app to manage screen time."
        case .approved:
            return "Family Controls is properly configured and ready to use."
        @unknown default:
            return "Please check your Family Controls settings in the Settings app."
        }
    }
}
#else
/// Service for managing Family Controls authorization
public class FamilyControlsAuthorizationService: FamilyControlsAuthorizationServiceProtocol {
    // MARK: - Properties
    #if canImport(OSLog)
    private let logger = Logger(subsystem: "com.screentimerewards.familycontrolskit", category: "authorization")
    #else
    private let logger: Any = "Logger not available"
    #endif

    // Authorization status caching
    private var lastStatusCheck: Date?
    private let statusCacheInterval: TimeInterval

    // MARK: - Initialization

    public init(authorizationCenter: Any? = nil, cacheInterval: TimeInterval = 300) { // Default 5 minutes
        self.statusCacheInterval = cacheInterval
    }

    // MARK: - Protocol Implementation

    public var authorizationStatus: Any {
        return "unavailable"
    }

    public func requestAuthorization() async throws -> Any {
        throw FamilyControlsAuthorizationError.unavailable
    }

    public func isParent() -> Bool {
        return false
    }

    public func isChild() -> Bool {
        return false
    }

    // MARK: - Additional Authorization Methods

    /// Clears cached authorization status to force fresh check
    public func clearAuthorizationCache() {
        lastStatusCheck = nil
        #if canImport(OSLog)
        logger.debug("Authorization status cache cleared")
        #endif
    }

    /// Checks if authorization is required
    public func isAuthorizationRequired() -> Bool {
        return false
    }

    /// Checks if authorization was explicitly denied by user
    public func wasAuthorizationDenied() -> Bool {
        return false
    }

    /// Checks if app is currently authorized to use Family Controls
    public func isAuthorized() -> Bool {
        return false
    }

    /// Provides user-friendly status description
    public func getAuthorizationStatusDescription() -> String {
        return "Family Controls not available on this platform"
    }

    /// Provides guidance for user on how to resolve authorization issues
    public func getAuthorizationGuidance() -> String {
        return "Family Controls is only available on iOS devices"
    }
}
#endif

// MARK: - Error Types

#if canImport(FamilyControls)
@available(iOS 15.0, *)
public enum FamilyControlsAuthorizationError: Error, LocalizedError {
    case authorizationDenied
    case requestFailed
    case unavailable
    case unavailableOnVersion
    case unknown

    public var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Family Controls authorization was denied by the user"
        case .requestFailed:
            return "Failed to request Family Controls authorization"
        case .unavailable:
            return "Family Controls is not available on this device"
        case .unavailableOnVersion:
            return "Family Controls authorization requires iOS 16.0 or newer"
        case .unknown:
            return "An unknown error occurred during authorization"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .authorizationDenied:
            return "Please enable Family Controls in Settings > Screen Time"
        case .requestFailed, .unknown:
            return "Please try again or restart the app"
        case .unavailable:
            return "Family Controls requires iOS 15.0 or later"
        case .unavailableOnVersion:
            return "Please update to iOS 16.0 or later for full Family Controls support"
        }
    }
}
#else
public enum FamilyControlsAuthorizationError: Error, LocalizedError {
    case unavailable
    
    public var errorDescription: String? {
        return "Family Controls is not available on this platform"
    }
    
    public var recoverySuggestion: String? {
        return "Family Controls is only available on iOS devices"
    }
}
#endif

#if canImport(FamilyControls)
// MARK: - Authorization Status Extensions

@available(iOS 15.0, *)
extension AuthorizationStatus {
    /// Human-readable description of the authorization status
    public var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .approved:
            return "Approved"
        @unknown default:
            return "Unknown"
        }
    }

    /// Whether the authorization status allows Family Controls usage
    public var isAuthorized: Bool {
        return self == .approved
    }
}
#endif