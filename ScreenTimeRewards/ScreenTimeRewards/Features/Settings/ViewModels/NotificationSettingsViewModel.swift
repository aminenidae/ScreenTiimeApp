import SwiftUI
import SharedModels
import RewardCore

@MainActor
class NotificationSettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = true
    @Published var enabledNotifications: Set<NotificationEvent> = Set(NotificationEvent.allCases)
    @Published var quietHoursStart: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
    @Published var quietHoursEnd: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @Published var digestMode: Bool = false
    
    private let childProfileID: String
    private let notificationService: NotificationServiceProtocol
    
    init(childProfileID: String, notificationService: NotificationServiceProtocol = NotificationService()) {
        self.childProfileID = childProfileID
        self.notificationService = notificationService
    }
    
    func loadPreferences() {
        Task {
            do {
                let preferences = try await notificationService.getPreferences(for: childProfileID)
                await MainActor.run {
                    self.notificationsEnabled = preferences.notificationsEnabled
                    self.enabledNotifications = preferences.enabledNotifications
                    self.quietHoursStart = preferences.quietHoursStart ?? Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
                    self.quietHoursEnd = preferences.quietHoursEnd ?? Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
                    self.digestMode = preferences.digestMode
                }
            } catch {
                print("Error loading notification preferences: \(error)")
            }
        }
    }
    
    func savePreferences() {
        let preferences = NotificationPreferences(
            enabledNotifications: enabledNotifications,
            quietHoursStart: quietHoursStart,
            quietHoursEnd: quietHoursEnd,
            digestMode: digestMode,
            notificationsEnabled: notificationsEnabled
        )
        
        Task {
            do {
                try await notificationService.updatePreferences(preferences, for: childProfileID)
            } catch {
                print("Error saving notification preferences: \(error)")
            }
        }
    }
    
    // Computed properties for binding
    var quietHoursStartBinding: Binding<Date> {
        Binding(
            get: { self.quietHoursStart },
            set: { newValue in
                self.quietHoursStart = newValue
                self.savePreferences()
            }
        )
    }
    
    var quietHoursEndBinding: Binding<Date> {
        Binding(
            get: { self.quietHoursEnd },
            set: { newValue in
                self.quietHoursEnd = newValue
                self.savePreferences()
            }
        )
    }
    
    var digestModeBinding: Binding<Bool> {
        Binding(
            get: { self.digestMode },
            set: { newValue in
                self.digestMode = newValue
                self.savePreferences()
            }
        )
    }
    
    var notificationsEnabledBinding: Binding<Bool> {
        Binding(
            get: { self.notificationsEnabled },
            set: { newValue in
                self.notificationsEnabled = newValue
                self.savePreferences()
            }
        )
    }
}