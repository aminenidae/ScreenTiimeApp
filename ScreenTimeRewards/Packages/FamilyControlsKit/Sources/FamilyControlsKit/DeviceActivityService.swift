import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import OSLog
import SharedModels

// MARK: - Device Activity Service Protocol

/// Protocol for device activity monitoring operations
@available(iOS 15.0, macOS 11.0, *)
public protocol DeviceActivityServiceProtocol {
    /// Starts monitoring device activity for a child
    func startMonitoring(for childID: UUID, configuration: ActivityMonitoringConfiguration) throws

    /// Stops monitoring device activity for a child
    func stopMonitoring(for childID: UUID)

    /// Stops all active monitoring
    func stopAllMonitoring()

    /// Gets list of currently monitored activities
    func getActiveMonitoring() -> [String]

    /// Creates an activity schedule for daily monitoring
    func createDailySchedule(startTime: DateComponents, endTime: DateComponents) -> DeviceActivitySchedule

    /// Creates time-based events for point earning and limits
    func createTimeBasedEvents(for applications: Set<ApplicationToken>, pointsEarningThreshold: TimeInterval, timeLimitThreshold: TimeInterval) -> [DeviceActivityEvent.Name: DeviceActivityEvent]
}

// MARK: - Device Activity Service Implementation

/// Service for managing device activity monitoring
@available(iOS 15.0, macOS 11.0, *)
public class DeviceActivityService: DeviceActivityServiceProtocol {

    // MARK: - Properties

    private let deviceActivityCenter = DeviceActivityCenter()
    private let logger = Logger(subsystem: "com.screentimerewards.familycontrolskit", category: "device-activity")

    // Keep track of active monitoring sessions
    private var activeMonitoring: Set<String> = []

    // MARK: - Initialization

    public init() {}

    // MARK: - Protocol Implementation

    public func startMonitoring(for childID: UUID, configuration: ActivityMonitoringConfiguration) throws {
        logger.info("Starting device activity monitoring for child: \(childID.uuidString)")

        // Validate configuration before starting monitoring
        try validateConfiguration(configuration)

        let activityName = DeviceActivityName("monitoring_\(childID.uuidString)")

        // Create events based on configuration
        let events = createEvents(from: configuration)

        do {
            try deviceActivityCenter.startMonitoring(
                activityName,
                during: configuration.schedule,
                events: events
            )

            // Track active monitoring
            activeMonitoring.insert(activityName.rawValue)

            logger.info("Successfully started monitoring for child: \(childID.uuidString)")
        } catch {
            logger.error("Failed to start monitoring for child \(childID.uuidString): \(error.localizedDescription)")

            // Provide more specific error information
            if error.localizedDescription.contains("authorization") || error.localizedDescription.contains("permission") {
                throw DeviceActivityError.unauthorizedAccess
            } else {
                throw DeviceActivityError.monitoringStartFailed(error)
            }
        }
    }

    public func stopMonitoring(for childID: UUID) {
        logger.info("Stopping device activity monitoring for child: \(childID.uuidString)")

        let activityName = DeviceActivityName("monitoring_\(childID.uuidString)")
        deviceActivityCenter.stopMonitoring([activityName])

        // Remove from active monitoring
        activeMonitoring.remove(activityName.rawValue)

        logger.info("Successfully stopped monitoring for child: \(childID.uuidString)")
    }

    public func stopAllMonitoring() {
        logger.info("Stopping all device activity monitoring")

        // Convert active monitoring to DeviceActivityName objects
        let activityNames = activeMonitoring.map { DeviceActivityName($0) }
        deviceActivityCenter.stopMonitoring(activityNames)

        // Clear active monitoring
        activeMonitoring.removeAll()

        logger.info("Successfully stopped all monitoring sessions")
    }

    public func getActiveMonitoring() -> [String] {
        return Array(activeMonitoring)
    }

    public func createDailySchedule(startTime: DateComponents, endTime: DateComponents) -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: startTime,
            intervalEnd: endTime,
            repeats: true
        )
    }

    public func createTimeBasedEvents(
        for applications: Set<ApplicationToken>,
        pointsEarningThreshold: TimeInterval,
        timeLimitThreshold: TimeInterval
    ) -> [DeviceActivityEvent.Name: DeviceActivityEvent] {

        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        // Create points earning event (for educational apps)
        let pointsEvent = DeviceActivityEvent(
            applications: applications,
            threshold: DateComponents(second: Int(pointsEarningThreshold))
        )
        events[DeviceActivityEvent.Name("pointsEarned")] = pointsEvent

        // Create time limit event (for recreational apps)
        let timeLimitEvent = DeviceActivityEvent(
            applications: applications,
            threshold: DateComponents(second: Int(timeLimitThreshold))
        )
        events[DeviceActivityEvent.Name("timeLimit")] = timeLimitEvent

        logger.debug("Created \(events.count) time-based events")

        return events
    }

    // MARK: - Configuration Validation

    private func validateConfiguration(_ configuration: ActivityMonitoringConfiguration) throws {
        // Validate time intervals are within acceptable ranges
        guard configuration.pointsEarningInterval >= FamilyControlsConfiguration.Validation.minimumPointsInterval else {
            logger.error("Points earning interval too short: \(configuration.pointsEarningInterval) (minimum: \(FamilyControlsConfiguration.Validation.minimumPointsInterval))")
            throw DeviceActivityError.invalidConfiguration
        }

        guard configuration.pointsEarningInterval <= FamilyControlsConfiguration.Validation.maximumPointsInterval else {
            logger.error("Points earning interval too long: \(configuration.pointsEarningInterval) (maximum: \(FamilyControlsConfiguration.Validation.maximumPointsInterval))")
            throw DeviceActivityError.invalidConfiguration
        }

        guard configuration.timeLimitInterval > 0 else {
            logger.error("Invalid time limit interval: \(configuration.timeLimitInterval)")
            throw DeviceActivityError.invalidConfiguration
        }

        // Validate schedule is logical
        guard let startHour = configuration.schedule.intervalStart.hour,
              let endHour = configuration.schedule.intervalEnd.hour else {
            logger.error("Invalid schedule: missing hour components")
            throw DeviceActivityError.invalidConfiguration
        }

        guard startHour >= FamilyControlsConfiguration.Validation.minimumScheduleHour &&
              startHour <= FamilyControlsConfiguration.Validation.maximumScheduleHour &&
              endHour >= FamilyControlsConfiguration.Validation.minimumScheduleHour &&
              endHour <= FamilyControlsConfiguration.Validation.maximumScheduleHour else {
            logger.error("Invalid schedule hours: start=\(startHour), end=\(endHour) (valid range: \(FamilyControlsConfiguration.Validation.minimumScheduleHour)-\(FamilyControlsConfiguration.Validation.maximumScheduleHour))")
            throw DeviceActivityError.invalidConfiguration
        }

        guard startHour < endHour else {
            logger.error("Invalid schedule: start hour (\(startHour)) must be before end hour (\(endHour))")
            throw DeviceActivityError.invalidConfiguration
        }

        logger.debug("Configuration validation passed")
    }

    // MARK: - Private Event Creation

    private func createEvents(from configuration: ActivityMonitoringConfiguration) -> [DeviceActivityEvent.Name: DeviceActivityEvent] {
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        // Create events for educational apps (points earning)
        if !configuration.educationalApps.isEmpty && configuration.pointsEarningInterval > 0 {
            let pointsEvent = DeviceActivityEvent(
                applications: configuration.educationalApps,
                threshold: DateComponents(second: Int(configuration.pointsEarningInterval))
            )
            events[DeviceActivityEvent.Name("pointsEarned")] = pointsEvent
        }

        // Create events for recreational apps (time limits)
        if !configuration.recreationalApps.isEmpty && configuration.timeLimitInterval > 0 {
            let timeLimitEvent = DeviceActivityEvent(
                applications: configuration.recreationalApps,
                threshold: DateComponents(second: Int(configuration.timeLimitInterval))
            )
            events[DeviceActivityEvent.Name("timeLimit")] = timeLimitEvent
        }

        logger.debug("Created \(events.count) monitoring events from configuration")

        return events
    }
}

// MARK: - Configuration Types

/// Configuration for device activity monitoring
@available(iOS 15.0, macOS 11.0, *)
public struct ActivityMonitoringConfiguration {
    /// Schedule for monitoring (e.g., daily from 6 AM to 10 PM)
    public let schedule: DeviceActivitySchedule

    /// Educational apps to monitor for points earning
    public let educationalApps: Set<ApplicationToken>

    /// Recreational apps to monitor for time limits
    public let recreationalApps: Set<ApplicationToken>

    /// Interval for points earning notifications (in seconds)
    public let pointsEarningInterval: TimeInterval

    /// Interval for time limit warnings (in seconds)
    public let timeLimitInterval: TimeInterval

    public init(
        schedule: DeviceActivitySchedule,
        educationalApps: Set<ApplicationToken>,
        recreationalApps: Set<ApplicationToken>,
        pointsEarningInterval: TimeInterval,
        timeLimitInterval: TimeInterval
    ) {
        self.schedule = schedule
        self.educationalApps = educationalApps
        self.recreationalApps = recreationalApps
        self.pointsEarningInterval = pointsEarningInterval
        self.timeLimitInterval = timeLimitInterval
    }
}

// MARK: - Error Types

@available(iOS 15.0, macOS 11.0, *)
public enum DeviceActivityError: Error, LocalizedError {
    case monitoringStartFailed(Error)
    case invalidConfiguration
    case unauthorizedAccess
    case deviceNotSupported

    public var errorDescription: String? {
        switch self {
        case .monitoringStartFailed(let error):
            return "Failed to start device activity monitoring: \(error.localizedDescription)"
        case .invalidConfiguration:
            return "Invalid monitoring configuration provided"
        case .unauthorizedAccess:
            return "Device activity monitoring requires Family Controls authorization"
        case .deviceNotSupported:
            return "Device activity monitoring is not supported on this device"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .monitoringStartFailed:
            return "Please ensure Family Controls is authorized and try again"
        case .invalidConfiguration:
            return "Please check your monitoring configuration and ensure all required fields are provided"
        case .unauthorizedAccess:
            return "Please authorize Family Controls in Settings > Screen Time"
        case .deviceNotSupported:
            return "Device activity monitoring requires iOS 15.0 or later"
        }
    }
}

// MARK: - Convenience Extensions

@available(iOS 15.0, macOS 11.0, *)
extension DeviceActivitySchedule {
    /// Creates a schedule for all-day monitoring
    public static func allDaySchedule() -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
    }

    /// Creates a schedule for typical school hours
    public static func schoolHoursSchedule() -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: FamilyControlsConfiguration.DeviceActivity.defaultSchoolStartHour, minute: 0),
            intervalEnd: DateComponents(hour: FamilyControlsConfiguration.DeviceActivity.defaultSchoolEndHour, minute: 0),
            repeats: true
        )
    }

    /// Creates a schedule for weekend monitoring
    public static func weekendSchedule() -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 8, minute: 0),  // 8 AM
            intervalEnd: DateComponents(hour: 22, minute: 0),   // 10 PM
            repeats: true
        )
    }
}

@available(iOS 15.0, macOS 11.0, *)
extension ActivityMonitoringConfiguration {
    /// Default configuration for balanced screen time management
    public static func defaultConfiguration(
        educationalApps: Set<ApplicationToken>,
        recreationalApps: Set<ApplicationToken>
    ) -> ActivityMonitoringConfiguration {
        return ActivityMonitoringConfiguration(
            schedule: .schoolHoursSchedule(),
            educationalApps: educationalApps,
            recreationalApps: recreationalApps,
            pointsEarningInterval: FamilyControlsConfiguration.DeviceActivity.defaultPointsEarningInterval,
            timeLimitInterval: FamilyControlsConfiguration.DeviceActivity.defaultTimeLimitInterval
        )
    }
}