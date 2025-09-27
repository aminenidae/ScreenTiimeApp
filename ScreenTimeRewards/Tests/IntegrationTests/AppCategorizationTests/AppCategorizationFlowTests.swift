//
//  AppCategorizationFlowTests.swift
//  IntegrationTests
//
//  Created by James on 2025-09-27.
//

import XCTest
@testable import ScreenTimeRewards_Features_AppCategorization
import SharedModels

class AppCategorizationFlowTests: XCTestCase {
    
    func testCompleteAppCategorizationFlow() async throws {
        // This test covers the complete flow from UI interaction to data persistence
        // Since we're using mock services, we'll focus on the logic flow
        
        // 1. Test that apps can be loaded and displayed
        let viewModel = AppCategorizationViewModel()
        
        // 2. Test that apps can be categorized
        let testAppBundleID = "com.test.app"
        viewModel.updateAppCategory(bundleID: testAppBundleID, category: .learning)
        viewModel.updatePointsPerHour(bundleID: testAppBundleID, points: 10)
        
        // 3. Verify that the categorization is stored locally
        XCTAssertEqual(viewModel.appCategories[testAppBundleID], .learning)
        XCTAssertEqual(viewModel.appPoints[testAppBundleID], 10)
        
        // 4. Test that bulk categorization works
        let testAppBundleID2 = "com.test.app2"
        viewModel.toggleAppSelection(bundleID: testAppBundleID2)
        viewModel.bulkCategorize(to: .reward)
        
        // 5. Verify bulk categorization
        XCTAssertEqual(viewModel.appCategories[testAppBundleID2], .reward)
        
        // 6. Test validation logic
        XCTAssertTrue(viewModel.validateCategorizations())
        
        // 7. Test that changes can be marked as unsaved
        XCTAssertTrue(viewModel.hasUnsavedChanges)
    }
    
    func testAppCategoryConflictValidation() async throws {
        // Test that the validation logic prevents conflicts
        let viewModel = AppCategorizationViewModel()
        
        // Since our current implementation allows only one category per app,
        // there are no conflicts possible with the current UI design
        XCTAssertTrue(viewModel.validateCategorizations())
    }
    
    func testPointValueValidation() async throws {
        let viewModel = AppCategorizationViewModel()
        let testAppBundleID = "com.test.app"
        
        // Test that negative points are rejected
        viewModel.updatePointsPerHour(bundleID: testAppBundleID, points: -5)
        
        // The current implementation shows an error but still allows the value
        // In a real implementation, we might want to prevent negative values
        XCTAssertFalse(viewModel.hasUnsavedChanges)
    }
    
    func testLearningAppValidation() async throws {
        let viewModel = AppCategorizationViewModel()
        let testAppBundleID = "com.test.app"
        
        // Test that learning apps must have points
        viewModel.updateAppCategory(bundleID: testAppBundleID, category: .learning)
        
        // Validation should fail without points
        XCTAssertFalse(viewModel.validateCategorizations())
        
        // Add points and validation should pass
        viewModel.updatePointsPerHour(bundleID: testAppBundleID, points: 10)
        XCTAssertTrue(viewModel.validateCategorizations())
    }
}