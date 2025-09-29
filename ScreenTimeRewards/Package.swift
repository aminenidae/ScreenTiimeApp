// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScreenTimeRewards",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "CloudKitService", targets: ["CloudKitService"]),
        .library(name: "FamilyControlsKit", targets: ["FamilyControlsKit"]),
        .library(name: "RewardCore", targets: ["RewardCore"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "SubscriptionService", targets: ["SubscriptionService"])
    ],
    dependencies: [
        // Code quality tools for development
        .package(url: "https://github.com/realm/SwiftLint", from: "0.50.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.50.0")
    ],
    targets: [
        // SharedModels
        .target(
            name: "SharedModels",
            dependencies: [],
            path: "SharedModels/Sources/SharedModels"
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: ["SharedModels"],
            path: "SharedModels/Tests/SharedModelsTests"
        ),

        // CloudKitService
        .target(
            name: "CloudKitService",
            dependencies: ["SharedModels", "FamilyControlsKit"],
            path: "CloudKitService/Sources/CloudKitService"
        ),
        .testTarget(
            name: "CloudKitServiceTests",
            dependencies: ["CloudKitService"],
            path: "CloudKitService/Tests/CloudKitServiceTests"
        ),

        // FamilyControlsKit
        .target(
            name: "FamilyControlsKit",
            dependencies: ["SharedModels"],
            path: "FamilyControlsKit/Sources/FamilyControlsKit"
        ),
        .testTarget(
            name: "FamilyControlsKitTests",
            dependencies: ["FamilyControlsKit"],
            path: "FamilyControlsKit/Tests/FamilyControlsKitTests"
        ),
        
        // RewardCore
        .target(
            name: "RewardCore",
            dependencies: ["SharedModels", "CloudKitService", "FamilyControlsKit"],
            path: "RewardCore/Sources/RewardCore"
        ),
        .testTarget(
            name: "RewardCoreTests",
            dependencies: ["RewardCore"],
            path: "RewardCore/Tests/RewardCoreTests"
        ),
        
        // DesignSystem
        .target(
            name: "DesignSystem",
            dependencies: ["SharedModels"],
            path: "DesignSystem/Sources/DesignSystem"
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            path: "DesignSystem/Tests/DesignSystemTests"
        ),

        // SubscriptionService
        .target(
            name: "SubscriptionService",
            dependencies: ["SharedModels"],
            path: "SubscriptionService/Sources/SubscriptionService"
        ),
        .testTarget(
            name: "SubscriptionServiceTests",
            dependencies: ["SubscriptionService"],
            path: "SubscriptionService/Tests/SubscriptionServiceTests"
        )
    ]
)