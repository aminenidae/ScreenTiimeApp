import SwiftUI
import Combine
import SharedModels

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: FamilySettings?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var lastSaveTime: Date?

    private var familySettingsRepository: FamilySettingsRepository?
    private var cancellables = Set<AnyCancellable>()
    private let debounceTime: TimeInterval = 1.0
    private var pendingChanges = false

    // Default values
    private let defaultDailyTimeLimit = 120 // 2 hours
    private let defaultBedtimeStart = Calendar.current.date(from: DateComponents(hour: 20, minute: 0))!
    private let defaultBedtimeEnd = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!

    var lastSaveTimeFormatted: String {
        guard let lastSaveTime = lastSaveTime else { return "Never" }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        let now = Date()
        let timeDifference = now.timeIntervalSince(lastSaveTime)

        if timeDifference < 60 {
            return "Just now"
        } else if timeDifference < 3600 {
            let minutes = Int(timeDifference / 60)
            return "\(minutes)m ago"
        } else {
            return formatter.string(from: lastSaveTime)
        }
    }

    init(familySettingsRepository: FamilySettingsRepository? = nil) {
        self.familySettingsRepository = familySettingsRepository

        // Set up debounced saving
        setupDebouncedSaving()
    }

    func loadSettings() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // TODO: Get current family ID from auth service
            let familyID = "mock-family-id"

            if let repository = familySettingsRepository {
                let loadedSettings = try await repository.fetchSettings(for: familyID)

                if let loadedSettings = loadedSettings {
                    settings = loadedSettings
                } else {
                    // Create default settings for new families
                    let defaultSettings = FamilySettings(
                        id: UUID().uuidString,
                        familyID: familyID,
                        dailyTimeLimit: defaultDailyTimeLimit,
                        bedtimeStart: nil, // Start disabled
                        bedtimeEnd: nil,   // Start disabled
                        contentRestrictions: [:]
                    )

                    settings = try await repository.createSettings(defaultSettings)
                }
            } else {
                // Mock data for preview/testing
                settings = FamilySettings(
                    id: "mock-settings-id",
                    familyID: familyID,
                    dailyTimeLimit: defaultDailyTimeLimit,
                    bedtimeStart: nil,
                    bedtimeEnd: nil,
                    contentRestrictions: [:]
                )
            }
        } catch {
            showError(message: "Failed to load settings: \(error.localizedDescription)")
        }
    }

    func refreshSettings() async {
        await loadSettings()
    }

    // MARK: - Settings Updates

    func updateDailyTimeLimit(_ newLimit: Int) {
        guard var currentSettings = settings else { return }

        let validatedLimit = max(0, min(480, newLimit)) // Validate range
        currentSettings.dailyTimeLimit = validatedLimit == 0 ? nil : validatedLimit

        settings = currentSettings
        scheduleAutosave()
    }

    func updateBedtimeStart(_ newStart: Date?) {
        guard var currentSettings = settings else { return }

        currentSettings.bedtimeStart = newStart
        settings = currentSettings
        scheduleAutosave()
    }

    func updateBedtimeEnd(_ newEnd: Date?) {
        guard var currentSettings = settings else { return }

        currentSettings.bedtimeEnd = newEnd
        settings = currentSettings
        scheduleAutosave()
    }

    func updateContentRestrictions(_ newRestrictions: [String: Bool]) {
        guard var currentSettings = settings else { return }

        currentSettings.contentRestrictions = newRestrictions
        settings = currentSettings
        scheduleAutosave()
    }

    // MARK: - Validation

    private func validateSettings(_ settings: FamilySettings) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []

        // Validate daily time limit
        if let dailyLimit = settings.dailyTimeLimit {
            if dailyLimit < 0 || dailyLimit > 480 {
                errors.append("Daily time limit must be between 0 and 480 minutes (8 hours)")
            }
        }

        // Validate bedtime range
        if let bedtimeStart = settings.bedtimeStart,
           let bedtimeEnd = settings.bedtimeEnd {

            // Convert to time components for comparison
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.hour, .minute], from: bedtimeStart)
            let endComponents = calendar.dateComponents([.hour, .minute], from: bedtimeEnd)

            let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
            let endMinutes = (endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0)

            // Handle overnight bedtime (e.g., 8 PM to 7 AM)
            // If end time is earlier than start time, it's overnight
            if endMinutes <= startMinutes {
                // This is valid for overnight bedtime (e.g., 20:00 to 07:00)
                // No error needed
            }
        }

        return (errors.isEmpty, errors)
    }

    // MARK: - Autosave

    private func setupDebouncedSaving() {
        // Create a publisher that emits when settings change
        $settings
            .compactMap { $0 }
            .removeDuplicates(by: { oldSettings, newSettings in
                // Compare all relevant fields
                return oldSettings.dailyTimeLimit == newSettings.dailyTimeLimit &&
                       oldSettings.bedtimeStart == newSettings.bedtimeStart &&
                       oldSettings.bedtimeEnd == newSettings.bedtimeEnd &&
                       oldSettings.contentRestrictions == newSettings.contentRestrictions
            })
            .debounce(for: .seconds(debounceTime), scheduler: DispatchQueue.main)
            .sink { [weak self] settings in
                Task { @MainActor in
                    await self?.saveSettings(settings)
                }
            }
            .store(in: &cancellables)
    }

    private func scheduleAutosave() {
        pendingChanges = true
    }

    private func saveSettings(_ settingsToSave: FamilySettings) async {
        guard let repository = familySettingsRepository else {
            // Mock successful save for preview/testing
            lastSaveTime = Date()
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            // Validate before saving
            let validation = validateSettings(settingsToSave)
            if !validation.isValid {
                showError(message: "Invalid settings: \(validation.errors.joined(separator: ", "))")
                return
            }

            let updatedSettings = try await repository.updateSettings(settingsToSave)
            settings = updatedSettings
            lastSaveTime = Date()
            pendingChanges = false
        } catch {
            showError(message: "Failed to save settings: \(error.localizedDescription)")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Mock Data

extension SettingsViewModel {
    static func mockViewModel() -> SettingsViewModel {
        let viewModel = SettingsViewModel()
        viewModel.settings = FamilySettings(
            id: "mock-settings-id",
            familyID: "mock-family-id",
            dailyTimeLimit: 120,
            bedtimeStart: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)),
            bedtimeEnd: Calendar.current.date(from: DateComponents(hour: 7, minute: 0)),
            contentRestrictions: [
                "com.apple.mobilesafari": true,
                "com.apple.mobilemail": false,
                "com.apple.Music": true
            ]
        )
        viewModel.lastSaveTime = Date().addingTimeInterval(-300) // 5 minutes ago
        return viewModel
    }
}