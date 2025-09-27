import Foundation
import SwiftUI

// MARK: - Navigation Destinations

enum ParentDashboardDestination: Hashable {
    case appCategorization
    case settings
    case detailedReports
    case addChild
    case childDetail(childID: String)
}

// MARK: - Navigation Coordinator

@MainActor
class ParentDashboardNavigationCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: ParentDashboardDestination?

    func navigate(to destination: ParentDashboardDestination) {
        navigationPath.append(destination)
    }

    func presentSheet(_ destination: ParentDashboardDestination) {
        presentedSheet = destination
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }

    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

// MARK: - Navigation Actions

struct ParentDashboardNavigationActions {
    let coordinator: ParentDashboardNavigationCoordinator

    func navigateToAppCategorization() {
        coordinator.navigate(to: .appCategorization)
    }

    func navigateToSettings() {
        coordinator.navigate(to: .settings)
    }

    func navigateToDetailedReports() {
        coordinator.navigate(to: .detailedReports)
    }

    func presentAddChild() {
        coordinator.presentSheet(.addChild)
    }

    func navigateToChildDetail(_ childID: String) {
        coordinator.navigate(to: .childDetail(childID: childID))
    }
}

// MARK: - Placeholder Views

struct AppCategorizationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("App Categorization")
                .font(.title2)
                .fontWeight(.bold)

            Text("This feature allows you to categorize apps as learning or reward apps for your children.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Coming Soon") {
                // TODO: Implement app categorization
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("App Categorization")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)

            Text("Manage your family settings, screen time limits, and app permissions.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Coming Soon") {
                // TODO: Implement settings
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DetailedReportsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Detailed Reports")
                .font(.title2)
                .fontWeight(.bold)

            Text("View comprehensive analytics and insights about your children's learning progress and app usage.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Coming Soon") {
                // TODO: Implement detailed reports
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Add Child")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Add a new child to your family to start tracking their learning progress and rewards.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Coming Soon") {
                    // TODO: Implement add child functionality
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ChildDetailView: View {
    let childID: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)

            Text("Child Details")
                .font(.title2)
                .fontWeight(.bold)

            Text("Detailed view for child: \(childID)")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Coming Soon") {
                // TODO: Implement child detail view
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Child Details")
        .navigationBarTitleDisplayMode(.large)
    }
}