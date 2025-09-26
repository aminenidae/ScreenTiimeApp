import Foundation
import FamilyControls
import OSLog
#if canImport(UIKit)
import UIKit
#endif

#if DEBUG

// MARK: - Family Controls Debug Tools

/// Debug tools for Family Controls development and troubleshooting
@available(iOS 15.0, macOS 11.0, *)
public class FamilyControlsDebugTools {

    // MARK: - Properties

    private static let logger = Logger(
        subsystem: "com.screentimerewards.familycontrolskit",
        category: "debug-tools"
    )

    // MARK: - Authorization Debugging

    /// Prints comprehensive authorization status information
    public static func printAuthorizationStatus() {
        let authService = FamilyControlsAuthorizationService()

        print("🔍 FAMILY CONTROLS DEBUG INFO")
        print("════════════════════════════")
        print("Authorization Status: \(authService.authorizationStatus.description)")
        print("Is Authorized: \(authService.isAuthorized())")
        print("Is Parent: \(authService.isParent())")
        print("Is Child: \(authService.isChild())")
        print("Authorization Required: \(authService.isAuthorizationRequired())")
        print("Authorization Denied: \(authService.wasAuthorizationDenied())")
        print("")
        print("Status Description: \(authService.getAuthorizationStatusDescription())")
        print("User Guidance: \(authService.getAuthorizationGuidance())")
        print("════════════════════════════")
    }

    /// Logs authorization status to console for monitoring
    public static func logAuthorizationStatus() {
        let authService = FamilyControlsAuthorizationService()

        logger.debug("=== Family Controls Authorization Debug ===")
        logger.debug("Status: \(authService.authorizationStatus.description)")
        logger.debug("Authorized: \(authService.isAuthorized())")
        logger.debug("Parent Role: \(authService.isParent())")
        logger.debug("Child Role: \(authService.isChild())")
        logger.debug("===========================================")
    }

    /// Tests authorization status caching mechanism
    public static func testAuthorizationCaching() {
        let authService = FamilyControlsAuthorizationService()

        print("🧪 TESTING AUTHORIZATION CACHING")
        print("═══════════════════════════════")

        // Get status multiple times to test caching
        let startTime = Date()
        let status1 = authService.authorizationStatus
        let time1 = Date().timeIntervalSince(startTime)

        let status2 = authService.authorizationStatus
        let time2 = Date().timeIntervalSince(startTime)

        print("First status check: \(status1.description) (took \(time1)s)")
        print("Second status check: \(status2.description) (took \(time2 - time1)s)")
        print("Status consistent: \(status1 == status2)")

        // Clear cache and test again
        authService.clearAuthorizationCache()
        let status3 = authService.authorizationStatus
        let time3 = Date().timeIntervalSince(startTime)

        print("After cache clear: \(status3.description) (took \(time3 - time2)s)")
        print("═══════════════════════════════")
    }

    // MARK: - Device Activity Debugging

    /// Prints device activity monitoring status
    public static func printMonitoringStatus() {
        let deviceService = DeviceActivityService()
        let activeMonitoring = deviceService.getActiveMonitoring()

        print("📱 DEVICE ACTIVITY MONITORING DEBUG")
        print("═══════════════════════════════════")
        print("Active Monitoring Sessions: \(activeMonitoring.count)")

        if activeMonitoring.isEmpty {
            print("No active monitoring sessions")
        } else {
            for (index, session) in activeMonitoring.enumerated() {
                print("  \(index + 1). \(session)")
            }
        }
        print("═══════════════════════════════════")
    }

    /// Tests device activity service functionality
    public static func testDeviceActivityService() {
        let deviceService = DeviceActivityService()

        print("🧪 TESTING DEVICE ACTIVITY SERVICE")
        print("══════════════════════════════════")

        // Test schedule creation
        let schedule = deviceService.createDailySchedule(
            startTime: DateComponents(hour: 8, minute: 0),
            endTime: DateComponents(hour: 20, minute: 0)
        )
        print("Created schedule: \(schedule.intervalStart.hour ?? 0):00 - \(schedule.intervalEnd.hour ?? 0):00")

        // Test event creation
        let events = deviceService.createTimeBasedEvents(
            for: [],
            pointsEarningThreshold: 900, // 15 minutes
            timeLimitThreshold: 3600     // 1 hour
        )
        print("Created \(events.count) events")

        // Test monitoring status
        let active = deviceService.getActiveMonitoring()
        print("Currently monitoring \(active.count) sessions")
        print("══════════════════════════════════")
    }

    // MARK: - System Environment Debugging

    /// Prints system environment information
    public static func printSystemEnvironment() {
        print("🔧 SYSTEM ENVIRONMENT DEBUG")
        print("═══════════════════════════")

        // Device information
        #if canImport(UIKit)
        if let device = UIDevice.current as Any as? UIDevice {
            print("Device: \(device.model)")
            print("iOS Version: \(device.systemVersion)")
            print("System Name: \(device.systemName)")
        }
        #else
        print("Device: macOS")
        print("System: macOS")
        #endif

        // Bundle information
        let bundle = Bundle.main
        print("App Version: \(bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
        print("Build Number: \(bundle.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")")
        print("Bundle ID: \(bundle.bundleIdentifier ?? "Unknown")")

        // Family Controls capability
        print("Family Controls Available: \(isFamilyControlsAvailable())")

        print("═══════════════════════════")
    }

    /// Checks if Family Controls is available on current device/iOS version
    public static func isFamilyControlsAvailable() -> Bool {
        // Since the class is already annotated with @available(iOS 15.0, macOS 11.0, *),
        // Family Controls are always available within this class
        return true
    }

    // MARK: - Comprehensive Debug Report

    /// Generates a comprehensive debug report for troubleshooting
    public static func generateDebugReport() -> String {
        var report = """
        FAMILY CONTROLS DEBUG REPORT
        Generated: \(Date())
        ════════════════════════════════════

        """

        // System Information
        report += """
        SYSTEM INFORMATION
        ──────────────────
        """
        
        #if canImport(UIKit)
        if let device = UIDevice.current as Any as? UIDevice {
            report += """
            Device: \(device.model)
            iOS Version: \(device.systemVersion)
            System Name: \(device.systemName)
            """
        }
        #else
        report += """
        Device: macOS
        System: macOS
        """
        #endif
        
        report += """
        App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
        Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")
        Family Controls Available: \(isFamilyControlsAvailable())

        """

        // Authorization Status
        let authService = FamilyControlsAuthorizationService()
        report += """
        AUTHORIZATION STATUS
        ────────────────────
        Status: \(authService.authorizationStatus.description)
        Is Authorized: \(authService.isAuthorized())
        Is Parent: \(authService.isParent())
        Is Child: \(authService.isChild())
        Description: \(authService.getAuthorizationStatusDescription())
        Guidance: \(authService.getAuthorizationGuidance())

        """

        // Device Activity Monitoring
        let deviceService = DeviceActivityService()
        let activeMonitoring = deviceService.getActiveMonitoring()
        report += """
        DEVICE ACTIVITY MONITORING
        ─────────────────────────
        Active Sessions: \(activeMonitoring.count)
        Session Names: \(activeMonitoring.joined(separator: ", "))

        """

        // Error Conditions
        report += """
        POTENTIAL ISSUES
        ───────────────
        """

        var issues: [String] = []

        if !isFamilyControlsAvailable() {
            issues.append("• Family Controls not available on this iOS version")
        }

        if !authService.isAuthorized() {
            issues.append("• Family Controls authorization not granted")
        }

        if activeMonitoring.isEmpty {
            issues.append("• No active device monitoring sessions")
        }

        if issues.isEmpty {
            report += "No critical issues detected\n"
        } else {
            report += issues.joined(separator: "\n") + "\n"
        }

        report += "\n════════════════════════════════════"

        return report
    }

    /// Saves debug report to file for sharing
    public static func saveDebugReportToFile() -> URL? {
        let report = generateDebugReport()

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "FamilyControls-Debug-\(DateFormatter.debugReportFormatter.string(from: Date())).txt"
        let fileURL = documentsPath.appendingPathComponent(fileName)

        do {
            try report.write(to: fileURL, atomically: true, encoding: .utf8)
            logger.info("Debug report saved to: \(fileURL.path)")
            return fileURL
        } catch {
            logger.error("Failed to save debug report: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Monitoring Helper

    /// Continuously monitors authorization status and logs changes
    public static func startAuthorizationMonitoring() {
        logger.info("Starting continuous authorization monitoring")

        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            logAuthorizationStatus()
        }
    }
}

// MARK: - Extensions

@available(iOS 15.0, macOS 11.0, *)
private extension DateFormatter {
    static let debugReportFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()
}

#endif
