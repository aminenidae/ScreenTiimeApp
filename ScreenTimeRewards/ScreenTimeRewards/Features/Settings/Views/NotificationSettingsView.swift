import SwiftUI
import SharedModels
import DesignSystem

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: NotificationSettingsViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Master toggle for all notifications
            masterNotificationToggle
            
            if viewModel.notificationsEnabled {
                // Notification types section
                notificationTypesSection
                
                // Quiet hours section
                quietHoursSection
                
                // Digest mode section
                digestModeSection
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.loadPreferences()
        }
    }
    
    private var masterNotificationToggle: some View {
        HStack {
            Image(systemName: "bell.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text("Notifications")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Toggle("", isOn: $viewModel.notificationsEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var notificationTypesSection: some View {
        SettingsSection(title: "Notification Types", icon: "list.bullet", iconColor: .green) {
            VStack(spacing: 16) {
                ForEach(NotificationEvent.allCases, id: \.self) { event in
                    notificationTypeToggle(for: event)
                }
            }
        }
    }
    
    private func notificationTypeToggle(for event: NotificationEvent) -> some View {
        HStack {
            Text(title(for: event))
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { viewModel.enabledNotifications.contains(event) },
                set: { isOn in
                    if isOn {
                        viewModel.enabledNotifications.insert(event)
                    } else {
                        viewModel.enabledNotifications.remove(event)
                    }
                    viewModel.savePreferences()
                }
            ))
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
    
    private var quietHoursSection: some View {
        SettingsSection(title: "Quiet Hours", icon: "moon.fill", iconColor: .purple) {
            VStack(spacing: 16) {
                HStack {
                    Text("Start Time")
                        .font(.body)
                    
                    Spacer()
                    
                    DatePicker("", selection: $viewModel.quietHoursStart, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                HStack {
                    Text("End Time")
                        .font(.body)
                    
                    Spacer()
                    
                    DatePicker("", selection: $viewModel.quietHoursEnd, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
        }
    }
    
    private var digestModeSection: some View {
        SettingsSection(title: "Notification Style", icon: "tray.full.fill", iconColor: .orange) {
            VStack(spacing: 16) {
                Toggle("Daily Digest", isOn: $viewModel.digestMode)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                if viewModel.digestMode {
                    Text("Receive a daily summary instead of real-time notifications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Receive real-time notifications as events happen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
    
    private func title(for event: NotificationEvent) -> String {
        switch event {
        case .pointsEarned:
            return "Points Earned"
        case .goalAchieved:
            return "Goal Achieved"
        case .weeklyMilestone:
            return "Weekly Milestone"
        case .streakAchieved:
            return "Streak Achieved"
        }
    }
}

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
                    .font(.title3)
                    .fontWeight(.semibold)
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
    }
}

#Preview {
    let viewModel = NotificationSettingsViewModel(childProfileID: "test-child-id")
    return NotificationSettingsView(viewModel: viewModel)
}