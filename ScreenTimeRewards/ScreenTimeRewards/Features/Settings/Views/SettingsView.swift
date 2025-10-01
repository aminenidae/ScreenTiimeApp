import SwiftUI
import SharedModels
import DesignSystem
import RewardCore
import SubscriptionService
import CloudKitService

// Legal documents
import ScreenTimeRewards


struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var familySharingViewModel = FamilySharingViewModel()
    @State private var notificationSettingsViewModel: NotificationSettingsViewModel?

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.settings == nil {
                    loadingView
                } else {
                    settingsContent
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshSettings()
            }
            .task {
                await viewModel.loadSettings()
                // Initialize notification settings view model when we have a child profile
                if let settings = viewModel.settings {
                    notificationSettingsViewModel = NotificationSettingsViewModel(childProfileID: settings.id)
                    // Load family sharing data
                    await familySharingViewModel.loadFamilyData(
                        familyID: settings.familyID,
                        currentUserID: "current-user-id" // TODO: Get from auth service
                    )
                }
            }
            .alert("Save Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    private var settingsContent: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Time Management Section
                timeManagementSection

                // Bedtime Controls Section
                bedtimeControlsSection

                // App Restrictions Section
                appRestrictionsSection

                // Family Sharing Section
                familySharingSection

                // Subscription Management Section
                subscriptionSection

                // Notification Settings Section
                if let notificationVM = notificationSettingsViewModel {
                    notificationSettingsSection(viewModel: notificationVM)
                }

                // Legal Section
                legalSection

                // Save Status Section
                saveStatusSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var timeManagementSection: some View {
        SettingsSection(title: "Time Management", icon: "clock.fill", iconColor: .blue) {
            VStack(spacing: 16) {
                DailyTimeLimitSetting(
                    dailyTimeLimit: Binding(
                        get: { viewModel.settings?.dailyTimeLimit ?? 120 },
                        set: { viewModel.updateDailyTimeLimit($0) }
                    )
                )
            }
        }
    }

    private var bedtimeControlsSection: some View {
        SettingsSection(title: "Bedtime Controls", icon: "moon.fill", iconColor: .purple) {
            VStack(spacing: 16) {
                BedtimeStartSetting(
                    bedtimeStart: Binding(
                        get: { viewModel.settings?.bedtimeStart },
                        set: { viewModel.updateBedtimeStart($0) }
                    )
                )

                BedtimeEndSetting(
                    bedtimeEnd: Binding(
                        get: { viewModel.settings?.bedtimeEnd },
                        set: { viewModel.updateBedtimeEnd($0) }
                    )
                )
            }
        }
    }

    private var appRestrictionsSection: some View {
        SettingsSection(title: "App Restrictions", icon: "apps.iphone", iconColor: .orange) {
            ContentRestrictionsView(
                contentRestrictions: Binding(
                    get: { viewModel.settings?.contentRestrictions ?? [:] },
                    set: { viewModel.updateContentRestrictions($0) }
                )
            )
        }
    }

    private var familySharingSection: some View {
        SettingsSection(title: "Family Sharing", icon: "person.2.fill", iconColor: .green) {
            FamilySharingSection(viewModel: familySharingViewModel)
        }
    }

    private func notificationSettingsSection(viewModel: NotificationSettingsViewModel) -> some View {
        SettingsSection(title: "Notifications", icon: "bell.fill", iconColor: .red) {
            NavigationLink(destination: NotificationSettingsView(viewModel: viewModel)) {
                HStack {
                    Text("Manage notification preferences")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var legalSection: some View {
        SettingsSection(title: "Legal", icon: "doc.fill", iconColor: .gray) {
            VStack(spacing: 16) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    HStack {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                NavigationLink(destination: TermsOfServiceView()) {
                    HStack {
                        Text("Terms of Service")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var saveStatusSection: some View {
        if viewModel.isSaving {
            HStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(0.8)

                Text("Saving changes...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        } else if viewModel.lastSaveTime != nil {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Text("Last saved: \(viewModel.lastSaveTimeFormatted)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }

    @available(iOS 15.0, *)
    private var subscriptionSection: some View {
        SettingsSection(title: "Subscription", icon: "crown.fill", iconColor: .purple) {
            NavigationLink(destination: SubscriptionDetailsView(familyID: viewModel.settings?.familyID)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manage Subscription")
                            .foregroundColor(.primary)
                            .font(.body)

                        Text("View billing, change plans, or cancel")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading settings...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Settings Section Container

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content

    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }

            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title) settings section")
    }
}

#Preview {
    SettingsView()
}

#Preview("With Mock Data") {
    let mockView = SettingsView()
    // TODO: Add mock data when ViewModel is implemented
    return mockView
}