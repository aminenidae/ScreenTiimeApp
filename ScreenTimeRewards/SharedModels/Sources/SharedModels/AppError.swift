import Foundation

/// Error types for the ScreenTimeRewards application
public enum AppError: LocalizedError {
    // Network and connectivity errors
    case networkUnavailable
    case networkTimeout
    case networkError(String)
    
    // CloudKit errors
    case cloudKitNotAvailable
    case cloudKitRecordNotFound
    case cloudKitSaveError(String)
    case cloudKitFetchError(String)
    case cloudKitDeleteError(String)
    case cloudKitZoneError(String)
    
    // Data validation errors
    case invalidData(String)
    case missingRequiredField(String)
    case dataValidationError(String)
    
    // Authentication errors
    case unauthorized
    case authenticationFailed
    case familyAccessDenied
    
    // Business logic errors
    case insufficientPoints
    case invalidOperation(String)
    case operationNotAllowed(String)
    
    // System errors
    case systemError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Please check your network settings and try again."
        case .networkTimeout:
            return "The request timed out. Please try again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .cloudKitNotAvailable:
            return "iCloud is not available. Please sign in to iCloud and try again."
        case .cloudKitRecordNotFound:
            return "The requested data was not found."
        case .cloudKitSaveError(let message):
            return "Failed to save data: \(message)"
        case .cloudKitFetchError(let message):
            return "Failed to fetch data: \(message)"
        case .cloudKitDeleteError(let message):
            return "Failed to delete data: \(message)"
        case .cloudKitZoneError(let message):
            return "CloudKit zone error: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .missingRequiredField(let field):
            return "Required field is missing: \(field)"
        case .dataValidationError(let message):
            return "Data validation error: \(message)"
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .authenticationFailed:
            return "Authentication failed. Please try signing in again."
        case .familyAccessDenied:
            return "Access to family data denied."
        case .insufficientPoints:
            return "Not enough points for this reward."
        case .invalidOperation(let message):
            return "Invalid operation: \(message)"
        case .operationNotAllowed(let message):
            return "Operation not allowed: \(message)"
        case .systemError(let message):
            return "System error: \(message)"
        case .unknownError(let message):
            return "An unknown error occurred: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .networkUnavailable:
            return "Network unavailable"
        case .networkTimeout:
            return "Network timeout"
        case .networkError:
            return "Network error"
        case .cloudKitNotAvailable:
            return "CloudKit unavailable"
        case .cloudKitRecordNotFound:
            return "Record not found"
        case .cloudKitSaveError:
            return "Save failed"
        case .cloudKitFetchError:
            return "Fetch failed"
        case .cloudKitDeleteError:
            return "Delete failed"
        case .cloudKitZoneError:
            return "Zone error"
        case .invalidData:
            return "Invalid data"
        case .missingRequiredField:
            return "Missing required field"
        case .dataValidationError:
            return "Data validation error"
        case .unauthorized:
            return "Unauthorized"
        case .authenticationFailed:
            return "Authentication failed"
        case .familyAccessDenied:
            return "Family access denied"
        case .insufficientPoints:
            return "Insufficient points"
        case .invalidOperation:
            return "Invalid operation"
        case .operationNotAllowed:
            return "Operation not allowed"
        case .systemError:
            return "System error"
        case .unknownError:
            return "Unknown error"
        }
    }
}