import Foundation
import SharedModels
import DeviceActivity

/// Validator that detects passive usage vs active engagement
public class EngagementValidator: UsageValidator {
    public var validatorName: String { "EngagementValidator" }
    
    // Thresholds for detection
    private let minimumInteractionTime: TimeInterval = 600.0 // 10 minutes
    private let passiveUsageThreshold: Double = 0.3 // 30% interaction density considered passive
    
    public init() {}
    
    public func validateSession(_ session: UsageSession, validationLevel: ValidationLevel) async -> ValidationResult {
        let engagementMetrics = analyzeEngagement(in: session)
        let isPassiveUsage = detectPassiveUsage(engagementMetrics: engagementMetrics)
        
        let validationScore: Double
        let confidenceLevel: Double
        let detectedPatterns: [GamingPattern]
        
        if isPassiveUsage {
            validationScore = 0.4 // Low score indicates passive usage
            confidenceLevel = 0.75 // Moderate to high confidence
            detectedPatterns = [.backgroundUsage] // Treat as background usage
        } else {
            validationScore = 0.9 // High score indicates active engagement
            confidenceLevel = 0.8 // High confidence
            detectedPatterns = []
        }
        
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
    
    /// Analyzes engagement metrics for a session
    /// - Parameter session: The usage session to analyze
    /// - Returns: EngagementMetrics with analysis results
    private func analyzeEngagement(in session: UsageSession) -> EngagementMetrics {
        // In a real implementation, this would use DeviceActivityMonitor data
        // For simulation, we'll estimate based on session characteristics
        
        // Estimate app state changes based on session duration
        let estimatedStateChanges = max(1, Int(session.duration / 300.0)) // Roughly every 5 minutes
        
        // Estimate interaction density based on session duration
        // Longer sessions might have lower interaction density
        let interactionDensity = max(0.1, min(1.0, 2.0 - (session.duration / 3600.0)))
        
        // Estimate average session length (this would be more complex in reality)
        let averageSessionLength = session.duration
        
        return EngagementMetrics(
            appStateChanges: estimatedStateChanges,
            averageSessionLength: averageSessionLength,
            interactionDensity: interactionDensity,
            deviceMotionCorrelation: session.duration > minimumInteractionTime ? 0.7 : 0.3
        )
    }
    
    /// Detects if the session shows signs of passive usage
    /// - Parameter engagementMetrics: The engagement metrics to analyze
    /// - Returns: True if passive usage is detected
    private func detectPassiveUsage(engagementMetrics: EngagementMetrics) -> Bool {
        // Check if interaction density is below threshold
        let isLowInteraction = engagementMetrics.interactionDensity < passiveUsageThreshold
        
        // Check if session is long with minimal state changes
        let isLongSessionWithLowActivity = 
            engagementMetrics.averageSessionLength > minimumInteractionTime && 
            engagementMetrics.appStateChanges < 3
        
        return isLowInteraction || isLongSessionWithLowActivity
    }
    
    /// Calculates the adjustment factor based on validation score and level
    /// - Parameters:
    ///   - validationScore: The validation score
    ///   - validationLevel: The validation strictness level
    /// - Returns: Adjustment factor (0.0 to 1.0)
    private func calculateAdjustmentFactor(validationScore: Double, validationLevel: ValidationLevel) -> Double {
        // Lenient mode is more forgiving
        if validationLevel == .lenient {
            return validationScore >= 0.7 ? 1.0 : (validationScore >= 0.4 ? 0.5 : 0.25)
        }
        
        // Strict mode is less forgiving
        if validationLevel == .strict {
            return validationScore >= 0.8 ? 1.0 : (validationScore >= 0.5 ? 0.25 : 0.0)
        }
        
        // Moderate mode (default)
        return validationScore >= 0.75 ? 1.0 : (validationScore >= 0.45 ? 0.5 : 0.0)
    }
}