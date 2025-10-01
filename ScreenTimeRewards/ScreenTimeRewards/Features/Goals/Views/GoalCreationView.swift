import SwiftUI
import SharedModels

struct GoalCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedGoalType: GoalTypeOption = .timeBased
    @State private var timeValue = 1
    @State private var pointsValue = 100
    @State private var appBundleID = ""
    @State private var streakDays = 7
    @State private var isRecurring = false
    @State private var selectedFrequency: GoalFrequencyOption = .weekly
    
    let onSave: (EducationalGoal) -> Void
    let childProfileID: String
    
    init(childProfileID: String = "default", onSave: @escaping (EducationalGoal) -> Void) {
        self.childProfileID = childProfileID
        self.onSave = onSave
    }
    
    enum GoalTypeOption: String, CaseIterable {
        case timeBased = "Time Based"
        case pointBased = "Point Based"
        case appSpecific = "App Specific"
        case streak = "Streak"
    }
    
    enum GoalFrequencyOption: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case custom = "Custom"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Goal Type") {
                    Picker("Type", selection: $selectedGoalType) {
                        ForEach(GoalTypeOption.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedGoalType {
                    case .timeBased:
                        Stepper("Hours: \(timeValue)", value: $timeValue, in: 1...100)
                    case .pointBased:
                        Stepper("Points: \(pointsValue)", value: $pointsValue, in: 10...1000, step: 10)
                    case .appSpecific:
                        TextField("App Bundle ID", text: $appBundleID)
                        Stepper("Hours: \(timeValue)", value: $timeValue, in: 1...100)
                    case .streak:
                        Stepper("Days: \(streakDays)", value: $streakDays, in: 1...365)
                    }
                }
                
                Section("Frequency") {
                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(GoalFrequencyOption.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Recurring", isOn: $isRecurring)
                }
            }
            .navigationTitle("Create Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty
    }
    
    private func saveGoal() {
        let goalType: GoalType
        let targetValue: Double
        
        switch selectedGoalType {
        case .timeBased:
            goalType = .timeBased(hours: timeValue)
            targetValue = Double(timeValue * 60) // Convert hours to minutes
        case .pointBased:
            goalType = .pointBased(points: pointsValue)
            targetValue = Double(pointsValue)
        case .appSpecific:
            goalType = .appSpecific(bundleID: appBundleID, hours: timeValue)
            targetValue = Double(timeValue * 60) // Convert hours to minutes
        case .streak:
            goalType = .streak(days: streakDays)
            targetValue = Double(streakDays)
        }
        
        let frequency: GoalFrequency = {
            let now = Date()
            let calendar = Calendar.current
            
            switch selectedFrequency {
            case .daily:
                let start = calendar.startOfDay(for: now)
                let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
                return .custom(startDate: start, endDate: end)
            case .weekly:
                let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? now
                return .custom(startDate: start, endDate: end)
            case .monthly:
                let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
                let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
                return .custom(startDate: start, endDate: end)
            case .custom:
                // For custom, we'll use a week as default but this would be set by user in a real app
                let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? now
                return .custom(startDate: start, endDate: end)
            }
        }()
        
        let now = Date()
        let goal = EducationalGoal(
            childProfileID: childProfileID,
            title: title,
            description: description,
            type: goalType,
            frequency: frequency,
            targetValue: targetValue,
            currentValue: 0.0,
            startDate: now,
            endDate: frequency.endDate,
            status: .notStarted,
            isRecurring: isRecurring,
            metadata: GoalMetadata(
                createdBy: "parent", // This would be the actual parent ID in a real app
                lastModifiedBy: "parent"
            )
        )
        
        onSave(goal)
        dismiss()
    }
}

// MARK: - Extension for GoalFrequency

extension GoalFrequency {
    var endDate: Date {
        switch self {
        case .daily:
            return Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        case .weekly:
            return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        case .monthly:
            return Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        case .custom(let startDate, let endDate):
            return endDate
        }
    }
}

// MARK: - Preview

struct GoalCreationView_Previews: PreviewProvider {
    static var previews: some View {
        GoalCreationView { _ in }
            .previewLayout(.sizeThatFits)
    }
}