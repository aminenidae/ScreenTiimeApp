import Foundation
import DeviceActivity
import OSLog

// MARK: - Device Activity Monitor Extension

/// DeviceActivityMonitor extension for tracking app usage events
@available(iOS 15.0, *)
extension DeviceActivityMonitor {

    // MARK: - Properties

    private static let logger = Logger(
        subsystem: "com.screentimerewards.screentimerewards",
        category: "device-activity"
    )

    // MARK: - DeviceActivityMonitor Lifecycle

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        Self.logger.info("Device activity interval started: \(activity.rawValue)")

        // Handle interval start
        handleIntervalStart(for: activity)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        Self.logger.info("Device activity interval ended: \(activity.rawValue)")

        // Handle interval end
        handleIntervalEnd(for: activity)
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        Self.logger.info("Device activity event reached threshold: \(event.rawValue) for activity: \(activity.rawValue)")

        // Handle threshold reached
        handleThresholdReached(event: event, activity: activity)
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)

        Self.logger.debug("Device activity interval will start warning: \(activity.rawValue)")

        // Handle warning
        handleIntervalWarning(for: activity, isStart: true)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)

        Self.logger.debug("Device activity interval will end warning: \(activity.rawValue)")

        // Handle warning
        handleIntervalWarning(for: activity, isStart: false)
    }

    override func eventWillReachThresholdWarning(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventWillReachThresholdWarning(event, activity: activity)

        Self.logger.debug("Device activity event will reach threshold warning: \(event.rawValue) for activity: \(activity.rawValue)")

        // Handle threshold warning
        handleThresholdWarning(event: event, activity: activity)
    }

    // MARK: - Event Handlers

    private func handleIntervalStart(for activity: DeviceActivityName) {
        // Extract activity information
        let activityInfo = parseActivityName(activity.rawValue)

        // Log the start of monitoring session
        let childID = activityInfo.childID ?? "unknown"
        Self.logger.info("Started monitoring session for child: \(childID)")

        // Notify the main app about the monitoring start
        sendNotificationToMainApp(
            type: .intervalStart,
            activity: activity,
            childID: activityInfo.childID
        )
    }

    private func handleIntervalEnd(for activity: DeviceActivityName) {
        // Extract activity information
        let activityInfo = parseActivityName(activity.rawValue)

        // Log the end of monitoring session
        let childID = activityInfo.childID ?? "unknown"
        Self.logger.info("Ended monitoring session for child: \(childID)")

        // Calculate session statistics if needed
        // This would integrate with data collection for point calculation

        // Notify the main app about the monitoring end
        sendNotificationToMainApp(
            type: .intervalEnd,
            activity: activity,
            childID: activityInfo.childID
        )
    }

    private func handleThresholdReached(event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        // Parse event and activity information
        let activityInfo = parseActivityName(activity.rawValue)
        let eventInfo = parseEventName(event.rawValue)

        let childID = activityInfo.childID ?? "unknown"
        let eventType = eventInfo.type ?? "unknown"
        Self.logger.warning("Time limit reached - Event: \(eventType), Child: \(childID)")

        // Handle different types of threshold events
        switch eventInfo.type {
        case "timeLimit":
            handleTimeLimitReached(activityInfo: activityInfo, eventInfo: eventInfo)
        case "pointsEarned":
            handlePointsEarnedThreshold(activityInfo: activityInfo, eventInfo: eventInfo)
        case .some(let type):
            Self.logger.error("Unknown threshold event type: \(type)")
        case .none:
            Self.logger.error("Threshold event type is nil")
        }

        // Notify the main app
        sendNotificationToMainApp(
            type: .thresholdReached,
            activity: activity,
            childID: activityInfo.childID,
            event: event
        )
    }

    private func handleIntervalWarning(for activity: DeviceActivityName, isStart: Bool) {
        let activityInfo = parseActivityName(activity.rawValue)
        let warningType = isStart ? "start" : "end"
        let childID = activityInfo.childID ?? "unknown"

        Self.logger.info("Interval \(warningType) warning for child: \(childID)")

        // Send warning notification to main app
        sendNotificationToMainApp(
            type: isStart ? .intervalStartWarning : .intervalEndWarning,
            activity: activity,
            childID: activityInfo.childID
        )
    }

    private func handleThresholdWarning(event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        let activityInfo = parseActivityName(activity.rawValue)
        let eventInfo = parseEventName(event.rawValue)
        let childID = activityInfo.childID ?? "unknown"
        let eventType = eventInfo.type ?? "unknown"

        Self.logger.info("Threshold warning - Event: \(eventType), Child: \(childID)")

        // Send warning notification to main app
        sendNotificationToMainApp(
            type: .thresholdWarning,
            activity: activity,
            childID: activityInfo.childID,
            event: event
        )
    }

    // MARK: - Specific Event Handlers

    private func handleTimeLimitReached(activityInfo: ActivityInfo, eventInfo: EventInfo) {
        let childID = activityInfo.childID ?? "unknown"
        Self.logger.info("Time limit reached for child: \(childID)")

        // Here would be the logic to:
        // 1. Update usage statistics
        // 2. Apply restrictions if needed
        // 3. Send notifications to parents/children
        // 4. Update point calculations

        // For now, just log the event
        Self.logger.info("Time limit enforcement triggered")
    }

    private func handlePointsEarnedThreshold(activityInfo: ActivityInfo, eventInfo: EventInfo) {
        let childID = activityInfo.childID ?? "unknown"
        Self.logger.info("Points earned threshold reached for child: \(childID)")

        // Here would be the logic to:
        // 1. Calculate points earned
        // 2. Update child's point balance
        // 3. Check for achievement unlocks
        // 4. Send congratulatory notifications

        // For now, just log the event
        Self.logger.info("Points calculation triggered")
    }

    // MARK: - Communication with Main App

    private func sendNotificationToMainApp(
        type: DeviceActivityEventType,
        activity: DeviceActivityName,
        childID: String?,
        event: DeviceActivityEvent.Name? = nil
    ) {
        // Create notification payload
        var userInfo: [String: Any] = [
            "eventType": type.rawValue,
            "activityName": activity.rawValue
        ]

        if let childID = childID {
            userInfo["childID"] = childID
        }

        if let event = event {
            userInfo["eventName"] = event.rawValue
        }

        // Send notification to main app
        // This uses Darwin notifications for cross-process communication
        let notificationName = "com.screentimerewards.deviceactivity.\(type.rawValue)"
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinCenter(),
            CFNotificationName(notificationName as CFString),
            nil,
            userInfo as CFDictionary,
            true
        )

        Self.logger.debug("Sent notification to main app: \(notificationName)")
    }

    // MARK: - Parsing Helpers

    private func parseActivityName(_ name: String) -> ActivityInfo {
        // Parse activity name format: "monitoring_{childID}" or "limit_{childID}"
        let components = name.split(separator: "_")

        if components.count >= 2 {
            let type = String(components[0])
            let childID = String(components[1])
            return ActivityInfo(type: type, childID: childID)
        }

        return ActivityInfo(type: nil, childID: nil)
    }

    private func parseEventName(_ name: String) -> EventInfo {
        // Parse event name format: "timeLimit", "pointsEarned", etc.
        // Could also parse thresholds if format is "timeLimit_30min"
        let components = name.split(separator: "_")
        
        if components.count >= 2 {
            let type = String(components[0])
            let threshold = String(components[1])
            return EventInfo(type: type, threshold: threshold)
        }
        
        return EventInfo(type: name, threshold: nil)
    }
}

// MARK: - Supporting Types

@available(iOS 15.0, *)
private struct ActivityInfo {
    let type: String?
    let childID: String?
}

@available(iOS 15.0, *)
private struct EventInfo {
    let type: String?
    let threshold: String?
}

@available(iOS 15.0, *)
private enum DeviceActivityEventType: String {
    case intervalStart = "intervalStart"
    case intervalEnd = "intervalEnd"
    case thresholdReached = "thresholdReached"
    case intervalStartWarning = "intervalStartWarning"
    case intervalEndWarning = "intervalEndWarning"
    case thresholdWarning = "thresholdWarning"
}