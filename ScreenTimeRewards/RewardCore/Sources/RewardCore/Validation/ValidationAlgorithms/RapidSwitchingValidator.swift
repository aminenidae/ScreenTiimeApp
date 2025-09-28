import Foundation
import SharedModels
import DeviceActivity

/// Validator that detects rapid app switching patterns that may indicate gaming
public class RapidSwitchingValidator: UsageValidator {
    public var validatorName: String { "RapidSwitchingValidator" }
    
    // Thresholds for detection
    private let rapidSwitchThreshold: TimeInterval = 30.0 // 30 seconds
    private let switchesPerMinuteThreshold: Double = 5.0 // 5 switches per minute
    
    public init() {}
    
    public func validateSession(_ session: UsageSession, validationLevel: ValidationLevel) async -> ValidationResult {
        // This would typically use DeviceActivityMonitor data to detect rapid switching
        // For now, we'll simulate the detection logic
        
        let isRapidSwitching = detectRapidSwitching(in: session)
        let switchFrequency = calculateSwitchFrequency(for: session)
        
        let validationScore: Double
        let confidenceLevel: Double
        let detectedPatterns: [GamingPattern]
        
        if isRapidSwitching {
            validationScore = 0.3 // Low score indicates suspicious activity
            confidenceLevel = 0.8 // High confidence in detection
            detectedPatterns = [.rapidAppSwitching(frequency: switchFrequency)]
        } else {
            validationScore = 0.9 // High score indicates normal activity
            confidenceLevel = 0.7 // Moderate confidence
            detectedPatterns = []
        }
        
        // Engagement metrics (simplified)
        let engagementMetrics = EngagementMetrics(
            appStateChanges: isRapidSwitching ? Int(switchFrequency) : 1,
            averageSessionLength: session.duration,
            interactionDensity: isRapidSwitching ? 0.2 : 0.8,
            deviceMotionCorrelation: nil
        )
        
        // Calculate adjustment factor based on validation level
        let adjustmentFactor = calculateAdjustmentFactor(
            validationScore: validationScore,
            validationLevel: validationLevel
        )
        
        return ValidationResult(
            isValid: validationScore >= validationLevel.confidenceThreshold,
            validationScore: validationScore,
            confidenceLevel: confidenceLevel,
            detectedPatterns: detectedPatterns,
            engagementMetrics: engagementMetrics,
            validationLevel: validationLevel,
            adjustmentFactor: adjustmentFactor
        )
    }
    
    /// Detects if the session shows rapid app switching patterns
    /// - Parameter session: The usage session to analyze
    /// - Returns: True if rapid switching is detected
    private func detectRapidSwitching(in session: UsageSession) -> Bool {
        // In a real implementation, this would analyze DeviceActivityMonitor events
        // For simulation, we'll use a simple heuristic based on session duration
        // Rapid switching is more likely in very short sessions
        return session.duration < rapidSwitchThreshold
    }
    
    /// Calculates the switch frequency for the session
    /// - Parameter session: The usage session to analyze
    /// - Returns: Switches per minute
    private func calculateSwitchFrequency(for session: UsageSession) -> Double {
        // In a real implementation, this would count actual app switches
        // For simulation, we'll estimate based on session characteristics
        let minutes = session.duration / 60.0
        guard minutes > 0 else { return 0.0 }
        
        // Estimate switches based on session duration
        // Shorter sessions are more likely to have more switches
        let estimatedSwitches = max(1.0, 10.0 - minutes)
        return estimatedSwitches / minutes
    }
    
    /// Calculates the adjustment factor based on validation score and level
    /// - Parameters:
    ///   - validationScore: The validation score
    ///   - validationLevel: The validation strictness level
    /// - Returns: Adjustment factor (0.0 to 1.0)
    private func calculateAdjustmentFactor(validationScore: Double, validationLevel: ValidationLevel) -> Double {
        // Lenient mode is more forgiving
        if validationLevel == .lenient {
            return validationScore >= 0.8 ? 1.0 : (validationScore >= 0.5 ? 0.75 : 0.5)
        }
        
        // Strict mode is less forgiving
        if validationLevel == .strict {
            return validationScore >= 0.9 ? 1.0 : (validationScore >= 0.7 ? 0.5 : 0.0)
        }
        
        // Moderate mode (default)
        return validationScore >= 0.85 ? 1.0 : (validationScore >= 0.6 ? 0.5 : 0.0)
    }
}