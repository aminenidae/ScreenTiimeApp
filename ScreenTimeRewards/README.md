# Screen Time Rewards

A comprehensive iOS application that transforms screen time management into a positive, gamified experience for families. Built with SwiftUI and leveraging Apple's Family Controls framework.

## Overview

Screen Time Rewards helps parents create a positive relationship between their children and technology by rewarding productive screen time activities. Children earn points for educational app usage, reading, and creative activities, which can be redeemed for rewards set by parents.

## Features

### 🎯 Core Functionality
- **Smart Screen Time Tracking** - Automatic monitoring of app usage across categories
- **Point-Based Rewards System** - Earn points for productive activities
- **Family Management** - Parent supervision with child profiles
- **Achievement System** - Unlock badges and milestones
- **Real-time Dashboard** - Track progress and statistics

### 📱 Technical Features
- **Native iOS Design** - Built with SwiftUI for iOS 15.0+
- **CloudKit Integration** - Seamless family data sync
- **Family Controls** - Leverages Apple's Screen Time APIs
- **Offline Support** - Works without internet connectivity
- **Privacy First** - All data stays within the family iCloud

## Requirements

### System Requirements
- iOS 15.0 or later
- Xcode 15.0 or later
- Swift 5.9+
- iCloud account with Family Sharing enabled

### Development Requirements
- Apple Developer Account (for Family Controls entitlement)
- TestFlight for testing screen time functionality
- macOS Ventura or later for development

## Project Structure

```
ScreenTimeRewards/
├── ScreenTimeRewards/           # Main iOS app
│   ├── App/                     # App lifecycle and coordination
│   ├── Features/                # Feature modules
│   └── Resources/               # Assets and configuration
├── WidgetExtension/             # Home screen widgets
├── AppIntentsExtension/         # Siri shortcuts
├── Packages/                    # Local Swift packages
│   ├── SharedModels/           # Data models and types
│   ├── DesignSystem/           # UI components and design tokens
│   ├── RewardCore/             # Business logic
│   ├── CloudKitService/        # Data persistence
│   ├── FamilyControlsKit/      # Screen time monitoring
│   ├── SubscriptionService/    # In-app purchases
│   └── AppIntents/            # Voice commands
├── Tests/                      # Test suites
├── Scripts/                    # Build and deployment scripts
├── Docs/                       # Project documentation
└── Package.swift              # Workspace configuration
```

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ScreenTimeRewards
```

### 2. Open in Xcode

```bash
open ScreenTimeRewards.xcworkspace
```

If workspace doesn't exist, open the Package.swift file:

```bash
open Package.swift
```

### 3. Configure Bundle Identifier

1. Open project settings in Xcode
2. Update bundle identifier from `com.yourcompany.screentimerewards` to your domain
3. Configure your development team
4. Update iCloud container identifiers in entitlements

### 4. Set Up CloudKit

1. Enable CloudKit in your Apple Developer Console
2. Create CloudKit container: `iCloud.{your-bundle-id}`
3. Update container identifier in `CloudKitService.swift`
4. Configure CloudKit schema (will be auto-generated)

### 5. Request Family Controls Entitlement

Family Controls requires special approval from Apple:

1. Go to Apple Developer Console
2. Navigate to Certificates, Identifiers & Profiles
3. Request Family Controls entitlement for your app
4. Provide justification for screen time access

### 6. Build and Run

```bash
# Build the project
⌘+B

# Run on simulator (limited functionality)
⌘+R

# For full testing, deploy to physical device via TestFlight
```

## Package Architecture

### SharedModels
Core data types shared across all packages:
- `ChildProfile` - Child user data
- `Reward` - Redeemable rewards
- `ScreenTimeSession` - App usage records
- `AppCategory` - Application categorization

### DesignSystem
Comprehensive UI toolkit:
- **Tokens** - Colors, typography, spacing
- **Components** - Buttons, cards, progress rings
- **Modifiers** - Consistent styling utilities
- **Gamification** - Points displays, achievement badges

### RewardCore
Business logic and algorithms:
- Point tracking engine implementation
- Point calculation engine with category-based point values
- Usage session processing and persistence
- Background tracking capability
- Edge case handling for app switching and device sleep/wake cycles
- Integration with DeviceActivityMonitor for accurate time tracking
- Data persistence with CloudKit synchronization
- Comprehensive unit testing suite

Key Components:
- **PointTrackingService**: Central coordinator for tracking time spent in educational apps
- **PointCalculationEngine**: Calculates points based on parent-defined values and app categories
- **UsageSessionRepository**: Manages persistence of usage session data
- **PointTransactionRepository**: Manages persistence of point transaction records

### CloudKitService
Data persistence layer:
- Protocol-based repositories
- CloudKit integration
- Offline synchronization
- Error handling

### FamilyControlsKit
Screen time monitoring:
- App usage tracking
- Time limit enforcement
- App categorization
- Device activity monitoring

## Development Workflow

### 1. Package Development
Each package is independently testable:

```bash
# Test specific package
cd Packages/DesignSystem
swift test

# Test all packages
swift test
```

### 2. Code Style
- Follow Swift API Design Guidelines
- Use dependency injection for testability
- Implement protocol-based architecture
- Write comprehensive unit tests

### 3. Testing Strategy
- **Unit Tests** - 70% coverage target
- **Integration Tests** - Package interaction
- **UI Tests** - Critical user flows
- **Manual Testing** - Screen time functionality

## Deployment

### TestFlight Deployment
Family Controls functionality requires physical device testing:

1. Archive the app in Xcode
2. Upload to App Store Connect
3. Create TestFlight build
4. Invite family members for testing
5. Test all screen time features

### App Store Submission
1. Complete App Store Connect metadata
2. Include privacy policy (required for Family Controls)
3. Provide detailed app review notes
4. Submit for review with entitlement justification

## Configuration Files

### Important Configuration
- `Info.plist` - App metadata and permissions
- `ScreenTimeRewards.entitlements` - Required entitlements
- `Package.swift` - Workspace dependencies
- `core-config.yaml` - BMad development configuration

### Bundle Identifiers
- Main App: `com.yourcompany.screentimerewards`
- Widget Extension: `com.yourcompany.screentimerewards.widget`
- App Intents: `com.yourcompany.screentimerewards.intents`

## Privacy and Security

### Data Handling
- All data stored in family's private iCloud
- No third-party analytics or tracking
- COPPA compliant for children under 13
- Transparent data usage policies

### Permissions Required
- **Family Controls** - Screen time monitoring
- **iCloud** - Data synchronization
- **Background App Refresh** - Data updates

## Troubleshooting

### Common Issues

**Family Controls Authorization Fails**
- Ensure proper entitlement is configured
- Test on physical device, not simulator
- Verify Apple Developer Account has entitlement approval

**CloudKit Sync Issues**
- Check iCloud account status
- Verify container identifier matches
- Test with different iCloud accounts

**Build Failures**
- Clean build folder (⌘+Shift+K)
- Reset package cache: `File > Packages > Reset Package Caches`
- Update to latest Xcode version

### Debug Logging
Enable debug logging in development:

```swift
// In AppDelegate or App.swift
#if DEBUG
DesignSystem.Debug.enableDebugMode()
#endif
```

## Contributing

### Development Setup
1. Follow getting started instructions
2. Install SwiftFormat and SwiftLint
3. Run tests before submitting PRs
4. Follow conventional commit messages

### Code Review Process
1. Create feature branch
2. Implement changes with tests
3. Submit pull request
4. Address review feedback
5. Merge after approval

## License

[Your chosen license - e.g., MIT, Apache 2.0, etc.]

## Support

For technical support or questions:
- Create GitHub issue for bugs
- Check documentation in `Docs/` folder
- Review Apple's Family Controls documentation

---

**Note**: This project is currently in development phase. Some features may be placeholder implementations that require completion before production deployment.
