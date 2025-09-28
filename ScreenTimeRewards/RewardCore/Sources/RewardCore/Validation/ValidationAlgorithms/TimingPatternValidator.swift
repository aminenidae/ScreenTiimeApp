import Foundation
import SharedModels

/// Validator that detects suspicious timing patterns that may indicate gaming
public class TimingPatternValidator: UsageValidator {
    public var validatorName: String { "TimingPatternValidator" }
    
    // Thresholds for detection
    private let exactBoundaryTolerance: TimeInterval = 60.0 // 1 minute tolerance for exact boundaries
    private let suspiciousDurationThreshold: TimeInterval = 3600.0 // 1 hour
    
    public init() {}
    
    public func validateSession(_ session: UsageSession, validationLevel: ValidationLevel) async -> ValidationResult {
        let isSuspiciousTiming = detectSuspiciousTiming(in: session)
        let isExactBoundary = detectExactHourBoundary(in: session)
        let isUnusuallyLong = session.duration > suspiciousDurationThreshold
        
        let validationScore: Double
        let confidenceLevel: Double
        let detectedPatterns: [GamingPattern]
        
        if isSuspiciousTiming || isExactBoundary {
            validationScore = isExactBoundary ? 0.2 : 0.5 // Lower score for exact boundaries
            confidenceLevel = isExactBoundary ? 0.9 : 0.7 // Higher confidence for exact boundaries
            detectedPatterns = isExactBoundary ? [.exactHourBoundaries] : [.suspiciouslyLongSession(duration: session.duration)]
        } else if isUnusuallyLong {
            validationScore = 0.6 // Moderate score for long sessions
            confidenceLevel = 0.6 // Moderate confidence
            detectedPatterns = [.suspiciouslyLongSession(duration: session.duration)]
        } else {
            validationScore = 0.9 // High score indicates normal timing
            confidenceLevel = 0.7 // Moderate confidence
            detectedPatterns = []
        }
        
        // Engagement metrics (simplified)
        let engagementMetrics = EngagementMetrics(
            appStateChanges: isSuspiciousTiming ? 0 : 2,
            averageSessionLength: session.duration,
            interactionDensity: isSuspiciousTiming ? 0.1 : 0.7,
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
    
    /// Detects suspicious timing patterns in the session
    /// - Parameter session: The usage session to analyze
    /// - Returns: True if suspicious timing is detected
    private func detectSuspiciousTiming(in session: UsageSession) -> Bool {
        // Check for exact hour boundaries (common gaming pattern)
        let startMinutes = Calendar.current.component(.minute, from: session.startTime)
        let startSeconds = Calendar.current.component(.second, from: session.startTime)
        let endMinutes = Calendar.current.component(.minute, from: session.endTime)
        let endSeconds = Calendar.current.component(.second, from: session.endTime)
        
        // Convert to TimeInterval for comparison
        let startSecondsDouble = TimeInterval(startSeconds)
        let endSecondsDouble = TimeInterval(endSeconds)
        
        // Suspicious if starting or ending very close to hour boundaries
        let isStartSuspicious = (startMinutes == 0 && startSecondsDouble < exactBoundaryTolerance) ||
                           (startMinutes == 59 && startSecondsDouble > (60.0 - exactBoundaryTolerance))
        let isEndSuspicious = (endMinutes == 0 && endSecondsDouble < exactBoundaryTolerance) ||
                         (endMinutes == 59 && endSecondsDouble > (60.0 - exactBoundaryTolerance))
        
        return isStartSuspicious || isEndSuspicious
    }
    
    /// Detects if session starts or ends exactly on hour boundaries
    /// - Parameter session: The usage session to analyze
    /// - Returns: True if exact hour boundary is detected
    private func detectExactHourBoundary(in session: UsageSession) -> Bool {
        let startSeconds = Calendar.current.component(.second, from: session.startTime)
        let startMinutes = Calendar.current.component(.minute, from: session.startTime)
        let endSeconds = Calendar.current.component(.second, from: session.endTime)
        let endMinutes = Calendar.current.component(.minute, from: session.endTime)
        
        // Convert to TimeInterval for comparison
        let startSecondsDouble = TimeInterval(startSeconds)
        let endSecondsDouble = TimeInterval(endSeconds)
        
        // Exact boundary if within tolerance
        let isStartExact = (startMinutes == 0 && startSecondsDouble <= exactBoundaryTolerance) ||
                      (startMinutes == 59 && startSecondsDouble >= (60.0 - exactBoundaryTolerance))
        let isEndExact = (endMinutes == 0 && endSecondsDouble <= exactBoundaryTolerance) ||
                    (endMinutes == 59 && endSecondsDouble >= (60.0 - exactBoundaryTolerance))
        
        return isStartExact || isEndExact
    }
    
    /// Calculates the adjustment factor based on validation score and level
    /// - Parameters:
    ///   - validationScore: The validation score
    ///   - validationLevel: The validation strictness level
    /// - Returns: Adjustment factor (0.0 to 1.0)
    private func calculateAdjustmentFactor(validationScore: Double, validationLevel: ValidationLevel) -> Double {
        // Lenient mode is more forgiving
        if validationLevel == .lenient {
            return validationScore >= 0.8 ? 1.0 : (validationScore >= 0.5 ? 0.75 : 0.25)
        }
        
        // Strict mode is less forgiving
        if validationLevel == .strict {
            return validationScore >= 0.85 ? 1.0 : (validationScore >= 0.6 ? 0.25 : 0.0)
        }
        
        // Moderate mode (default)
        return validationScore >= 0.8 ? 1.0 : (validationScore >= 0.55 ? 0.5 : 0.0)
    }
}