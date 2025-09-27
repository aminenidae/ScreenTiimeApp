// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScreenTimeRewards",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "RewardCore", targets: ["RewardCore"]),
        .library(name: "CloudKitService", targets: ["CloudKitService"]),
        .library(name: "FamilyControlsKit", targets: ["FamilyControlsKit"])
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
            path: "Packages/SharedModels/Sources/SharedModels"
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: ["SharedModels"],
            path: "Packages/SharedModels/Tests/SharedModelsTests"
        ),

        // DesignSystem
        .target(
            name: "DesignSystem",
            dependencies: ["SharedModels", "CloudKitService"],
            path: "Packages/DesignSystem/Sources/DesignSystem"
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            path: "Packages/DesignSystem/Tests/DesignSystemTests"
        ),

        // RewardCore
        .target(
            name: "RewardCore",
            dependencies: ["SharedModels"],
            path: "Packages/RewardCore/Sources/RewardCore"
        ),
        .testTarget(
            name: "RewardCoreTests",
            dependencies: ["RewardCore"],
            path: "Packages/RewardCore/Tests/RewardCoreTests"
        ),

        // CloudKitService
        .target(
            name: "CloudKitService",
            dependencies: ["SharedModels", "FamilyControlsKit"],
            path: "Packages/CloudKitService/Sources/CloudKitService"
        ),
        .testTarget(
            name: "CloudKitServiceTests",
            dependencies: ["CloudKitService"],
            path: "Packages/CloudKitService/Tests/CloudKitServiceTests"
        ),

        // FamilyControlsKit
        .target(
            name: "FamilyControlsKit",
            dependencies: ["SharedModels"],
            path: "Packages/FamilyControlsKit/Sources/FamilyControlsKit"
        ),
        .testTarget(
            name: "FamilyControlsKitTests",
            dependencies: ["FamilyControlsKit"],
            path: "Packages/FamilyControlsKit/Tests/FamilyControlsKitTests"
        )
    ]
)