import Foundation
import OSLog

/// Performance monitoring utility for Parent Dashboard
struct PerformanceMonitor {
    private static let logger = Logger(subsystem: "ScreenTimeRewards.ParentDashboard", category: "Performance")

    /// Measure execution time of an async operation
    static func measure<T>(
        operation: String,
        execute: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("⏱️ \(operation) completed in \(String(format: "%.3f", timeElapsed))s")

            // Log performance warnings for slow operations
            if timeElapsed > 2.0 {
                logger.warning("🐌 Slow operation detected: \(operation) took \(String(format: "%.3f", timeElapsed))s")
            }
        }

        return try await execute()
    }

    /// Measure execution time of a synchronous operation
    static func measure<T>(
        operation: String,
        execute: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("⏱️ \(operation) completed in \(String(format: "%.3f", timeElapsed))s")

            if timeElapsed > 1.0 {
                logger.warning("🐌 Slow operation detected: \(operation) took \(String(format: "%.3f", timeElapsed))s")
            }
        }

        return try execute()
    }

    /// Log memory usage for dashboard operations
    static func logMemoryUsage(for operation: String) {
        let memoryUsage = getCurrentMemoryUsage()
        logger.info("🧠 Memory usage for \(operation): \(String(format: "%.2f", memoryUsage))MB")

        // Warn about high memory usage
        if memoryUsage > 100.0 {
            logger.warning("⚠️ High memory usage detected: \(String(format: "%.2f", memoryUsage))MB for \(operation)")
        }
    }

    /// Get current memory usage in MB
    private static func getCurrentMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0 // Convert to MB
        } else {
            return 0.0
        }
    }
}

/// Data structure to track dashboard performance metrics
struct DashboardPerformanceMetrics {
    let loadTime: TimeInterval
    let childrenCount: Int
    let memoryUsage: Double
    let timestamp: Date

    init(loadTime: TimeInterval, childrenCount: Int) {
        self.loadTime = loadTime
        self.childrenCount = childrenCount
        self.memoryUsage = PerformanceMonitor.getCurrentMemoryUsage()
        self.timestamp = Date()
    }
}

/// Performance optimization hints for the dashboard
enum PerformanceOptimization {
    case enableLazyLoading
    case reduceUpdateFrequency
    case optimizeImageLoading
    case enableDataCaching

    var description: String {
        switch self {
        case .enableLazyLoading:
            return "Enable lazy loading for child progress cards"
        case .reduceUpdateFrequency:
            return "Reduce real-time update frequency"
        case .optimizeImageLoading:
            return "Optimize avatar image loading"
        case .enableDataCaching:
            return "Enable local data caching"
        }
    }
}

/// Accessibility configuration for dashboard components
struct AccessibilityConfiguration {
    static let defaultConfiguration = AccessibilityConfiguration()

    let announceDataUpdates: Bool = true
    let useReducedMotion: Bool = false
    let increaseContrastMode: Bool = false
    let voiceOverEnabled: Bool = false

    /// Get dynamic accessibility settings from the system
    static func current() -> AccessibilityConfiguration {
        return AccessibilityConfiguration(
            announceDataUpdates: true,
            useReducedMotion: UIAccessibility.isReduceMotionEnabled,
            increaseContrastMode: UIAccessibility.isDarkerSystemColorsEnabled,
            voiceOverEnabled: UIAccessibility.isVoiceOverRunning
        )
    }

    private init(announceDataUpdates: Bool = true, useReducedMotion: Bool = false, increaseContrastMode: Bool = false, voiceOverEnabled: Bool = false) {
        self.announceDataUpdates = announceDataUpdates
        self.useReducedMotion = useReducedMotion
        self.increaseContrastMode = increaseContrastMode
        self.voiceOverEnabled = voiceOverEnabled
    }
}