import Foundation
import OSLog

// MARK: - Family Controls Logging System

/// Centralized logging system for Family Controls operations and troubleshooting
@available(iOS 15.0, macOS 11.0, *)
public class FamilyControlsLogger {

    // MARK: - Logger Categories

    public enum Category: String, CaseIterable {
        case authorization = "authorization"
        case deviceActivity = "device-activity"
        case monitoring = "monitoring"
        case events = "events"
        case errors = "errors"
        case performance = "performance"
        case debug = "debug"
    }

    // MARK: - Log Levels

    public enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }

    // MARK: - Properties

    private static let subsystem = FamilyControlsConfiguration.Logging.subsystem
    private static var loggers: [Category: Logger] = [:]

    // Log file management
    private static let logDirectory: URL = {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("FamilyControlsLogs")
    }()

    // MARK: - Initialization

    private static let initializeOnce: Void = {
        // Create loggers for all categories
        for category in Category.allCases {
            loggers[category] = Logger(subsystem: subsystem, category: category.rawValue)
        }

        // Ensure log directory exists
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
    }()

    // MARK: - Logging Methods

    /// Log authorization-related events
    public static func logAuthorization(_ message: String, level: LogLevel = .info, file: String = #file, line: Int = #line) {
        _ = initializeOnce  // Ensure initialization
        let logger = loggers[.authorization]!
        let formattedMessage = formatMessage(message, level: level, file: file, line: line)

        switch level {
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .warning:
            logger.warning("\(formattedMessage)")
        case .error, .critical:
            logger.error("\(formattedMessage)")
        }

        writeToFile(formattedMessage, category: .authorization)
    }

    /// Log device activity events
    public static func logDeviceActivity(_ message: String, level: LogLevel = .info, file: String = #file, line: Int = #line) {
        let logger = loggers[.deviceActivity]!
        let formattedMessage = formatMessage(message, level: level, file: file, line: line)

        switch level {
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .warning:
            logger.warning("\(formattedMessage)")
        case .error, .critical:
            logger.error("\(formattedMessage)")
        }

        writeToFile(formattedMessage, category: .deviceActivity)
    }

    /// Log monitoring operations
    public static func logMonitoring(_ message: String, level: LogLevel = .info, file: String = #file, line: Int = #line) {
        let logger = loggers[.monitoring]!
        let formattedMessage = formatMessage(message, level: level, file: file, line: line)

        switch level {
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .warning:
            logger.warning("\(formattedMessage)")
        case .error, .critical:
            logger.error("\(formattedMessage)")
        }

        writeToFile(formattedMessage, category: .monitoring)
    }

    /// Log events and callbacks
    public static func logEvent(_ message: String, level: LogLevel = .info, file: String = #file, line: Int = #line) {
        let logger = loggers[.events]!
        let formattedMessage = formatMessage(message, level: level, file: file, line: line)

        switch level {
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .warning:
            logger.warning("\(formattedMessage)")
        case .error, .critical:
            logger.error("\(formattedMessage)")
        }

        writeToFile(formattedMessage, category: .events)
    }

    /// Log errors and exceptions
    public static func logError(_ message: String, error: Error? = nil, file: String = #file, line: Int = #line) {
        let logger = loggers[.errors]!
        var fullMessage = message

        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }

        let formattedMessage = formatMessage(fullMessage, level: .error, file: file, line: line)
        logger.error("\(formattedMessage)")

        writeToFile(formattedMessage, category: .errors)
    }

    /// Log performance metrics
    public static func logPerformance(_ message: String, duration: TimeInterval? = nil, file: String = #file, line: Int = #line) {
        let logger = loggers[.performance]!
        var fullMessage = message

        if let duration = duration {
            fullMessage += " (took \(String(format: "%.3f", duration))s)"
        }

        let formattedMessage = formatMessage(fullMessage, level: .info, file: file, line: line)
        logger.info("\(formattedMessage)")

        writeToFile(formattedMessage, category: .performance)
    }

    /// Log debug information (only in debug builds)
    public static func logDebug(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let logger = loggers[.debug]!
        let formattedMessage = formatMessage(message, level: .debug, file: file, line: line)
        logger.debug("\(formattedMessage)")
        writeToFile(formattedMessage, category: .debug)
        #endif
    }

    // MARK: - Log Formatting

    private static func formatMessage(_ message: String, level: LogLevel, file: String, line: Int) -> String {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        return "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(message)"
    }

    // MARK: - File Logging

    private static func writeToFile(_ message: String, category: Category) {
        DispatchQueue.global(qos: FamilyControlsConfiguration.Performance.loggingQoS).async {
            let fileName = "FamilyControls-\(category.rawValue)-\(DateFormatter.logFileDate.string(from: Date())).log"
            let fileURL = logDirectory.appendingPathComponent(fileName)

            do {
                let data = (message + "\n").data(using: .utf8)!

                if FileManager.default.fileExists(atPath: fileURL.path) {
                    let fileHandle = try FileHandle(forWritingTo: fileURL)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    try data.write(to: fileURL)
                }
            } catch {
                // Fallback to system logger if file writing fails
                let logger = Logger(subsystem: subsystem, category: "file-logging")
                logger.error("Failed to write to log file: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Log File Management

    /// Returns URLs of all log files
    public static func getLogFileURLs() -> [URL] {
        do {
            let logFiles = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)
            return logFiles.filter { $0.pathExtension == "log" }.sorted { $0.lastPathComponent > $1.lastPathComponent }
        } catch {
            logError("Failed to get log file URLs", error: error)
            return []
        }
    }

    /// Returns the content of the most recent log file for a category
    public static func getRecentLogContent(for category: Category, lines: Int = 100) -> String? {
        let logFiles = getLogFileURLs().filter { $0.lastPathComponent.contains(category.rawValue) }
        guard let mostRecentFile = logFiles.first else { return nil }

        do {
            let content = try String(contentsOf: mostRecentFile)
            let allLines = content.components(separatedBy: .newlines)
            let recentLines = Array(allLines.suffix(lines))
            return recentLines.joined(separator: "\n")
        } catch {
            logError("Failed to read log file content", error: error)
            return nil
        }
    }

    /// Clears old log files based on configured retention period
    public static func cleanupOldLogFiles() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -FamilyControlsConfiguration.Logging.logRetentionDays, to: Date()) ?? Date()

        do {
            let logFiles = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: [.creationDateKey])

            for fileURL in logFiles {
                let resourceValues = try fileURL.resourceValues(forKeys: [.creationDateKey])
                if let creationDate = resourceValues.creationDate, creationDate < cutoffDate {
                    try FileManager.default.removeItem(at: fileURL)
                    logDebug("Removed old log file: \(fileURL.lastPathComponent)")
                }
            }
        } catch {
            logError("Failed to cleanup old log files", error: error)
        }
    }

    /// Generates a comprehensive log summary for troubleshooting
    public static func generateTroubleshootingReport() -> String {
        var report = """
        FAMILY CONTROLS TROUBLESHOOTING REPORT
        Generated: \(Date())
        ═══════════════════════════════════════

        """

        // Add recent logs from each category
        for category in Category.allCases {
            report += """

            \(category.rawValue.uppercased()) LOGS (Last 20 entries)
            \(String(repeating: "─", count: 40))
            """

            if let content = getRecentLogContent(for: category, lines: 20) {
                report += "\n\(content)\n"
            } else {
                report += "\nNo logs available for this category\n"
            }
        }

        return report
    }

    /// Saves troubleshooting report to file and returns URL
    public static func saveTroubleshootingReport() -> URL? {
        let report = generateTroubleshootingReport()
        let fileName = "FamilyControls-TroubleshootingReport-\(DateFormatter.reportTimestamp.string(from: Date())).txt"
        let fileURL = logDirectory.appendingPathComponent(fileName)

        do {
            try report.write(to: fileURL, atomically: true, encoding: .utf8)
            logDebug("Troubleshooting report saved to: \(fileURL.path)")
            return fileURL
        } catch {
            logError("Failed to save troubleshooting report", error: error)
            return nil
        }
    }

    // MARK: - Performance Measurement

    /// Measures and logs the execution time of a closure
    public static func measurePerformance<T>(_ operation: String, file: String = #file, line: Int = #line, closure: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try closure()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        logPerformance("Performance: \(operation)", duration: timeElapsed, file: file, line: line)
        return result
    }

    /// Measures and logs the execution time of an async closure
    public static func measurePerformanceAsync<T>(_ operation: String, file: String = #file, line: Int = #line, closure: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await closure()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        logPerformance("Async Performance: \(operation)", duration: timeElapsed, file: file, line: line)
        return result
    }
}

// MARK: - Date Formatters

@available(iOS 15.0, macOS 11.0, *)
private extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    static let logFileDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let reportTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()
}

// MARK: - Convenience Extensions

@available(iOS 15.0, macOS 11.0, *)
public extension FamilyControlsLogger {
    /// Quick authorization logging
    static func authInfo(_ message: String) { logAuthorization(message, level: .info) }
    static func authWarning(_ message: String) { logAuthorization(message, level: .warning) }
    static func authError(_ message: String) { logAuthorization(message, level: .error) }

    /// Quick device activity logging
    static func activityInfo(_ message: String) { logDeviceActivity(message, level: .info) }
    static func activityWarning(_ message: String) { logDeviceActivity(message, level: .warning) }
    static func activityError(_ message: String) { logDeviceActivity(message, level: .error) }

    /// Quick monitoring logging
    static func monitorInfo(_ message: String) { logMonitoring(message, level: .info) }
    static func monitorWarning(_ message: String) { logMonitoring(message, level: .warning) }
    static func monitorError(_ message: String) { logMonitoring(message, level: .error) }

    /// Quick event logging
    static func eventInfo(_ message: String) { logEvent(message, level: .info) }
    static func eventWarning(_ message: String) { logEvent(message, level: .warning) }
    static func eventError(_ message: String) { logEvent(message, level: .error) }
}