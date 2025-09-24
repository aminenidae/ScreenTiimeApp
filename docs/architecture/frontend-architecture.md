# Frontend Architecture

## Component Architecture

The app uses SwiftUI's component-based architecture organized by feature modules:

### Component Organization
```
ScreenTimeRewards/
├── App/
│   ├── ScreenTimeRewardsApp.swift          # App entry point
│   └── AppCoordinator.swift                # Root navigation coordinator
├── Features/
│   ├── ParentDashboard/
│   │   ├── Views/
│   │   │   ├── ParentDashboardView.swift
│   │   │   ├── ChildProgressCardView.swift
│   │   │   └── QuickActionsView.swift
│   │   ├── ViewModels/
│   │   │   └── ParentDashboardViewModel.swift
│   │   └── Models/
│   │       └── DashboardState.swift
│   ├── ChildDashboard/
│   ├── AppCategorization/
│   ├── RewardRedemption/
│   ├── Subscription/
│   │   ├── Views/
│   │   │   ├── PaywallView.swift
│   │   │   ├── PlanSelectionView.swift
│   │   │   └── SubscriptionManagementView.swift
│   │   └── ViewModels/
│   │       └── SubscriptionViewModel.swift
│   └── Settings/
└── Common/
    ├── Extensions/
    └── Utilities/
```

### Component Template

```swift
// View
struct ChildDashboardView: View {
    @StateObject private var viewModel: ChildDashboardViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PointsHeaderView(points: viewModel.pointBalance)
                ProgressRingView(progress: viewModel.todayProgress)
                AvailableRewardsView(rewards: viewModel.availableRewards)
            }
            .padding()
        }
        .navigationTitle("My Dashboard")
        .task { await viewModel.loadDashboard() }
    }
}

// ViewModel
@MainActor
class ChildDashboardViewModel: ObservableObject {
    @Published var pointBalance: Int = 0
    @Published var todayProgress: Double = 0.0

    private let childRepository: ChildProfileRepository
    private var cancellables = Set<AnyCancellable>()

    func loadDashboard() async {
        childRepository.fetchChildProfile(id: currentChildID)
            .sink { [weak self] profile in
                self?.pointBalance = profile.pointBalance
            }
            .store(in: &cancellables)
    }
}
```

## State Management Architecture

### State Structure
- **Local State:** `@State` for view-specific UI state
- **Shared State:** `@StateObject` for ViewModels
- **Global State:** `@EnvironmentObject` for app-wide state (AppState)
- **Reactive Streams:** Combine publishers for CloudKit subscriptions

### State Management Patterns
- Single source of truth (ViewModels own published state)
- Unidirectional data flow (User actions → ViewModel → State → View)
- Combine publishers for reactive streams
- Dependency injection via initializers

## Routing Architecture

```swift
enum AppRoute: Hashable {
    case parentDashboard
    case childDashboard(childID: UUID)
    case appCategorization(childID: UUID)
    case rewardRedemption(childID: UUID)
    case settings
}

@MainActor
class AppCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()

    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }
}
```

## Frontend Services Layer

```swift
class RepositoryFactory {
    func makeFamilyRepository() -> FamilyRepository {
        CloudKitFamilyRepository(syncEngine: cloudKitService)
    }
}

class DashboardService {
    func fetchDashboardData(for childID: UUID) -> AnyPublisher<DashboardData, Error> {
        Publishers.Zip3(
            childRepository.fetchChildProfile(id: childID),
            sessionRepository.fetchSessionHistory(childID: childID),
            transactionRepository.fetchTransactionHistory(childID: childID)
        )
        .map { profile, sessions, transactions in
            DashboardData(profile: profile, sessions: sessions, transactions: transactions)
        }
        .eraseToAnyPublisher()
    }
}
```

---
