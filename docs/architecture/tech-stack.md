# Tech Stack

## Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
|----------|-----------|---------|---------|-----------|
| **Frontend Language** | Swift | 5.9+ | Primary development language | Native iOS development, type safety, modern concurrency, optimal performance |
| **Frontend Framework** | SwiftUI | iOS 15.0+ | Declarative UI framework | Native Apple framework, reactive data binding, reduced UI code, Live Activities support |
| **UI Component Library** | Native SwiftUI Components | iOS 15.0+ | Standard UI elements | Zero dependencies, consistent iOS design, accessibility built-in, App Store compliance |
| **State Management** | Combine + SwiftUI @Published | iOS 15.0+ | Reactive state management | Native to SwiftUI, seamless integration with CloudKit publishers, minimal overhead |
| **Backend Language** | N/A (Serverless) | - | No custom backend needed | CloudKit provides serverless infrastructure |
| **Backend Framework** | CloudKit Framework | iOS 15.0+ | Serverless backend | Zero maintenance, automatic scaling, end-to-end encryption, iCloud integration |
| **API Style** | CloudKit Native APIs | CKDatabase, CKRecord | Data operations | Protocol-based repositories abstract CloudKit; no REST/GraphQL needed |
| **Database** | CloudKit (Primary) + CoreData (Cache) | iOS 15.0+ | Cloud + local storage | CloudKit for sync, CoreData for offline-first local cache and queries |
| **Cache** | NSCache + CoreData | iOS 15.0+ | Memory and disk caching | NSCache for images/ephemeral data, CoreData as persistent cache layer |
| **File Storage** | CloudKit Assets | CKAsset | Profile images, badges | Native CloudKit asset storage with CDN delivery |
| **Authentication** | iCloud + Family Sharing | iOS 15.0+ | User authentication | Zero-config auth, automatic family member discovery, COPPA compliant |
| **Frontend Testing** | XCTest + SwiftUI Previews | Xcode 15.0+ | Unit and UI testing | Native testing framework, preview-driven development, UI snapshot testing |
| **Backend Testing** | XCTest (Repository Mocks) | Xcode 15.0+ | CloudKit abstraction testing | Mock CKDatabase via protocols, test business logic without cloud dependency |
| **E2E Testing** | XCUITest | Xcode 15.0+ | End-to-end testing | Native iOS UI automation, integrates with CI/CD |
| **Build Tool** | Xcode Build System | Xcode 15.0+ | Compilation and builds | Native iOS build system with SPM integration |
| **Bundler** | Swift Package Manager (SPM) | Swift 5.9+ | Dependency and package management | Native Apple package manager, local packages for monorepo, zero config |
| **IaC Tool** | N/A (CloudKit Auto) | - | Infrastructure management | CloudKit schema deployment via Xcode, no custom IaC needed |
| **CI/CD** | Xcode Cloud | - | Continuous integration and delivery | Native Apple CI/CD, seamless TestFlight deployment, App Store integration |
| **Monitoring** | MetricKit + OSLog | iOS 15.0+ | Performance and crash monitoring | Native frameworks, privacy-preserving, battery/hang/crash metrics |
| **Logging** | OSLog (Unified Logging) | iOS 15.0+ | Structured logging | Native logging system, privacy categories, Console.app integration |
| **CSS Framework** | N/A (SwiftUI Native) | - | Styling | SwiftUI native styling with view modifiers, no web CSS needed |
| **Screen Time Integration** | Family Controls Framework | iOS 15.0+ | Usage monitoring and enforcement | Modern replacement for legacy Screen Time API, robust enforcement |
| **Device Activity Monitoring** | DeviceActivityMonitor | iOS 15.0+ | Granular app usage tracking | Real-time usage events, application state awareness |
| **Widget Framework** | WidgetKit + Live Activities | iOS 15.0+ (16.0 for LA) | Home screen widgets | Real-time point display, learning session progress |
| **Voice Integration** | App Intents Framework | iOS 16.0+ | Siri shortcuts | Voice commands for point queries and redemption |
| **Background Processing** | BackgroundTasks Framework | iOS 15.0+ | Point reconciliation | BGAppRefreshTask for periodic sync, BGProcessingTask for analytics |
| **Conflict Resolution** | CloudKit Conflict Handlers | CKRecord system fields | Multi-parent sync | Vector clocks via CKRecord metadata, last-write-wins with merge strategies |
| **Local Notifications** | UserNotifications Framework | iOS 15.0+ | Achievement alerts | Local notifications for points earned, goals reached |
| **In-App Purchases** | StoreKit 2 | iOS 15.0+ | Subscription system | Modern async/await API, auto-renewable subscriptions, transaction verification |
| **Receipt Validation** | CloudKit Functions | CloudKit | Server-side validation | Fraud prevention, offline grace period support, entitlement management |
| **Feature Gating** | FeatureGateService | Swift | Access control | Subscription-based feature access, graceful degradation on expiration |
| **Design Tokens** | Custom Swift Enums | - | Design system | Type-safe colors, spacing, typography in DesignSystem package |
