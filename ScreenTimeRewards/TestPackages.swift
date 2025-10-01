import Foundation
import SharedModels
import FamilyControlsKit
import CloudKitService

// Test that we can create instances of our models and services
func testPackages() {
    // Test SharedModels
    let appCategory = AppCategory.learning
    let appMetadata = AppMetadata(
        id: "test-id",
        bundleID: "com.example.app",
        displayName: "Test App",
        isSystemApp: false,
        iconData: nil
    )
    let appCategorization = AppCategorization(
        id: "test-id",
        appBundleID: "com.example.app",
        category: appCategory,
        childProfileID: "child-123",
        pointsPerHour: 10
    )
    
    // Test FamilyControlsKit
    let appDiscoveryService = AppDiscoveryService()
    
    // Test CloudKitService
    let appCategorizationRepository = AppCategorizationRepository()
    
    print("All packages imported and instantiated successfully!")
    print("App Category: \(appCategory)")
    print("App Metadata: \(appMetadata.displayName)")
    print("App Categorization: \(appCategorization.category)")
}

// Run the test
testPackages()