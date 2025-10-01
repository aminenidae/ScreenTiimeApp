# Screen Time Rewards

Screen Time Rewards helps parents create a positive relationship between their children and technology by rewarding productive screen time activities. Children earn points for educational app usage, reading, and creative activities, which can be redeemed for rewards set by parents.

With real-time dashboards and achievement systems, families can track progress and celebrate milestones together.

## Key Features
- **Smart Screen Time Tracking** - Automatic monitoring of app usage across categories
- **Point-Based Rewards System** - Earn points for productive activities
- **Family Management** - Parent supervision with child profiles
- **Achievement System** - Unlock badges and milestones
- **Real-time Dashboard** - Track progress and statistics
- **Error Handling & Recovery** - Graceful error handling and data recovery mechanisms
- **Privacy First** - All data stays within the family iCloud

## Technology Stack
- **Frontend Language:** Swift 5.9+
- **Frontend Framework:** SwiftUI (iOS 15.0+) - Declarative UI framework
- **State Management:** Combine + SwiftUI @Published - Native to SwiftUI, seamless integration with CloudKit publishers
- **Backend Framework:** CloudKit Framework (iOS 15.0+) - Serverless backend
- **Database:** CloudKit (Primary) + CoreData (Cache)
- **Screen Time Integration:** Family Controls Framework (iOS 15.0+) - Managed Settings Store for reward enforcement
- **Frontend Testing:** XCTest + SwiftUI Previews (Xcode 15.0+) - Unit and UI testing

## Project Structure
```
ScreenTimeRewards/
├── ScreenTimeRewards/                      # Main iOS app
│   ├── App/
│   ├── Features/
│   │   ├── ParentDashboard/
│   │   ├── ChildDashboard/                 # ✅ COMPLETE - Child dashboard with points and rewards
│   │   ├── AppCategorization/
│   │   ├── PointTracking/
│   │   ├── RewardRedemption/
│   │   └── Settings/
│   └── Resources/
├── Packages/                               # Local Swift packages
│   ├── RewardCore/                         # Business logic
│   ├── CloudKitService/
│   ├── FamilyControlsKit/
│   ├── SubscriptionService/
│   ├── DesignSystem/
│   ├── SharedModels/
│   └── AppIntents/
├── Tests/                                  # Test suite
│   ├── Unit Tests/
│   ├── Integration Tests/
│   └── Validation Tests/
└── Documentation/                          # Project documentation
```

## Implemented Features

### ✅ Story 3.2: Child Dashboard UI Implementation
- Child dashboard with progress ring showing daily point goal completion
- Points balance prominently displayed with large, colorful numbers
- Reward cards showing available rewards with point costs and visual previews
- Visual feedback animations when points are earned (floating "+5" notifications)
- Interface with large touch targets and simple navigation suitable for children ages 6-12
- Dashboard updates in real-time when points are earned or rewards are redeemed

### 🔄 Story 5.3: Error Handling and Recovery Implementation (In Progress)
- Comprehensive error handling for all critical functions
- Data recovery mechanisms to protect against data loss
- User-friendly error messages to guide users through issues
- Logging systems to help diagnose and resolve problems

### 📱 Core Components
- **ProgressRingView**: Circular progress indicator showing daily goal completion with animated filling
- **PointsBalanceView**: Large numeric display of current points with animation
- **FloatingPointsNotificationView**: Animated view that floats up when points are earned
- **RewardCardView**: Card component showing available rewards with point costs
- **ChildDashboardView**: Main dashboard view integrating all components
- **ChildDashboardViewModel**: Data loading and state management

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ device or simulator
- Apple ID for CloudKit testing

### Installation
1. Clone the repository
2. Open `ScreenTimeRewards.xcodeproj` in Xcode
3. Select your development team in the project settings
4. Build and run the project

### Testing
Run unit tests using Xcode's test navigator or command line:
```bash
swift test
```

## Documentation
- [Architecture](Docs/Architecture.md)
- [Development Guidelines](Docs/DevelopmentGuidelines.md)
- [Testing Strategy](Docs/TestingStrategy.md)

## Contributing
Please read [CONTRIBUTING.md](Docs/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- Thanks to Apple's Family Controls framework for enabling screen time management
- Inspired by positive reinforcement techniques in child development research
