# Components

## RewardEngineCore

**Responsibility:** Central business logic for point calculation, reward conversion, and validation algorithms.

**Key Interfaces:**
- `PointCalculator` - Calculates points earned based on usage duration
- `RewardConverter` - Converts points to screen time
- `UsageValidator` - Anti-gaming validation logic
- `RewardStrategy` - Protocol for pluggable reward types

**Dependencies:** SharedModels, Foundation

**Technology Stack:** Pure Swift package, XCTest, Combine, Strategy pattern

---

## CloudKitSyncEngine

**Responsibility:** CloudKit operations, zone management, conflict resolution, real-time subscriptions.

**Key Interfaces:**
- Repository implementations (Family, ChildProfile, etc.)
- `ZoneManager` - Creates and manages per-child CloudKit zones
- `ConflictResolver` - Handles multi-parent edit conflicts
- `SubscriptionManager` - Manages CloudKit subscriptions
- `SyncCoordinator` - Coordinates offline queue and sync

**Dependencies:** CloudKit, CoreData, Combine, SharedModels

**Technology Stack:** CloudKit SDK, CoreData cache, Background Tasks

---

## FamilyControlsService

**Responsibility:** Wraps Family Controls framework for screen time enforcement and monitoring.

**Key Interfaces:**
- `ScreenTimeEnforcer` - Applies reward time limits using Managed Settings Store
- `AppBlockingService` - Uses Shield API to block apps
- `DeviceActivityTracker` - Monitors app usage via DeviceActivityMonitor
- `AuthorizationManager` - Handles parent/child role authorization

**Dependencies:** FamilyControls, ManagedSettings, DeviceActivity, SharedModels

**Technology Stack:** Family Controls framework, DeviceActivity, Combine

---

## ParentDashboardFeature

**Responsibility:** Parent-facing UI for monitoring, settings, and app categorization.

**Key Interfaces:**
- `DashboardViewModel` - Aggregates all children's progress
- `AppCategorizationViewModel` - Manages app categorization
- `SettingsViewModel` - Handles family settings
- `ReportsViewModel` - Generates usage analytics

**Dependencies:** RewardEngineCore, CloudKitSyncEngine, DesignSystem, SharedModels

**Technology Stack:** SwiftUI MVVM, Combine, NavigationStack

---

## ChildDashboardFeature

**Responsibility:** Child-facing gamified UI for points, progress, and redemption.

**Key Interfaces:**
- `ChildDashboardViewModel` - Displays points and rewards
- `RewardRedemptionViewModel` - Handles point-to-time conversion
- `ProgressTracker` - Shows learning goals
- `AchievementPresenter` - Celebratory UI

**Dependencies:** RewardEngineCore, CloudKitSyncEngine, DesignSystem, SharedModels

**Technology Stack:** SwiftUI with animations, WidgetKit, SF Symbols

---

## SubscriptionService

**Responsibility:** StoreKit 2 integration, subscription purchases, feature gating, receipt validation.

**Key Interfaces:**
- `SubscriptionManager` - Fetches products, handles purchases
- `ReceiptValidator` - Server-side validation via CloudKit Functions
- `FeatureGateService` - Subscription-based feature access control
- `TrialManager` - 14-day trial eligibility and management
- `EntitlementEngine` - Maps subscription tier to feature access

**Dependencies:** StoreKit, CloudKit, SharedModels

**Technology Stack:** StoreKit 2, CloudKit Functions, Combine, async/await

---

## BackgroundTasksCoordinator

**Responsibility:** Background point reconciliation and periodic sync.

**Key Interfaces:**
- `PointReconciliationTask` - Validates points every 15 min
- `UsageAnalysisTask` - Nightly usage analysis
- `SyncReconciliationTask` - Resolves offline conflicts
- `SubscriptionValidationTask` - Hourly receipt validation
- `TaskScheduler` - Registers background tasks

**Dependencies:** BackgroundTasks, RewardEngineCore, CloudKitSyncEngine, SubscriptionService

**Technology Stack:** BGAppRefreshTask, BGProcessingTask, Combine, OSLog

---

## WidgetExtension

**Responsibility:** Home screen widgets for real-time points and progress.

**Key Interfaces:**
- `PointsWidgetProvider` - Timeline for points widget
- `ProgressWidgetProvider` - Timeline for progress widget
- `LiveActivityProvider` - Live Activities (iOS 16+)
- `WidgetDataService` - Fetches from shared CoreData

**Dependencies:** WidgetKit, SharedModels, DesignSystem, CoreData

**Technology Stack:** WidgetKit, Live Activities, App Groups, SwiftUI

---

## AppIntentsExtension

**Responsibility:** Siri shortcuts and voice commands.

**Key Interfaces:**
- `CheckPointsIntent` - "Hey Siri, how many points?"
- `RedeemPointsIntent` - "Hey Siri, redeem points"
- `ViewProgressIntent` - "Hey Siri, show progress"
- `QuickCategorizationIntent` - Voice app categorization

**Dependencies:** App Intents, RewardEngineCore, CloudKitSyncEngine, SharedModels

**Technology Stack:** App Intents framework (iOS 16+), Siri, Shortcuts

---

## DesignSystem Package

**Responsibility:** Shared UI components and design tokens.

**Key Interfaces:**
- `ColorTokens` - App color palette
- `TypographyTokens` - Font styles
- `SpacingTokens` - Spacing values
- `CommonComponents` - Reusable buttons, cards, badges
- `GamificationComponents` - Point displays, progress rings

**Dependencies:** SwiftUI only

**Technology Stack:** Pure SwiftUI, custom view modifiers, SF Symbols

---

## SharedModels Package

**Responsibility:** Data models shared across app, widgets, and extensions.

**Key Interfaces:**
- Data model structs (Family, ChildProfile, etc.)
- Enums (AppCategory, TransactionType, etc.)
- Extension helpers
- Constants

**Dependencies:** Foundation, CloudKit, StoreKit

**Technology Stack:** Pure Swift, Codable, CKRecord extensions, StoreKit 2 types

---
