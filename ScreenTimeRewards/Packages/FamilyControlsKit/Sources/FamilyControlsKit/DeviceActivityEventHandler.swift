import Foundation
import DeviceActivity
import OSLog
#if canImport(CoreFoundation)
import CoreFoundation
#endif

// MARK: - Device Activity Event Handler

/// Centralized handler for device activity events and communication with main app
@available(iOS 15.0, macOS 11.0, *)
public class DeviceActivityEventHandler {

    // MARK: - Properties

    private static let logger = Logger(
        subsystem: "com.screentimerewards.familycontrolskit",
        category: "event-handler"
    )

    // Singleton instance
    public static let shared = DeviceActivityEventHandler()

    private init() {}

    // MARK: - Event Processing

    /// Processes device activity events and forwards them to the main app
    public func processEvent(
        type: DeviceActivityEventType,
        activity: DeviceActivityName,
        event: DeviceActivityEvent.Name? = nil,
        additionalInfo: [String: Any] = [:]
    ) {
        Self.logger.info("Processing device activity event: \(type.rawValue)")

        // Extract activity information
        let activityInfo = parseActivityName(activity.rawValue)

        // Create comprehensive event data
        var eventData = DeviceActivityEventData(
            type: type,
            activityName: activity.rawValue,
            childID: activityInfo.childID,
            eventName: event?.rawValue,
            timestamp: Date(),
            additionalInfo: additionalInfo
        )

        // Add parsed information
        eventData.activityType = activityInfo.type

        // Log detailed event information
        logEventDetails(eventData)

        // Send to main app
        sendEventToMainApp(eventData)

        // Handle specific event types
        handleSpecificEvent(eventData)
    }

    // MARK: - Event Handling

    private func handleSpecificEvent(_ eventData: DeviceActivityEventData) {
        switch eventData.type {
        case .intervalStart:
            handleIntervalStart(eventData)
        case .intervalEnd:
            handleIntervalEnd(eventData)
        case .thresholdReached:
            handleThresholdReached(eventData)
        case .intervalStartWarning, .intervalEndWarning:
            handleIntervalWarnings(eventData)
        case .thresholdWarning:
            handleThresholdWarnings(eventData)
        }
    }

    private func handleIntervalStart(_ eventData: DeviceActivityEventData) {
        Self.logger.info("Handling interval start for child: \(eventData.childID ?? "unknown")")

        // Initialize session tracking
        let sessionData: [String: Any] = [
            "sessionID": UUID().uuidString,
            "startTime": eventData.timestamp.timeIntervalSince1970,
            "childID": eventData.childID ?? "unknown"
        ]

        // Store session information
        storeSessionData(sessionData)

        // Send session start notification
        sendNotification(
            name: "SessionStarted",
            userInfo: sessionData
        )
    }

    private func handleIntervalEnd(_ eventData: DeviceActivityEventData) {
        Self.logger.info("Handling interval end for child: \(eventData.childID ?? "unknown")")

        // Calculate session statistics
        let sessionStats = calculateSessionStatistics(for: eventData.childID)

        // Send session end notification with statistics
        var sessionData: [String: Any] = [
            "endTime": eventData.timestamp.timeIntervalSince1970,
            "childID": eventData.childID ?? "unknown"
        ]

        if let stats = sessionStats {
            sessionData.merge(stats) { _, new in new }
        }

        sendNotification(
            name: "SessionEnded",
            userInfo: sessionData
        )
    }

    private func handleThresholdReached(_ eventData: DeviceActivityEventData) {
        Self.logger.warning("Handling threshold reached for child: \(eventData.childID ?? "unknown")")

        guard let eventName = eventData.eventName else {
            Self.logger.error("Threshold event missing event name")
            return
        }

        let thresholdData: [String: Any] = [
            "eventType": eventName,
            "childID": eventData.childID ?? "unknown",
            "timestamp": eventData.timestamp.timeIntervalSince1970,
            "severity": determineSeverity(for: eventName)
        ]

        // Different handling based on event type
        switch eventName {
        case "pointsEarned":
            handlePointsEarnedThreshold(thresholdData)
        case "timeLimit":
            handleTimeLimitThreshold(thresholdData)
        default:
            Self.logger.warning("Unknown threshold event: \(eventName)")
        }

        sendNotification(
            name: "ThresholdReached",
            userInfo: thresholdData
        )
    }

    private func handleIntervalWarnings(_ eventData: DeviceActivityEventData) {
        Self.logger.debug("Handling interval warning for child: \(eventData.childID ?? "unknown")")

        let warningData: [String: Any] = [
            "warningType": eventData.type.rawValue,
            "childID": eventData.childID ?? "unknown",
            "timestamp": eventData.timestamp.timeIntervalSince1970
        ]

        sendNotification(
            name: "IntervalWarning",
            userInfo: warningData
        )
    }

    private func handleThresholdWarnings(_ eventData: DeviceActivityEventData) {
        Self.logger.debug("Handling threshold warning for child: \(eventData.childID ?? "unknown")")

        guard let eventName = eventData.eventName else {
            Self.logger.error("Threshold warning missing event name")
            return
        }

        let warningData: [String: Any] = [
            "warningType": eventName,
            "childID": eventData.childID ?? "unknown",
            "timestamp": eventData.timestamp.timeIntervalSince1970,
            "urgency": determineUrgency(for: eventName)
        ]

        sendNotification(
            name: "ThresholdWarning",
            userInfo: warningData
        )
    }

    // MARK: - Specific Threshold Handlers

    private func handlePointsEarnedThreshold(_ thresholdData: [String: Any]) {
        Self.logger.info("Points earned threshold reached")

        // This would integrate with the points calculation system
        // For now, just log the achievement
        if let childID = thresholdData["childID"] as? String {
            Self.logger.info("Child \(childID) earned points for educational app usage")
        }
    }

    private func handleTimeLimitThreshold(_ thresholdData: [String: Any]) {
        Self.logger.warning("Time limit threshold reached")

        // This would integrate with the restriction system
        // For now, just log the limit reached
        if let childID = thresholdData["childID"] as? String {
            Self.logger.warning("Child \(childID) reached time limit - restrictions may apply")
        }
    }

    // MARK: - Helper Methods

    private func parseActivityName(_ name: String) -> (type: String?, childID: String?) {
        let components = name.split(separator: "_")
        if components.count >= 2 {
            return (type: String(components[0]), childID: String(components[1]))
        }
        return (type: nil, childID: nil)
    }

    private func logEventDetails(_ eventData: DeviceActivityEventData) {
        Self.logger.debug("Event Details:")
        Self.logger.debug("  Type: \(eventData.type.rawValue)")
        Self.logger.debug("  Activity: \(eventData.activityName)")
        Self.logger.debug("  Child ID: \(eventData.childID ?? "unknown")")
        Self.logger.debug("  Event: \(eventData.eventName ?? "none")")
        Self.logger.debug("  Timestamp: \(eventData.timestamp)")

        if !eventData.additionalInfo.isEmpty {
            Self.logger.debug("  Additional Info: \(eventData.additionalInfo)")
        }
    }

    private func sendEventToMainApp(_ eventData: DeviceActivityEventData) {
        // Convert event data to dictionary for Darwin notification
        var userInfo: [String: Any] = [
            "eventType": eventData.type.rawValue,
            "activityName": eventData.activityName,
            "timestamp": eventData.timestamp.timeIntervalSince1970
        ]

        if let childID = eventData.childID {
            userInfo["childID"] = childID
        }

        if let eventName = eventData.eventName {
            userInfo["eventName"] = eventName
        }

        userInfo.merge(eventData.additionalInfo) { _, new in new }

        // Send Darwin notification (iOS/macOS only)
        #if canImport(CoreFoundation) && (os(iOS) || os(macOS)) && !targetEnvironment(simulator)
        let notificationName = "com.screentimerewards.deviceactivity.\(eventData.type.rawValue)"
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil,
            userInfo as CFDictionary,
            true
        )
        Self.logger.debug("Sent Darwin notification: \(notificationName)")
        #else
        Self.logger.info("Darwin notifications not available on this platform")
        #endif
    }

    private func sendNotification(name: String, userInfo: [String: Any]) {
        let fullName = "com.screentimerewards.events.\(name)"

        #if canImport(CoreFoundation) && (os(iOS) || os(macOS)) && !targetEnvironment(simulator)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(fullName as CFString),
            nil,
            userInfo as CFDictionary,
            true
        )
        Self.logger.debug("Sent notification: \(fullName)")
        #else
        Self.logger.info("Darwin notifications not available - would send: \(fullName)")
        #endif
    }

    private func storeSessionData(_ sessionData: [String: Any]) {
        // Store session data for later retrieval and statistics
        // This would integrate with local storage or CloudKit
        Self.logger.debug("Storing session data: \(sessionData)")
    }

    private func calculateSessionStatistics(for childID: String?) -> [String: Any]? {
        // Calculate session statistics like total time, apps used, points earned
        // This would integrate with the actual tracking system
        guard let childID = childID else { return nil }

        return [
            "totalSessionTime": 0, // Would be calculated
            "appsUsed": 0,         // Would be calculated
            "pointsEarned": 0,     // Would be calculated
            "childID": childID
        ]
    }

    private func determineSeverity(for eventName: String) -> String {
        switch eventName {
        case "timeLimit":
            return "high"
        case "pointsEarned":
            return "low"
        default:
            return "medium"
        }
    }

    private func determineUrgency(for eventName: String) -> String {
        switch eventName {
        case "timeLimit":
            return "urgent"
        case "pointsEarned":
            return "info"
        default:
            return "normal"
        }
    }
}

// MARK: - Supporting Types

@available(iOS 15.0, macOS 11.0, *)
public struct DeviceActivityEventData {
    let type: DeviceActivityEventType
    let activityName: String
    let childID: String?
    let eventName: String?
    let timestamp: Date
    let additionalInfo: [String: Any]

    // Additional parsed information
    var activityType: String?

    init(
        type: DeviceActivityEventType,
        activityName: String,
        childID: String?,
        eventName: String?,
        timestamp: Date,
        additionalInfo: [String: Any] = [:]
    ) {
        self.type = type
        self.activityName = activityName
        self.childID = childID
        self.eventName = eventName
        self.timestamp = timestamp
        self.additionalInfo = additionalInfo
    }
}

@available(iOS 15.0, macOS 11.0, *)
public enum DeviceActivityEventType: String, CaseIterable {
    case intervalStart = "intervalStart"
    case intervalEnd = "intervalEnd"
    case thresholdReached = "thresholdReached"
    case intervalStartWarning = "intervalStartWarning"
    case intervalEndWarning = "intervalEndWarning"
    case thresholdWarning = "thresholdWarning"
}