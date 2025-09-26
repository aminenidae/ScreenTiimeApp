# Reward-Based Screen Time Management App Product Requirements Document (PRD)

## Goals and Background Context

### Goals

- Transform traditional screen time management from a restrictive model to a reward-based system
- Reduce family conflict around screen time by creating positive behavioral reinforcement
- Encourage educational app usage through tangible rewards
- Provide parents with customizable controls while maintaining ease of use
- Establish a foundation for a comprehensive family digital wellness platform
- Enable multiple parents to collaboratively manage their children's screen time profiles and settings **(v1.1)**

### Background Context

Current screen time management solutions, particularly Apple's built-in Screen Time feature, create adversarial relationships between parents and children by focusing purely on restrictions. Market research indicates that 73% of parents struggle with screen time management, and 68% report it as a source of family conflict. Our solution addresses this by reframing screen time from a punishment to an earned privilege, allowing children to earn points for time spent on educational apps which can then be converted into screen time for recreational apps or real-world rewards.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-09-23 | 1.0 | Initial PRD creation based on project brief | Business Analyst |
| 2025-09-23 | 1.1 | Multi-parent features deferred to v1.1, Epic 1-3 corrections, Epic 6 added | Sarah (Product Owner) |
| 2025-09-24 | 1.2 | Added Epic 7: Payment & Subscription Infrastructure with StoreKit 2, FR15-19, NFR13-16 | John (Product Manager) |

## Requirements

### Functional

FR1: Parents can categorize apps as "learning" or "reward" with customizable point values
FR2: System tracks time spent on educational apps and awards points based on parent-defined values
FR3: Children can convert earned points to screen time for reward apps
FR4: Basic dashboard displays points earned, time spent, and available rewards
FR5: Parental controls allow setting of point values, minimum time requirements, and reward limits
FR6: Core functionality for points-to-time conversion is available in MVP
FR7: App integrates with iOS screen time monitoring APIs
FR8: System validates educational app usage to prevent gaming
FR9: Parents can view detailed reports on child's app usage and progress
FR10: Children receive notifications when they earn points or when rewards are available
FR11: Multiple parents can access and manage the same child's profile and settings **(v1.1)**
FR12: Changes made by one parent are synchronized in real-time to other parents **(v1.1)**
FR13: Parents can communicate with each other through the app about screen time decisions **(v1.1)**
FR14: Appropriate permissions and access controls ensure only authorized parents can make changes **(v1.1)**
FR15: Parents can subscribe to paid plans via Apple In-App Purchase with 14-day free trial
FR16: Subscription management allows upgrading/downgrading between child tiers
FR17: System enforces feature access based on active subscription status
FR18: Parents can view subscription status, billing history, and manage auto-renewal
FR19: App gracefully handles subscription expiration with appropriate feature limitations

### Non Functional

NFR1: App must comply with COPPA regulations for children's privacy
NFR2: System must have <5% battery impact on devices
NFR3: App storage requirements must be <100MB
NFR4: Support iOS 15.0 and above
NFR5: Ensure end-to-end encryption for sensitive data
NFR6: Achieve <5% crash rate in production
NFR7: App must be approved by Apple App Store
NFR8: System must synchronize data across devices via cloud services
NFR9: Response time for core features must be <2 seconds
NFR10: App must handle up to 10,000 concurrent users
NFR11: Real-time synchronization must work across multiple parent devices with <5 second delay **(v1.1)**
NFR12: Conflict resolution must handle simultaneous edits by multiple parents **(v1.1)**
NFR13: StoreKit 2 integration must handle subscription status validation with <1 second latency
NFR14: Payment processing must comply with Apple App Store Review Guidelines (3.1 In-App Purchase)
NFR15: Subscription receipt validation must be server-side with offline grace period support
NFR16: Free trial must be enforced without payment method requirement (Apple standard)

## User Interface Design Goals

### Overall UX Vision

The app should provide a friendly, gamified experience that makes screen time management feel less like punishment and more like a game. The interface should be intuitive for both parents and children, with distinct but cohesive experiences for each user type. Visual elements should reinforce the reward-based system with progress indicators, achievement badges, and celebratory moments when goals are reached.

### Key Interaction Paradigms

- Gamified point system with visual progress tracking
- Simple toggle-based app categorization for parents
- Child-friendly interface with large buttons and clear rewards
- Dashboard views for both parents and children showing progress
- Notification system for achievements and available rewards

### Core Screens and Views

- Parent Dashboard: Overview of all children's progress, app categorization, settings
- Child Dashboard: Points earned, available rewards, progress toward goals
- App Categorization Screen: Interface for parents to classify apps
- Reward Conversion Screen: Where children exchange points for screen time
- Settings Screen: Parental controls for point values and limits
- Reports Screen: Detailed usage analytics for parents

### Accessibility

WCAG AA

### Branding

Family-friendly, playful design with bright colors and gamification elements. Focus on positive reinforcement with celebratory animations when goals are achieved.

### Target Device and Platforms

Mobile Only (iOS iPhone and iPad)

## Technical Assumptions

### Repository Structure

Monorepo

### Service Architecture

Monolith with cloud-based backend services

### Testing Requirements

Unit + Integration

### Additional Technical Assumptions and Requests

- Integration with iOS Screen Time API for monitoring capabilities
- Firebase or similar cloud service for data synchronization
- Swift implementation with UIKit or SwiftUI
- COPPA compliance for children's data privacy
- Cloud Firestore or similar NoSQL database for data storage
- Implementation of usage validation algorithms to prevent gaming
- Modular architecture to support future feature expansion
- Real-time synchronization across multiple parent devices
- Secure invitation and authentication system for multi-parent families
- Conflict resolution mechanisms for simultaneous edits by multiple parents
- StoreKit 2 framework for subscription management and payment processing
- Server-side receipt validation system for subscription verification
- Subscription tier management: $9.99/month (1 child), +$3.99/month per additional child
- Annual pricing: $89.99/year (1 child), $125.99/year (2 children), +$25/year per additional child
- 14-day free trial implementation without payment method requirement

## Epic List

**v1.0 MVP Epics:**

Epic 1: Foundation & Core Infrastructure: Establish project setup, authentication, and basic app structure with core screen time monitoring integration

Epic 2: Core Reward System: Implement the fundamental points-based reward system including app categorization, point tracking, and reward conversion

Epic 3: User Experience & Interface: Develop complete user interfaces for both parents and children with dashboard views and core functionality

Epic 4: Reporting & Analytics: Provide detailed usage reports and analytics for parents to monitor progress and adjust settings

Epic 5: Validation & Testing: Implement usage validation algorithms and comprehensive testing to ensure system integrity

Epic 7: Payment & Subscription Infrastructure: Implement StoreKit 2 subscription system with tiered pricing, free trial, and subscription management

**v1.1 Post-MVP Epics:**

Epic 6: Multi-Parent Collaboration & Real-Time Synchronization: Enable multiple parents to collaboratively manage family accounts with real-time sync and conflict resolution

## Epic 1: Foundation & Core Infrastructure

### Goal

Establish the foundational project infrastructure including app setup, iOS screen time API integration, and basic architectural structure. This epic will deliver a functional app with core monitoring capabilities that can track app usage and lay the groundwork for the reward system.

Story 1.1: As a developer, I want to set up the basic iOS project structure with Swift Package Manager packages and necessary entitlements, so that we have a foundation for building the screen time management app.

Acceptance Criteria:
1. Xcode project is created with proper bundle identifiers
2. Swift Package Manager workspace is configured
3. Local package structure is created:
   - `Packages/SharedModels/` - Data models and enums
   - `Packages/DesignSystem/` - **UI components and design tokens (POPULATED)**
   - `Packages/RewardCore/` - Business logic (placeholder)
   - `Packages/CloudKitService/` - CloudKit wrapper (placeholder)
   - `Packages/FamilyControlsKit/` - Family Controls wrapper (placeholder)
4. **DesignSystem package populated with core elements**:
   - Color tokens (primary, secondary, accent, semantic colors)
   - Typography tokens (heading styles, body text, captions)
   - Spacing tokens (margins, padding, grid system)
   - Common UI components (buttons, cards, progress indicators)
   - Gamification components (point displays, progress rings, badges)
   - Icon system (SF Symbols integration)
5. App Store entitlements for screen time monitoring are configured
6. Basic app structure with navigation (AppCoordinator) is implemented
7. Project compiles successfully without errors
8. **All packages compile and work together** - no placeholder dependencies in Epic 2
9. README.md created with setup instructions

Story 1.2: As a developer, I want to integrate with iOS Family Controls and Screen Time APIs, so that the app can monitor and track app usage on the device.

Acceptance Criteria:
1. Family Controls framework is integrated into FamilyControlsKit package
2. App successfully requests and receives Family Controls authorization
3. AuthorizationCenter configured to detect parent/child roles
4. DeviceActivityMonitor capability added for usage tracking
5. Basic usage event detection is functional (app launch/close)
6. Authorization flow is tested on physical device (Simulator limitations noted)

Story 1.3: As a developer, I want to set up CloudKit schema, repository protocols, and local cache, so that user data can be synchronized across devices and backed up securely. **[CREATED: docs/stories/1.3.cloudkit-setup.md]**

Acceptance Criteria:
1. CloudKit container is configured in Xcode project
2. CloudKit schema is deployed with record types:
   - `Family` (in shared zone)
   - `ChildProfile` (in custom zones)
   - `AppCategorization` (in child zones)
   - `UsageSession` (in child zones)
   - `PointTransaction` (in child zones)
   - `RewardRedemption` (in child zones)
   - `FamilySettings` (in shared zone)
3. **CRITICAL: CloudKit schema deployment is validated and confirmed working before proceeding**
   - Test record creation/retrieval for each record type
   - Verify all indexes are properly configured and queryable
   - Confirm Development environment schema matches Production preparation
   - **MANDATORY CHECKPOINT: Execute end-to-end schema validation test**
     - Create test Family record → Save → Query → Update → Delete
     - Create test ChildProfile in private zone → Verify zone isolation
     - Test all 6 record types with proper field validation
     - Verify CloudKit Console shows all record types and indexes
     - **BLOCKING:** Epic 2 cannot start until this checkpoint passes
4. Custom CloudKit zones created (per-child private zones)
5. Repository protocol definitions are created in CloudKitService package:
   - `FamilyRepository` protocol
   - `ChildProfileRepository` protocol
   - `AppCategorizationRepository` protocol
   - `UsageSessionRepository` protocol
   - `PointTransactionRepository` protocol
6. CoreData schema created for local cache (offline support)
7. Mock repository implementations created for testing
8. **Repository integration tests pass** - All repository protocols work with real CloudKit before Epic 2
9. Basic data models defined in SharedModels package (Family, ChildProfile, etc.)
10. Zone management service (`CloudKitZoneManager`) implemented
11. COPPA compliance measures implemented for data storage (age verification, parental consent)
12. **Checkpoint: Complete end-to-end test** (create Family record → save → retrieve → update → sync)

Story 1.4: As a developer, I want to implement basic user authentication with iCloud, so that families can securely access their data and settings.

Acceptance Criteria:
1. iCloud authentication system is implemented
2. User account status detection (`CKContainer.accountStatus()`)
3. Family account structure supports parent and children profiles
4. Single parent can create family account
5. Data isolation ensures each family only sees their own data
6. Account recovery mechanisms are in place for forgotten passwords (iCloud native)
7. Basic parent authorization flow implemented (Face ID/Touch ID via AuthorizationCenter)
8. **Authentication integration validation** - Test complete auth flow before Epic 2
   - Verify iCloud account detection works on physical device
   - Test Family account creation with real CloudKit writes
   - Validate parent authorization via Family Controls framework
   - Confirm data isolation by creating test records in different zones
9. **Authentication error handling tested**
   - Handle "iCloud account not available" gracefully
   - Handle "Family Controls authorization denied" scenario
   - Test authentication flow with restricted/child accounts

Story 1.5: As a developer, I want to set up CI/CD pipeline and deployment infrastructure, so that automated testing and deployment can support development throughout all epics.

Acceptance Criteria:
1. **Xcode Cloud CI/CD pipeline configured**
   - Automatic builds triggered on pull requests and main branch commits
   - Build environment configured with proper iOS SDK version (15.0+)
   - Build workflow includes Swift Package Manager dependency resolution
2. **Automated testing pipeline**
   - Unit tests run automatically on every commit
   - UI tests configured (though limited on CI due to Family Controls requiring physical device)
   - Test results reported with pass/fail status and coverage metrics
3. **Code quality automation**
   - SwiftLint integration in CI pipeline
   - SwiftFormat validation
   - Build breaks on critical lint violations
4. **TestFlight deployment pipeline**
   - Automatic TestFlight builds from main branch
   - Beta testing group configured for internal testing
   - Build number auto-increment and version management
5. **App Store Connect integration**
   - App Store Connect app record created
   - Bundle identifiers reserved and configured
   - App metadata placeholders prepared
   - Screenshots and app description templates ready
6. **Environment management**
   - Development vs Production CloudKit environment handling
   - Build configuration management (Debug, Release, TestFlight)
   - Certificate and provisioning profile management via Xcode Cloud
7. **Deployment validation**
   - TestFlight build successfully processes and becomes available
   - Internal testing flow validated
   - App Store Review Guidelines pre-compliance check

**Dependencies:** Story 1.1 (Project structure), Story 1.3 (CloudKit configuration)

Story 1.6: As a developer, I want to configure all development and testing environment files, so that local development, testing, and subscription features work correctly across different environments.

Acceptance Criteria:
1. **StoreKit configuration files created**
   - `.storekit` configuration file created for local subscription testing
   - All subscription products defined with correct pricing tiers:
     - `screentime.1child.monthly` - $9.99/month
     - `screentime.2child.monthly` - $13.98/month
     - `screentime.1child.yearly` - $89.99/year
     - `screentime.2child.yearly` - $125.99/year
   - 14-day free trial configured on all products
   - Sandbox test scenarios defined
2. **CloudKit environment configuration**
   - Development CloudKit environment properly configured
   - Production CloudKit environment prepared (schema deployment ready)
   - Environment switching mechanism implemented (build configurations)
   - CloudKit console access verified for both environments
3. **Build configuration setup**
   - Debug, Release, and TestFlight build configurations defined
   - Environment-specific bundle identifiers configured
   - CloudKit container identifiers properly mapped per environment
   - Entitlements files properly configured per build type
4. **Development environment configuration**
   - `.swiftlint.yml` configuration file created with project-specific rules
   - `.swiftformat` configuration for code formatting standards
   - Xcode scheme configurations for different environments
   - Launch arguments for debug/testing modes
5. **Testing configuration files**
   - XCTest schemes configured for unit and UI testing
   - Mock data configuration files for testing scenarios
   - Test CloudKit environment setup for isolated testing
   - Background task testing configuration
6. **Environment validation**
   - All configurations tested and working
   - Environment switching verified (Dev ↔ Prod)
   - Local StoreKit testing validated
   - CloudKit connectivity confirmed for both environments

**Dependencies:** Story 1.1 (Project structure), Story 1.3 (CloudKit setup), Story 1.5 (CI/CD pipeline)

Story 1.7: As a developer, I want to implement app discovery and metadata services foundation, so that Epic 2 can immediately begin with app categorization functionality.

Acceptance Criteria:
1. **App Discovery Service created** in FamilyControlsKit package
   - Integrates with `ManagedSettingsStore.application` to access installed apps
   - Uses `FamilyActivityPicker` for app selection (iOS 15.0+ native approach)
   - Handles app bundle identifier resolution
2. **App Metadata Service implemented**
   - Fetches app display names, icons, and bundle identifiers
   - Caches app icons locally for performance (using NSCache)
   - Handles system apps vs user-installed apps distinction
3. **Installed Apps Repository protocol created**
   - Protocol: `InstalledAppsRepository` in CloudKitService package
   - Follows established patterns from Story 1.3
   - Mock implementation for testing
4. **Integration validation**
   - Works with CloudKit zone-based architecture
   - Physical device testing completed
   - Handles edge cases: deleted apps, system apps, restricted apps

**Dependencies:** Story 1.2 (Family Controls integration), Story 1.3 (Repository protocols)

**Note:** Multi-parent features (multiple parents per family, permissions, co-parent management) deferred to v1.1 Epic 6

## Epic 2: Core Reward System

### Goal

Implement the fundamental points-based reward system including app categorization, point tracking, and reward conversion. This epic will deliver the core value proposition of the app - allowing children to earn points for educational app usage and convert those points to screen time for recreational apps.

Story 2.0: MOVED TO EPIC 1 AS STORY 1.7 - App Discovery Service foundation now implemented in Epic 1.

Story 2.1: As a parent, I want to categorize apps as "learning" or "reward" with customizable point values, so that I can control which activities earn rewards and how much they're worth.

Acceptance Criteria:
1. **Interface for browsing and categorizing installed apps is implemented** (uses App Discovery Service from Story 2.0)
2. Parents can assign custom point values per hour for each app category
3. System validates app categorization and prevents conflicts
4. Categorized apps are saved and persist between app sessions
5. **App categorization UI handles app metadata** (names, icons from Story 2.0 services)

**Dependencies:** Story 1.7 (App Discovery Service - moved from 2.0)

Story 2.2: As a developer, I want to implement the point tracking engine, so that children earn points automatically based on time spent in educational apps.

Acceptance Criteria:
1. System accurately tracks time spent in categorized educational apps
2. Points are calculated and awarded based on parent-defined values
3. Tracking works in the background and survives app restarts
4. System handles edge cases like app switching and device sleep

Story 2.3: As a child, I want to convert my earned points to screen time for reward apps, so that I can access my favorite apps by earning educational time.

Acceptance Criteria:
1. Interface for viewing earned points is implemented
2. Children can select reward apps and convert points to time
3. System validates conversions and updates point balances
4. Reward time is properly allocated to selected apps

Story 2.4: As a parent, I want to set minimum time requirements and reward limits, so that I can ensure quality educational engagement and prevent excessive reward app usage.

Acceptance Criteria:
1. Settings interface for minimum time requirements is implemented
2. Parents can set daily/weekly limits for reward app usage
3. System enforces all parental controls consistently
4. Notifications are sent when limits are reached or adjusted

## Epic 3: User Experience & Interface

### Goal

Develop complete user interfaces for both parents and children with dashboard views and core functionality. This epic will deliver polished, intuitive interfaces that make the reward system engaging for children and easy to manage for parents.

Story 3.1: As a parent, I want a dashboard that shows all my children's progress, so that I can monitor their educational app usage and reward accumulation.

Acceptance Criteria:
1. Parent dashboard displays all children's:
   - Current point balance
   - Today's usage summary (learning vs reward time)
   - Available rewards
   - Recent activity (last 5 sessions)
2. Visual progress indicators:
   - Progress rings for daily learning goals
   - Point accumulation charts (last 7 days)
   - Streak indicators (consecutive learning days)
3. Quick access buttons:
   - "Categorize Apps"
   - "Adjust Settings"
   - "View Detailed Reports"
4. Dashboard updates in real-time as children use apps:
   - CloudKit subscription for ChildProfile changes
   - UI updates via Combine publishers
5. Pull-to-refresh for manual sync
6. Empty state UI when no children added yet

**Dependencies:** Epic 2 (Core reward functionality), Epic 7 Core (Stories 7.1-7.3 for subscription/paywall integration)

**Note:** Multi-parent dashboard features (co-parent visibility, activity log) deferred to v1.1 Epic 6

Story 3.2: As a child, I want a fun, engaging dashboard that shows my points and rewards, so that I'm motivated to use educational apps.

Acceptance Criteria:
1. Child dashboard uses gamification elements like progress bars and badges
2. Points balance and available rewards are clearly displayed
3. Visual feedback is provided when points are earned
4. Interface is intuitive for children to navigate

Story 3.3: As a parent, I want an easy-to-use app categorization screen, so that I can quickly set up and adjust which apps are educational vs. reward.

Acceptance Criteria:
1. App categorization interface is organized and efficient
2. Search and filter capabilities help find specific apps
3. Bulk categorization options save time for parents
4. Changes are immediately reflected in the tracking system

Story 3.4: As a user, I want a settings screen that allows me to customize all aspects of the reward system, so that I can tailor it to my family's needs.

Acceptance Criteria:
1. Comprehensive settings interface is implemented
2. All parental controls are accessible and clearly labeled
3. Settings changes take effect immediately
4. Default values guide new users through setup

~~Story 3.5: As a parent, I want to invite and manage other parents in my family account, so that we can collaboratively manage our children's screen time.~~

**Status:** DEFERRED TO v1.1 EPIC 6

**Rationale:** Multi-parent features deferred to reduce MVP complexity by 35% and accelerate time-to-market. All multi-parent functionality (invitation system, real-time sync, activity log, permissions, conflict resolution) moved to Epic 6 for v1.1 release.

**Original Acceptance Criteria (moved to Epic 6):**
1. Interface for inviting additional parents to the family account
2. Secure invitation links with expiration
3. Permission management (view-only vs. full access)
4. Remove co-parent functionality
5. In-app communication between parents
6. Activity log showing all parent changes

**See Epic 6 below for complete v1.1 implementation.**

Story 3.5: As a user (parent or child), I want comprehensive onboarding, help documentation, and user guides, so that I can easily understand and effectively use the app.

Acceptance Criteria:
1. **First-time user onboarding flow**
   - Interactive tutorial for parents covering:
     - iCloud and Family Controls setup
     - Creating child profiles
     - App categorization process
     - Understanding the reward system
     - Basic settings configuration
   - Child-friendly tutorial covering:
     - How to earn points
     - How to redeem rewards
     - Progress tracking
     - Understanding learning vs reward apps
2. **In-app help system**
   - Contextual help buttons on all major screens
   - Help overlay system with step-by-step guidance
   - FAQ section covering common questions:
     - "Why aren't points being awarded?"
     - "How do I change point values?"
     - "What if an app isn't categorized correctly?"
     - "How do rewards expire?"
3. **User guide documentation**
   - Complete parent guide covering all features
   - Child-friendly illustrated guide
   - Troubleshooting section for common issues
   - Family Controls permissions troubleshooting
   - CloudKit sync issues resolution
4. **Error state documentation**
   - Clear error messages with resolution steps
   - Common error scenarios documented:
     - "iCloud not available"
     - "Family Controls authorization denied"
     - "Sync failed - retry later"
     - "Insufficient points for redemption"
5. **Accessibility and COPPA compliance**
   - All documentation meets WCAG AA standards
   - Age-appropriate language for child-facing content
   - Parent consent flows clearly documented
   - Privacy-focused help content
6. **Help content delivery**
   - Help content available offline (cached locally)
   - Search functionality within help system
   - Direct links to relevant help from error states
   - Contact support option for unresolved issues

**Dependencies:** All Epic 3 UI stories (3.1-3.4), Epic 2 (Core functionality), Epic 7 (Subscription flows)

## Epic 4: Reporting & Analytics

### Goal

Provide detailed usage reports and analytics for parents to monitor progress and adjust settings. This epic will deliver insights that help parents understand their children's app usage patterns and optimize the reward system for better educational outcomes.

Story 4.1: As a parent, I want detailed reports on my child's app usage, so that I can understand their digital habits and adjust the reward system accordingly.

Acceptance Criteria:
1. Comprehensive reporting dashboard is implemented
2. Reports show time spent in different app categories
3. Historical data is available for trend analysis
4. Reports can be exported or shared with others

Story 4.2: As a parent, I want to see progress toward educational goals, so that I can celebrate achievements and identify areas for improvement.

Acceptance Criteria:
1. Goal tracking system is implemented with visual indicators
2. Achievement badges and milestones are displayed
3. Progress comparisons show improvement over time
4. Notifications highlight significant achievements

Story 4.3: As a developer, I want to implement data analytics capabilities, so that we can understand user behavior and improve the app.

Acceptance Criteria:
1. Anonymous usage analytics are collected (with proper consent)
2. Key metrics are tracked and reported
3. Data is aggregated to protect individual privacy
4. Analytics inform future feature development

Story 4.4: As a parent, I want to receive notifications about my child's progress, so that I can stay engaged with their educational journey.

Acceptance Criteria:
1. Notification system is implemented for key events
2. Parents can customize notification preferences
3. Notifications are timely and relevant
4. Notification frequency is reasonable to avoid annoyance

## Epic 5: Validation & Testing

### Goal

Implement usage validation algorithms and comprehensive testing to ensure system integrity. This epic will deliver confidence that the app works correctly and cannot be easily gamed by children.

Story 5.1: As a developer, I want to implement usage validation algorithms, so that children cannot easily game the system to earn points without genuine educational engagement.

Acceptance Criteria:
1. Algorithms detect and prevent common gaming techniques
2. System identifies passive usage vs. active engagement
3. Validation works without being overly restrictive
4. False positives are minimized through smart detection

Story 5.2: As a QA engineer, I want to conduct comprehensive testing of all core features, so that we can ensure the app works correctly before release.

Acceptance Criteria:
1. Unit tests cover all core functionality
2. Integration tests verify system components work together
3. User acceptance tests validate the experience for both parents and children
4. Performance tests confirm acceptable battery and storage impact

Story 5.3: As a developer, I want to implement error handling and recovery mechanisms, so that the app remains stable even when unexpected issues occur.

Acceptance Criteria:
1. Graceful error handling is implemented for all critical functions
2. Data recovery mechanisms protect against data loss
3. User-friendly error messages guide users through issues
4. Logging helps diagnose and resolve problems

Story 5.4: As a product manager, I want to validate App Store compliance and execute production deployment, so that the app can be successfully published and maintained.

Acceptance Criteria:
1. **App Store Review Guidelines compliance**
   - App meets all relevant App Store review guidelines (especially 3.1 for subscriptions)
   - Family Controls entitlements properly configured and justified
   - In-app purchase implementation follows Apple guidelines
2. **COPPA compliance verified and documented**
   - Age verification mechanisms tested
   - Parental consent flows validated
   - Data collection and storage practices documented
   - Privacy-first design confirmed
3. **Legal and policy requirements**
   - Privacy policy properly implemented and accessible
   - Terms of service created and integrated
   - App Store metadata and descriptions finalized
4. **Pre-submission validation**
   - Beta testing completed via TestFlight (internal team)
   - Performance benchmarks met (battery <5%, storage <100MB, launch <2s)
   - All NFRs validated in production-like environment
5. **Production deployment execution**
   - Final production build created via CI/CD pipeline (Story 1.5)
   - App Store submission completed
   - App Store review process managed and issues addressed
   - Production CloudKit environment validated
   - Subscription products configured in App Store Connect
6. **Launch readiness validation**
   - App successfully passes App Store review process
   - Production deployment tested end-to-end
   - Rollback procedures documented and tested
   - Support documentation ready for public users

**Dependencies:** Story 1.5 (CI/CD Pipeline), Epic 7 (Subscription Infrastructure), All previous epics (complete functionality)

## Epic 7: Payment & Subscription Infrastructure

### Goal

Implement a comprehensive subscription and payment system using StoreKit 2 that enables monetization through tiered pricing based on number of children, provides a frictionless 14-day free trial experience, and ensures compliance with Apple App Store guidelines. This epic delivers the revenue model critical for sustainable business operations while maintaining a user-friendly payment experience.

### Business Model

**Subscription Tiers:**
- **1 Child Plan:** $9.99/month or $89.99/year
- **2 Child Plan:** $13.98/month or $125.99/year
- **3+ Child Plan:** +$3.99/month or +$25/year per additional child

**Free Trial:**
- 14-day trial period (no payment method required)
- Full feature access during trial
- Automatic conversion to paid plan after trial
- No charges during trial period

**Included Features (All Tiers):**
- Multi-child support (based on tier)
- Advanced analytics and reporting
- Multi-parent collaboration (v1.1)
- Unlimited app categorizations
- Real-time synchronization

### Story 7.1: StoreKit 2 Integration & Product Configuration

**As a developer, I want to integrate StoreKit 2 and configure subscription products in App Store Connect, so that parents can purchase subscriptions through Apple In-App Purchase.**

**Acceptance Criteria:**

1. **StoreKit 2 Framework Integration**
   - StoreKit 2 added to Xcode project
   - `StoreKit.framework` linked properly
   - StoreKit configuration file created for local testing

2. **App Store Connect Product Setup**
   - Subscription group created: "Family Screen Time Management"
   - Monthly products configured:
     - `screentime.1child.monthly` - $9.99/month
     - `screentime.2child.monthly` - $13.98/month
     - Additional child upgrades configured as consumable in-app purchases
   - Annual products configured:
     - `screentime.1child.yearly` - $89.99/year
     - `screentime.2child.yearly` - $125.99/year
   - 14-day free trial enabled on all products

3. **Product Metadata**
   - Localized product descriptions written
   - Product display names configured
   - Subscription benefits clearly listed
   - Pricing tier selection optimized

4. **StoreKit Testing Configuration**
   - `.storekit` configuration file created
   - Test products match production configuration
   - Sandbox testing environment configured

5. **Product Fetching Service**
   - `SubscriptionService` created to fetch available products
   - Product caching implemented for offline access
   - Error handling for product fetch failures

6. **Documentation**
   - Product ID reference guide created
   - Subscription tier matrix documented

**Dependencies:** Epic 1 (CloudKit infrastructure)

---

### Story 7.2: Free Trial Implementation & Trial Management

**As a parent, I want to start a 14-day free trial without providing payment information, so that I can evaluate the app risk-free before committing to a subscription.**

**Acceptance Criteria:**

1. **Trial Eligibility Detection**
   - System checks trial eligibility via StoreKit 2 API
   - First-time users automatically qualify for trial
   - Users who previously trialed are identified and excluded
   - Trial status persisted in CloudKit `Family` record

2. **Trial Activation Flow**
   - "Start Free Trial" button prominently displayed on paywall
   - Trial activation requires Face ID/Touch ID confirmation only (no payment)
   - Trial start date stored in `Family.subscriptionMetadata.trialStartDate`
   - Trial expiration calculated (14 days from start)

3. **Trial Experience**
   - Full feature access during trial period
   - Trial countdown displayed in Settings screen
   - Reminder notifications:
     - 7 days remaining
     - 3 days remaining
     - 1 day remaining
     - Trial expired

4. **Trial Expiration Handling**
   - Graceful feature lockout after trial ends
   - Paywall presented on next app launch
   - Trial data preserved (no deletion)
   - Option to subscribe displayed prominently

5. **Trial Status UI**
   - Badge showing "Free Trial" in navigation bar
   - Days remaining indicator in Settings
   - Clear messaging about what happens after trial

6. **Server-Side Trial Validation**
   - CloudKit Function validates trial status
   - Trial bypass attempts detected and blocked
   - Audit log for trial activations

**Dependencies:** Story 7.1

---

### Story 7.3: Subscription Purchase Flow & Checkout

**As a parent, I want a seamless subscription purchase experience, so that I can easily subscribe to the plan that fits my family's needs.**

**Acceptance Criteria:**

1. **Paywall UI Implementation**
   - Beautiful, conversion-optimized paywall screen
   - Clear value proposition displayed
   - Pricing comparison table (monthly vs. annual)
   - Savings percentage highlighted for annual plans
   - Trial offer prominently featured

2. **Plan Selection Interface**
   - Number of children selector (1, 2, 3+)
   - Dynamic pricing calculation displayed
   - Monthly vs. Annual toggle
   - Selected plan highlighted clearly

3. **Purchase Flow**
   - "Start Free Trial" / "Subscribe Now" button
   - StoreKit 2 purchase sheet presented
   - Face ID/Touch ID authentication
   - Purchase processing indicator
   - Success confirmation with celebratory animation

4. **StoreKit 2 Purchase Logic**
   - `Product.purchase()` method implemented
   - Transaction verification using `Transaction.currentEntitlements`
   - Receipt validation via server
   - Entitlement granted immediately upon success

5. **Error Handling**
   - User cancellation handled gracefully
   - Payment failure errors displayed clearly
   - Network error retry logic
   - Support contact option for persistent errors

6. **Post-Purchase Experience**
   - Subscription confirmation screen
   - Receipt email sent (Apple-managed)
   - Features unlocked immediately
   - Onboarding continues seamlessly

7. **Analytics & Conversion Tracking**
   - Paywall impressions tracked
   - Purchase conversions logged
   - Drop-off points identified
   - A/B testing framework prepared

**Dependencies:** Story 7.2

---

### Story 7.4: Subscription Management & Status Monitoring

**As a parent, I want to view and manage my subscription, so that I can upgrade, downgrade, or cancel as my family's needs change.**

**Acceptance Criteria:**

1. **Subscription Status Service**
   - Real-time subscription status monitoring via `Transaction.currentEntitlements`
   - Status synced to CloudKit `Family.subscriptionStatus` field
   - Subscription states handled:
     - `active` - Paid and current
     - `trial` - In free trial period
     - `expired` - Lapsed subscription
     - `gracePeriod` - Payment issue, retrying
     - `revoked` - Refunded or cancelled

2. **Subscription Details Screen**
   - Current plan displayed (e.g., "2 Child Plan - Monthly")
   - Next billing date shown
   - Subscription price displayed
   - Manage subscription button (links to App Store)
   - Cancel subscription option

3. **Plan Upgrade/Downgrade**
   - "Change Plan" button in Settings
   - Upgrade flow to add more children
   - Downgrade flow with data preservation warning
   - Prorated billing handled by Apple
   - Immediate entitlement changes applied

4. **Subscription Renewal Monitoring**
   - Auto-renewal status detected
   - Renewal success/failure notifications
   - Billing issue alerts with resolution steps
   - Grace period handling (continue access for 16 days)

5. **Cancellation Flow**
   - "Cancel Subscription" redirects to App Store settings
   - Cancellation confirmation detected
   - Access continues until period end
   - Re-subscription offer presented after cancellation

6. **Family Sharing Compatibility**
   - Subscription shareable via Apple Family Sharing
   - Family members' access managed
   - Purchase account identified as subscription owner

7. **Subscription History**
   - Billing history displayed
   - Transaction receipts accessible
   - Refund requests directed to App Store

**Dependencies:** Story 7.3

---

### Story 7.5: Server-Side Receipt Validation & Entitlement Management

**As the system, I need server-side receipt validation to securely verify subscriptions and prevent fraud, so that only paying customers access premium features.**

**Acceptance Criteria:**

1. **CloudKit Server-Side Validation**
   - CloudKit Function: `validateSubscriptionReceipt`
   - Receives signed transaction from client
   - Validates transaction signature using Apple's JWS verification
   - Extracts subscription entitlements

2. **Entitlement Storage**
   - `SubscriptionEntitlement` record type in CloudKit
   - Fields:
     - `familyID` (reference to Family)
     - `productID` (subscription tier)
     - `expirationDate`
     - `isActive` (boolean)
     - `transactionID` (unique Apple transaction)
     - `originalTransactionID` (for upgrades/renewals)

3. **Entitlement Validation Logic**
   - Client queries entitlement on app launch
   - Subscription status cached locally for offline access
   - Server validates against Apple's servers periodically
   - Expiration checks run on critical feature access

4. **Fraud Prevention**
   - Duplicate transaction detection
   - Receipt tampering detection
   - Jailbreak detection and logging (non-blocking)
   - Anomalous usage patterns flagged

5. **Grace Period & Billing Retry**
   - 16-day grace period for billing issues
   - Entitlement remains active during grace period
   - Billing retry notifications sent to user
   - Access revoked after grace period expiration

6. **Offline Support**
   - Last known entitlement cached locally
   - 7-day offline grace period before feature lockout
   - Background sync when connectivity returns

7. **Admin Tools**
   - Subscription status dashboard (internal)
   - Manual entitlement grant for support cases
   - Refund/cancellation audit log

**Dependencies:** Story 7.4

---

### Story 7.6: Feature Gating & Paywall Enforcement

**As the system, I need to enforce subscription-based feature access, so that free users are guided to subscribe and paid users receive full access.**

**Acceptance Criteria:**

1. **Feature Gate Service**
   - `FeatureGateService` singleton created
   - Checks subscription status before feature access
   - Returns `FeatureAccessResult` (allowed/denied/trial)

2. **Feature Access Rules**
   - Trial users: Full access to all features
   - 1 Child Plan: 1 child profile, all features
   - 2+ Child Plans: Multiple children, all features
   - Expired subscription: Read-only access, paywall prompts

3. **Gated Features**
   - Child profile creation (based on tier)
   - Advanced analytics (premium only after trial)
   - Export reports (premium only)
   - Multi-parent invitations (v1.1, premium only)

4. **Paywall Trigger Points**
   - Add child beyond limit → Upgrade paywall
   - Access premium analytics → Subscribe paywall
   - Trial expiration → Conversion paywall
   - Lapsed subscription → Re-subscribe paywall

5. **UI Feature Gating**
   - Premium features show "lock" badge when unavailable
   - Tap on locked feature opens paywall
   - Upgrade prompts display pricing and value prop

6. **Graceful Degradation**
   - Expired users retain read-only access to existing data
   - No data deletion on subscription lapse
   - Core app categorization remains functional (view-only)

7. **Messaging & CTAs**
   - Clear upgrade benefits messaging
   - "Unlock with Premium" buttons
   - Trial countdown creates urgency

**Dependencies:** Story 7.5

---

### Story 7.7: Subscription Analytics & Optimization

**As a product manager, I want subscription analytics and A/B testing capabilities, so that I can optimize conversion rates and maximize revenue.**

**Acceptance Criteria:**

1. **Conversion Funnel Tracking**
   - Paywall impressions logged
   - Trial starts tracked
   - Purchases recorded with metadata
   - Conversion rates calculated per funnel stage

2. **Key Metrics Dashboard**
   - Trial-to-paid conversion rate
   - Monthly Recurring Revenue (MRR)
   - Annual Recurring Revenue (ARR)
   - Customer Lifetime Value (LTV)
   - Churn rate
   - Average Revenue Per User (ARPU)

3. **Cohort Analysis**
   - Trial cohorts by start date
   - Conversion rates by acquisition channel
   - Retention by subscription tier

4. **A/B Testing Framework**
   - Paywall design variants testable
   - Pricing experiments supported
   - Trial duration experiments (future)
   - Feature gate experiments

5. **Event Logging**
   - Subscription events sent to analytics backend
   - Events: trial_start, purchase, renewal, cancellation, churn
   - User properties: subscription_tier, trial_status, ltv

6. **Revenue Reporting**
   - Daily/weekly/monthly revenue reports
   - Revenue by subscription tier
   - Refund tracking
   - Net revenue calculations

7. **Optimization Insights**
   - Drop-off point identification
   - Pricing sensitivity analysis
   - Feature value perception metrics

**Dependencies:** Story 7.6

---

### Epic 7 Success Metrics

**Business Metrics:**
- Trial-to-paid conversion rate >30%
- Monthly churn rate <5%
- Average LTV >$150 per family
- Payment failure rate <2%

**Technical Metrics:**
- Receipt validation latency <1 second
- StoreKit purchase success rate >95%
- Entitlement sync reliability >99.9%

**User Experience:**
- Paywall-to-purchase completion >60%
- Subscription management task success >90%
- Payment error resolution time <2 minutes

---

## Epic 7 Implementation Phases

**Phase 1 (Weeks 8-9): Core Subscription Foundation**
| Week | Focus | Deliverables |
|------|-------|--------------|
| 8 | Stories 7.1 + 7.2 | StoreKit integration, Free trial |
| 9 | Story 7.3 | Purchase flow (needed for Epic 3) |

**Phase 2 (Week 14): Advanced Subscription Features**
| Week | Focus | Deliverables |
|------|-------|--------------|
| 14 | Stories 7.4-7.7 | Management, validation, analytics |

**Total:** 3 weeks core + 1 week advanced (integrated with Epic timeline)

---

### App Store Review Considerations

**Critical for Approval:**
1. All payments via Apple In-App Purchase (no external payment links)
2. Clear pricing and subscription terms displayed before purchase
3. Subscription management via iOS Settings accessible
4. No "subscribe or delete account" dark patterns
5. Privacy policy updated with payment data handling
6. Restore purchases functionality implemented

**Compliance:**
- App Store Review Guideline 3.1 (In-App Purchase)
- Guideline 3.1.1 (Subscription transparency)
- Guideline 3.1.2 (Subscription management)

---

## Epic 6: Multi-Parent Collaboration & Real-Time Synchronization (v1.1)

### Goal

Enable multiple parents to collaboratively manage their children's screen time profiles with real-time synchronization, secure permission controls, and transparent activity tracking. This epic delivers seamless multi-parent coordination that was deferred from MVP to reduce initial complexity while maintaining architectural readiness for future expansion.

### Release Information

**Version:** v1.1 (Post-MVP)
**Estimated Timeline:** 4 weeks after v1.0 launch
**Target Market Expansion:** 65% of families (two-parent households)

### Requirements Addressed

**Functional Requirements (Deferred from v1.0):**
- FR11: Multiple parents can access and manage the same child's profile and settings
- FR12: Changes made by one parent are synchronized in real-time to other parents
- FR13: Parents can communicate with each other through the app about screen time decisions (via activity log)
- FR14: Appropriate permissions and access controls ensure only authorized parents can make changes

**Non-Functional Requirements (Deferred from v1.0):**
- NFR11: Real-time synchronization must work across multiple parent devices with <5 second delay
- NFR12: Conflict resolution must handle simultaneous edits by multiple parents

### Prerequisites (Built in v1.0)

The following architectural foundations are already in place from v1.0:
- `Family.sharedWithUserIDs` array field (supports multi-parent data model)
- `metadata.modifiedBy` tracking in all records
- CloudKit shared zone architecture
- iCloud Family Sharing integration
- Repository pattern with protocol abstractions

### Story 6.1: Parent Invitation System

**As a parent (family owner), I want to invite another parent to co-manage our family account, so that we can both access and manage our children's screen time settings.**

**Acceptance Criteria:**

1. **Invite Flow UI Created**
   - New "Family Sharing" section added to Settings screen
   - "Invite Co-Parent" button prominently displayed
   - Current co-parents list shown with avatars and roles
   - "Remove Co-Parent" option available (owner only)

2. **Secure Invitation Link Generation**
   - System generates unique, time-limited invitation token (UUID)
   - Invitation stored in CloudKit record type `FamilyInvitation`
   - Deep link generated: `screentimerewards://invite/{token}`
   - Share sheet allows sending via Messages, Email, or AirDrop

3. **Invitation Acceptance Flow**
   - Invitee taps deep link → App opens
   - Invitation validation (token validity, expiration, iCloud account)
   - Acceptance screen displays inviting parent, family details
   - On acceptance: Add to `Family.sharedWithUserIDs`, grant CloudKit access

4. **CloudKit Sharing Integration**
   - `CKShare` record shares Family record with invitee
   - Read/write access granted to shared zone
   - Child zone access configured
   - CloudKit subscriptions created

5. **Error Handling**
   - Clear error messages for expired/invalid invitations
   - Network error handling with retry logic

6. **Security & Validation**
   - 72-hour token expiration
   - One-time use enforcement
   - Owner-only invitation privileges (v1.1)
   - Maximum 2 parents per family (v1.1)

**Dependencies:** v1.0 Family data model, CloudKit architecture, iCloud auth

---

### Story 6.2: Real-Time Synchronization

**As a parent, I want changes I make to sync in real-time to my co-parent's device, so that we always see consistent data.**

**Acceptance Criteria:**

1. **Parent Coordination Zone**
   - Dedicated CloudKit zone: `parent-coordination-{familyID}`
   - `ParentCoordinationEvent` record type stores change events

2. **CloudKit Subscriptions**
   - `CKQuerySubscription` for each parent device
   - Filters by family ID, excludes own changes
   - Silent push notifications enabled

3. **Push Notification Handling**
   - Background fetch retrieves coordination events
   - Local cache updated
   - UI updates via Combine publishers

4. **Change Detection & Publishing**
   - All mutations create coordination events
   - Events contain sufficient detail for transparency

5. **UI Real-Time Updates**
   - ViewModels subscribe to coordination service
   - Toast notifications for co-parent changes
   - Smooth transition animations

6. **Synchronization Guarantees**
   - <5 second latency target (NFR11)
   - Retry logic, offline queue
   - Idempotent event handling

7. **Performance Optimization**
   - Debouncing (300ms)
   - Batch operations
   - Efficient delta sync

**Dependencies:** Story 6.1, v1.0 Repository pattern

---

### Story 6.3: Activity Log & Co-Parent Visibility

**As a parent, I want to see which changes my co-parent made, so that I understand recent modifications.**

**Acceptance Criteria:**

1. **Activity Log UI**
   - "Recent Activity" section in Parent Dashboard
   - Last 50 events displayed
   - Event details: parent, action, timestamp, changes

2. **Activity Log Data Source**
   - Queries `ParentCoordinationEvent` records
   - Sorted by timestamp descending
   - Pagination with infinite scroll

3. **Event Type Formatting**
   - Settings changes: "Sarah updated conversion rate from 10 to 15 pts/min"
   - Categorization: "David categorized 'Duolingo' as Learning (20 pts/hr)"
   - Point adjustments: "Sarah added 50 bonus points to Alex"

4. **Co-Parent Indicator**
   - Header: "You & {co-parent-name}" with avatars
   - Online status indicator
   - Last active timestamp

5. **Change Detail Modal**
   - Tap event for full details
   - Before/after values
   - Optional parent notes

6. **Activity Notifications**
   - Optional toggle for co-parent change notifications
   - Batched to avoid spam

7. **Search & Filter**
   - Keyword search
   - Filter by event type, parent, child, date range

**Dependencies:** Story 6.2

---

### Story 6.4: Permissions & Access Control

**As a family owner, I want to control co-parent permissions, so that I can manage who can make changes.**

**Acceptance Criteria:**

1. **Permission Roles**
   - Owner (Full Access): Complete control
   - Co-Parent (Full Access): Modify settings/categorizations/points (v1.1)
   - Viewer (Read-Only): Planned for v1.2

2. **Permission Enforcement**
   - Repository methods check permissions
   - Unauthorized actions return errors
   - Granular permission checks

3. **UI Permission Indicators**
   - Role badges displayed
   - Owner-only controls hidden from co-parents

4. **Owner Transfer Documentation**
   - Future feature documented
   - Data model prepared (v1.2)

5. **Error Handling**
   - Clear unauthorized action alerts

6. **CloudKit Security**
   - Record permissions match role permissions

**Dependencies:** Story 6.1

---

### Story 6.5: Conflict Resolution & Concurrent Edits

**As the system, I need to handle simultaneous edits gracefully to maintain data integrity.**

**Acceptance Criteria:**

1. **Conflict Detection**
   - CloudKit `recordChangeTag` version tracking
   - Conflict when client version doesn't match server

2. **Resolution Strategies**
   - **Last-Write-Wins (Default):** Server timestamp wins
   - **Field-Level Merge:** Non-conflicting fields merged
   - **User Prompt:** Critical conflicts show resolution modal

3. **Conflict Points**
   - App categorization: LWW
   - Settings: Field-level merge or prompt
   - Point balance: Sum adjustments

4. **CloudKit Handler**
   - `CKError.serverRecordChanged` triggers resolution
   - Retry with resolved record

5. **Notifications**
   - Toast for auto-resolved conflicts
   - Activity log entry

6. **Optimistic UI**
   - Immediate local updates
   - Animated revert if server wins

7. **Race Prevention**
   - Debouncing (300ms)
   - Lock mechanism for points
   - Atomic operations

8. **Testing**
   - Simultaneous edits
   - Network partition scenarios
   - Rapid changes

**Dependencies:** Story 6.2

---

### Migration Path: v1.0 → v1.1

**Zero-Downtime Migration Strategy**

**Data Compatibility:**
- All v1.0 structures unchanged
- Additive CloudKit records only
- No breaking changes

**Migration Process:**
1. App update (automatic)
2. Opt-in to multi-parent (user-initiated invite)
3. Co-parent onboarding (invitation acceptance)

**Backward Compatibility:**
- v1.0 users continue unchanged
- v1.1 single-parent mode identical to v1.0
- Co-parent must update to accept invite

**Rollback Plan:**
- Remote config disable switch
- Emergency v1.1.1 release

---

### v1.1 Success Criteria

**Functional:**
- Two parents manage simultaneously
- <5 second sync
- Activity log shows all actions
- Zero data loss conflicts

**Performance:**
- Sync latency <5s (95th percentile)
- >95% auto-resolution
- >99% APNs delivery

**Adoption:**
- 40% add co-parent within 30 days
- Zero critical bugs
- <50% CloudKit quota

---

### v1.1 Timeline

| Week | Focus | Deliverables |
|------|-------|--------------|
| 1 | Stories 6.1 + 6.2 | Invitation + Sync |
| 2 | Story 6.5 | Conflict resolution |
| 3 | Stories 6.3 + 6.4 | Activity log + Permissions |
| 4 | Testing + Launch | Migration, App Store |

**Total:** 4 weeks post-v1.0

---

### Post-v1.1 Roadmap (v1.2)

**Future Enhancements:**
- Viewer role (read-only access)
- Change reversion
- Owner transfer
- In-app messaging
- CRDT-based conflict resolution

## Checklist Results Report

Before proceeding with development, the following checklist items should be reviewed:

1. ✅ Project goals and success metrics clearly defined
2. ✅ Target user segments identified and described
3. ✅ Core value proposition validated through competitive analysis
4. ✅ MVP scope appropriately constrained to essential features
5. ✅ Technical feasibility of iOS Screen Time API integration confirmed
6. ✅ COPPA compliance requirements understood and planned for
7. ✅ App Store approval risks identified and mitigation strategies developed
8. ✅ Development timeline and resource constraints documented
9. ✅ Key assumptions validated or research planned
10. ✅ Risk mitigation strategies developed for critical risks

## Next Steps

### v1.0 MVP Development

**Timeline:** 14 weeks
**Focus:** Epic 1-5, 7 (core functionality + monetization)

**Epic Execution Order:**
1. **Weeks 1-4:** Epic 1 (Foundation & Core Infrastructure)
2. **Weeks 5-7:** Epic 2 (Core Reward System)
3. **Weeks 8-9:** Epic 7 Core (Stories 7.1-7.3: StoreKit Integration, Trial, Purchase Flow)
4. **Weeks 10-12:** Epic 3 (User Experience & Interface)
5. **Week 13:** Epic 4 (Reporting & Analytics)
6. **Week 14:** Epic 5 (Validation & Testing) + Epic 7 Advanced (Stories 7.4-7.7)

**UX Expert Prompt (v1.0):**
Create detailed UI/UX designs for the reward-based screen time management app based on the PRD. Focus on creating distinct but cohesive experiences for parents and children, with an emphasis on gamification elements that reinforce the reward system. Ensure COPPA compliance in all design elements. Prioritize the following screens: Parent Dashboard (single-parent), Child Dashboard, App Categorization Screen, Reward Conversion Screen, Settings Screen, **Paywall Screen (14-day trial), Subscription Management Screen**. Design conversion-optimized paywall with clear value proposition and pricing tiers. Note: Multi-parent UI features deferred to v1.1.

**Architect Prompt (v1.0):**
Design the technical architecture for the reward-based screen time management app based on the PRD. Focus on iOS Family Controls framework integration (iOS 15.0+), CloudKit data synchronization with zone-based architecture, implementing the points-based reward system, **and StoreKit 2 subscription infrastructure**. Ensure COPPA compliance and prepare for App Store approval requirements. Address the following technical areas: iOS entitlements and Family Controls permissions, CloudKit schema and repository protocols, usage tracking via DeviceActivityMonitor, security measures for children's data, **StoreKit 2 integration for tiered subscriptions ($9.99/month base, +$3.99/child), server-side receipt validation, and feature gating logic**. Note: Prepare data models for multi-parent (v1.1) but implement single-parent functionality only.

### v1.1 Post-MVP Development

**Timeline:** 4 weeks (after v1.0 launch)
**Focus:** Epic 6 (multi-parent collaboration)

**Implementation Sequence:**
1. Week 1: Parent invitation system + Real-time sync infrastructure
2. Week 2: Conflict resolution mechanisms
3. Week 3: Activity log UI + Permissions system
4. Week 4: Testing, migration validation, App Store submission

**Key Deliverables:**
- Multi-parent invitation flow with deep linking
- Real-time CloudKit synchronization (<5 sec)
- Activity log with co-parent visibility
- Conflict resolution for concurrent edits
- Zero-downtime migration from v1.0

### v1.2 Future Roadmap

**Planned Enhancements:**
- Viewer role (read-only co-parent access)
- Change reversion capabilities
- Owner transfer functionality
- Enhanced in-app parent messaging
- CRDT-based conflict resolution