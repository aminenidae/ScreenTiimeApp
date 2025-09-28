import Foundation
import SharedModels
import FamilyControlsKit
import DeviceActivity

/// Service responsible for validating usage sessions to prevent gaming of the reward system
public class UsageValidationService {
    private let validationAlgorithms: [UsageValidator]
    private let familySettingsRepository: FamilySettingsRepository
    private let parentNotificationService: ParentNotificationService?
    
    public init(
        familySettingsRepository: FamilySettingsRepository,
        parentNotificationService: ParentNotificationService? = nil
    ) {
        self.familySettingsRepository = familySettingsRepository
        self.parentNotificationService = parentNotificationService
        self.validationAlgorithms = [
            RapidSwitchingValidator(),
            EngagementValidator(),
            TimingPatternValidator()
        ]
    }
    
    public func validateUsageSession(_ session: UsageSession, familyID: String) async throws -> ValidationResult {
        // Get family settings to determine validation strictness
        // Since we removed validationStrictness from FamilySettings to avoid circular dependencies,
        // we'll use a default validation level
        let validationLevel: ValidationLevel = .moderate
        
        // Run all validation algorithms
        var results: [ValidationResult] = []
        for validator in validationAlgorithms {
            let result = await validator.validateSession(session, validationLevel: validationLevel)
            results.append(result)
        }
        
        // Combine results using weighted scoring
        let combinedResult = combineValidationResults(results, validationLevel: validationLevel)
        
        // Notify parents if confidence is high enough
        if let parentNotificationService = parentNotificationService,
           combinedResult.confidenceLevel > 0.75 {
            await parentNotificationService.notifyParents(of: combinedResult, for: session, familyID: familyID)
        }
        
        return combinedResult
    }
    
    /// Combines multiple validation results into a single result
    /// - Parameters:
    ///   - results: Array of individual validation results
    ///   - validationLevel: The validation strictness level
    /// - Returns: Combined ValidationResult
    private func combineValidationResults(_ results: [ValidationResult], validationLevel: ValidationLevel) -> ValidationResult {
        guard !results.isEmpty else {
            // Return default valid result if no validations ran
            return ValidationResult(
                isValid: true,
                validationScore: 1.0,
                confidenceLevel: 1.0,
                detectedPatterns: [],
                engagementMetrics: EngagementMetrics(
                    appStateChanges: 0,
                    averageSessionLength: 0,
                    interactionDensity: 1.0,
                    deviceMotionCorrelation: nil
                ),
                validationLevel: validationLevel,
                adjustmentFactor: 1.0
            )
        }
        
        // Calculate weighted averages
        let totalScore = results.reduce(0.0) { $0 + $1.validationScore }
        let totalConfidence = results.reduce(0.0) { $0 + $1.confidenceLevel }
        let averageScore = totalScore / Double(results.count)
        let averageConfidence = totalConfidence / Double(results.count)
        
        // Combine detected patterns
        let allPatterns = results.flatMap { $0.detectedPatterns }
        
        // Combine engagement metrics (simplified averaging)
        let totalAppStateChanges = results.reduce(0) { $0 + $1.engagementMetrics.appStateChanges }
        let totalAverageSessionLength = results.reduce(0.0) { $0 + $1.engagementMetrics.averageSessionLength }
        let totalInteractionDensity = results.reduce(0.0) { $0 + $1.engagementMetrics.interactionDensity }
        
        let combinedMetrics = EngagementMetrics(
            appStateChanges: totalAppStateChanges / results.count,
            averageSessionLength: totalAverageSessionLength / Double(results.count),
            interactionDensity: totalInteractionDensity / Double(results.count),
            deviceMotionCorrelation: results.first?.engagementMetrics.deviceMotionCorrelation
        )
        
        // Determine if session is valid based on validation level threshold
        let isValid = averageScore >= validationLevel.confidenceThreshold
        
        // Calculate adjustment factor for point calculation
        let adjustmentFactor = calculateAdjustmentFactor(
            validationScore: averageScore,
            confidenceLevel: averageConfidence,
            validationLevel: validationLevel
        )
        
        return ValidationResult(
            isValid: isValid,
            validationScore: averageScore,
            confidenceLevel: averageConfidence,
            detectedPatterns: allPatterns,
            engagementMetrics: combinedMetrics,
            validationLevel: validationLevel,
            adjustmentFactor: adjustmentFactor
        )
    }
    
    /// Calculates the adjustment factor for point calculation based on validation results
    /// - Parameters:
    ///   - validationScore: The validation score (0.0 to 1.0)
    ///   - confidenceLevel: The confidence level in the validation (0.0 to 1.0)
    ///   - validationLevel: The validation strictness level
    /// - Returns: Adjustment factor (0.0 to 1.0)
    private func calculateAdjustmentFactor(validationScore: Double, confidenceLevel: Double, validationLevel: ValidationLevel) -> Double {
        // If validation score is high, give full points
        if validationScore >= 0.95 {
            return 1.0
        }
        
        // If validation score is medium, give partial points
        if validationScore >= 0.75 {
            return 0.75
        }
        
        // If validation score is low, give minimal points
        if validationScore >= 0.5 {
            return 0.5
        }
        
        // If validation score is very low, give no points
        return 0.0
    }
}

/// Protocol for usage validation algorithms
public protocol UsageValidator {
    func validateSession(_ session: UsageSession, validationLevel: ValidationLevel) async -> ValidationResult
    var validatorName: String { get }
}

/// Composite validator that combines multiple validation algorithms
public class CompositeUsageValidator: UsageValidator {
    private let validators: [UsageValidator]
    
    public var validatorName: String { "CompositeValidator" }
    
    public init(validators: [UsageValidator]) {
        self.validators = validators
    }
    
    public func validateSession(_ session: UsageSession, validationLevel: ValidationLevel) async -> ValidationResult {
        var results: [ValidationResult] = []
        for validator in validators {
            let result = await validator.validateSession(session, validationLevel: validationLevel)
            results.append(result)
        }
        
        // Simple combination - return the most conservative result
        let isValid = results.allSatisfy { $0.isValid }
        let lowestScore = results.map { $0.validationScore }.min() ?? 1.0
        let lowestConfidence = results.map { $0.confidenceLevel }.min() ?? 1.0
        let allPatterns = results.flatMap { $0.detectedPatterns }
        
        // Take metrics from first validator or create default
        let metrics = results.first?.engagementMetrics ?? EngagementMetrics(
            appStateChanges: 0,
            averageSessionLength: session.duration,
            interactionDensity: 1.0,
            deviceMotionCorrelation: nil
        )
        
        let adjustmentFactor = results.map { $0.adjustmentFactor }.min() ?? 1.0
        
        return ValidationResult(
            isValid: isValid,
            validationScore: lowestScore,
            confidenceLevel: lowestConfidence,
            detectedPatterns: allPatterns,
            engagementMetrics: metrics,
            validationLevel: validationLevel,
            adjustmentFactor: adjustmentFactor
        )
    }
}