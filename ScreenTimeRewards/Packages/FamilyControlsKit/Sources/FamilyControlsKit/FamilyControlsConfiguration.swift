import Foundation

// MARK: - Family Controls Configuration

/// Centralized configuration constants for Family Controls services
@available(iOS 15.0, macOS 11.0, *)
public struct FamilyControlsConfiguration {

    // MARK: - Authorization Configuration

    public struct Authorization {
        /// Default cache interval for authorization status (30 seconds)
        public static let defaultCacheInterval: TimeInterval = 30

        /// Minimum cache interval to prevent excessive API calls (5 seconds)
        public static let minimumCacheInterval: TimeInterval = 5

        /// Maximum cache interval for authorization status (5 minutes)
        public static let maximumCacheInterval: TimeInterval = 300
    }

    // MARK: - Device Activity Configuration

    public struct DeviceActivity {
        /// Default points earning interval (15 minutes)
        public static let defaultPointsEarningInterval: TimeInterval = TimeInterval.minutes(15)

        /// Default time limit check interval (1 hour)
        public static let defaultTimeLimitInterval: TimeInterval = TimeInterval.hours(1)

        /// Minimum monitoring interval (1 minute)
        public static let minimumMonitoringInterval: TimeInterval = TimeInterval.minutes(1)

        /// Maximum monitoring interval (4 hours)
        public static let maximumMonitoringInterval: TimeInterval = TimeInterval.hours(4)

        /// Default school hours start time
        public static let defaultSchoolStartHour = 7

        /// Default school hours end time
        public static let defaultSchoolEndHour = 21
    }

    // MARK: - Logging Configuration

    public struct Logging {
        /// Base subsystem identifier for all Family Controls logging
        public static let subsystem = "com.screentimerewards.familycontrolskit"

        /// Log file retention period (7 days)
        public static let logRetentionDays = 7

        /// Maximum log file size before rotation (10MB)
        public static let maxLogFileSizeBytes = 10 * 1024 * 1024
    }

    // MARK: - Performance Configuration

    public struct Performance {
        /// Background queue quality of service for logging
        public static let loggingQoS: DispatchQoS.QoSClass = .utility

        /// Maximum number of concurrent monitoring sessions
        public static let maxConcurrentMonitoringSessions = 5

        /// Timeout for authorization requests (30 seconds)
        public static let authorizationRequestTimeout: TimeInterval = 30
    }

    // MARK: - Validation Configuration

    public struct Validation {
        /// Minimum valid hour for schedule (0-23)
        public static let minimumScheduleHour = 0

        /// Maximum valid hour for schedule (0-23)
        public static let maximumScheduleHour = 23

        /// Minimum points earning interval (1 minute)
        public static let minimumPointsInterval: TimeInterval = TimeInterval.minutes(1)

        /// Maximum points earning interval (4 hours)
        public static let maximumPointsInterval: TimeInterval = TimeInterval.hours(4)
    }

    // MARK: - Default Configurations

    /// Default authorization configuration
    public static let defaultAuthorization = Authorization.self

    /// Default device activity configuration
    public static let defaultDeviceActivity = DeviceActivity.self

    /// Default logging configuration
    public static let defaultLogging = Logging.self

    /// Default performance configuration
    public static let defaultPerformance = Performance.self

    /// Default validation configuration
    public static let defaultValidation = Validation.self
}

// MARK: - TimeInterval Extensions

@available(iOS 15.0, macOS 11.0, *)
public extension TimeInterval {
    /// Convert minutes to TimeInterval
    static func minutes(_ minutes: Double) -> TimeInterval {
        return minutes * 60
    }

    /// Convert hours to TimeInterval
    static func hours(_ hours: Double) -> TimeInterval {
        return hours * 60 * 60
    }

    /// Convert days to TimeInterval
    static func days(_ days: Double) -> TimeInterval {
        return days * 24 * 60 * 60
    }
}