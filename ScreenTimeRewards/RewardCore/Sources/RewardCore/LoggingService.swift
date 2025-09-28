import Foundation
import OSLog

/// A service for structured logging throughout the application
public class LoggingService {
    private static let shared = LoggingService()
    
    private let logger: Logger
    
    private init() {
        self.logger = Logger(subsystem: "com.screentime.rewards", category: "app")
    }
    
    /// Get the shared instance of the logging service
    public static func shared() -> LoggingService {
        return shared
    }
    
    /// Log a debug message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called (automatically filled)
    ///   - function: The function where the log was called (automatically filled)
    ///   - line: The line where the log was called (automatically filled)
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.debug("\(message) [\(fileName(file)):\(function):\(line)]")
    }
    
    /// Log an info message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called (automatically filled)
    ///   - function: The function where the log was called (automatically filled)
    ///   - line: The line where the log was called (automatically filled)
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.info("\(message) [\(fileName(file)):\(function):\(line)]")
    }
    
    /// Log a warning message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called (automatically filled)
    ///   - function: The function where the log was called (automatically filled)
    ///   - line: The line where the log was called (automatically filled)
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.warning("\(message) [\(fileName(file)):\(function):\(line)]")
    }
    
    /// Log an error message
    /// - Parameters:
    ///   - message: The message to log
    ///   - error: An optional error to include details from
    ///   - file: The file where the log was called (automatically filled)
    ///   - function: The function where the log was called (automatically filled)
    ///   - line: The line where the log was called (automatically filled)
    public func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            logger.error("\(message): \(error.localizedDescription) [\(fileName(file)):\(function):\(line)]")
        } else {
            logger.error("\(message) [\(fileName(file)):\(function):\(line)]")
        }
    }
    
    /// Log a fault message (critical error)
    /// - Parameters:
    ///   - message: The message to log
    ///   - error: An optional error to include details from
    ///   - file: The file where the log was called (automatically filled)
    ///   - function: The function where the log was called (automatically filled)
    ///   - line: The line where the log was called (automatically filled)
    public func fault(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            logger.fault("\(message): \(error.localizedDescription) [\(fileName(file)):\(function):\(line)]")
        } else {
            logger.fault("\(message) [\(fileName(file)):\(function):\(line)]")
        }
    }
    
    /// Extract just the file name from the full file path
    /// - Parameter file: The full file path
    /// - Returns: The file name without extension
    private func fileName(_ file: String) -> String {
        let components = file.split(separator: "/")
        if let lastComponent = components.last {
            let fileNameComponents = lastComponent.split(separator: ".")
            return String(fileNameComponents.first ?? lastComponent)
        }
        return file
    }
}

// MARK: - Convenience Functions

/// Convenience function for debug logging
/// - Parameters:
///   - message: The message to log
///   - file: The file where the log was called (automatically filled)
///   - function: The function where the log was called (automatically filled)
///   - line: The line where the log was called (automatically filled)
public func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared().debug(message, file: file, function: function, line: line)
}

/// Convenience function for info logging
/// - Parameters:
///   - message: The message to log
///   - file: The file where the log was called (automatically filled)
///   - function: The function where the log was called (automatically filled)
///   - line: The line where the log was called (automatically filled)
public func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared().info(message, file: file, function: function, line: line)
}

/// Convenience function for warning logging
/// - Parameters:
///   - message: The message to log
///   - file: The file where the log was called (automatically filled)
///   - function: The function where the log was called (automatically filled)
///   - line: The line where the log was called (automatically filled)
public func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared().warning(message, file: file, function: function, line: line)
}

/// Convenience function for error logging
/// - Parameters:
///   - message: The message to log
///   - error: An optional error to include details from
///   - file: The file where the log was called (automatically filled)
///   - function: The function where the log was called (automatically filled)
///   - line: The line where the log was called (automatically filled)
public func logError(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared().error(message, error: error, file: file, function: function, line: line)
}

/// Convenience function for fault logging
/// - Parameters:
///   - message: The message to log
///   - error: An optional error to include details from
///   - file: The file where the log was called (automatically filled)
///   - function: The function where the log was called (automatically filled)
///   - line: The line where the log was called (automatically filled)
public func logFault(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared().fault(message, error: error, file: file, function: function, line: line)
}