import SwiftUI
import Combine

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentTab: AppTab = .dashboard
    @Published var isOnboardingCompleted: Bool = false

    enum AppTab: CaseIterable {
        case dashboard
        case rewards
        case settings

        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .rewards: return "Rewards"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .dashboard: return "chart.bar.fill"
            case .rewards: return "gift.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    init() {
        // Initialize with default state
        checkOnboardingStatus()
    }

    private func checkOnboardingStatus() {
        // TODO: Check UserDefaults for onboarding completion
        isOnboardingCompleted = true
    }

    func showTab(_ tab: AppTab) {
        currentTab = tab
    }
}