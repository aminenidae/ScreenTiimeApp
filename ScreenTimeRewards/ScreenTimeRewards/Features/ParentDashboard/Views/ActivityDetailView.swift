import SwiftUI
import SharedModels
import DesignSystem

struct ActivityDetailView: View {
    let activity: ParentActivity
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    headerSection

                    // Details Section
                    detailsSection

                    // Changes Section
                    if !activity.changes.dictionary.isEmpty {
                        changesSection
                    }

                    // Additional Info Section
                    additionalInfoSection

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Activity Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Activity Icon
                Image(systemName: activity.activityType.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.activityType.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(formatTimestamp(activity.timestamp))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Description
            Text(activity.detailedDescription)
                .font(.body)
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                DetailRow(label: "Triggered By", value: parentName(for: activity.triggeringUserID))
                DetailRow(label: "Target Entity", value: activity.targetEntity)
                DetailRow(label: "Time", value: formatFullTimestamp(activity.timestamp))

                if let deviceID = activity.deviceID {
                    DetailRow(label: "Device", value: deviceName(for: deviceID))
                }
            }
        }
    }

    private var changesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Changes Made")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ForEach(Array(activity.changes.dictionary.keys.sorted()), id: \.self) { key in
                    if let value = activity.changes.dictionary[key] {
                        ChangeRow(key: key, value: value, activityType: activity.activityType)
                    }
                }
            }
        }
    }

    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Information")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                DetailRow(label: "Activity ID", value: activity.id.uuidString)
                DetailRow(label: "Family ID", value: activity.familyID.uuidString)
                DetailRow(label: "Entity ID", value: activity.targetEntityID.uuidString)

                // Navigation to related entity (if applicable)
                if shouldShowNavigateButton {
                    navigateToEntityButton
                }
            }
        }
    }

    private var navigateToEntityButton: some View {
        Button(action: {
            // Navigate to related entity
            navigateToRelatedEntity()
        }) {
            HStack {
                Image(systemName: "arrow.forward.circle.fill")
                Text("View \(activity.targetEntity)")
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
            .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
    }

    private var shouldShowNavigateButton: Bool {
        switch activity.activityType {
        case .childProfileModified, .childAdded:
            return true
        case .appCategorizationAdded, .appCategorizationModified, .appCategorizationRemoved:
            return true
        case .settingsUpdated:
            return true
        default:
            return false
        }
    }

    // MARK: - Helper Methods

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func formatFullTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func parentName(for userID: String) -> String {
        // TODO: Implement actual parent name lookup
        return "Co-Parent"
    }

    private func deviceName(for deviceID: String) -> String {
        // TODO: Implement actual device name lookup
        return "iPhone"
    }

    private func navigateToRelatedEntity() {
        // TODO: Implement navigation to related entity
        print("Navigate to \(activity.targetEntity) with ID: \(activity.targetEntityID)")
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(minWidth: 80, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

struct ChangeRow: View {
    let key: String
    let value: String
    let activityType: ParentActivityType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedKey)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            HStack {
                if isBeforeAfterChange {
                    beforeAfterView
                } else {
                    Text(value)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
    }

    private var formattedKey: String {
        switch key {
        case "appName": return "App Name"
        case "category": return "Category"
        case "oldCategory": return "Previous Category"
        case "newCategory": return "New Category"
        case "childName": return "Child"
        case "pointsChange": return "Points Change"
        case "reason": return "Reason"
        case "rewardName": return "Reward"
        case "pointsSpent": return "Points Spent"
        case "modifications": return "Modifications"
        case "settingsType": return "Settings Type"
        default: return key.capitalized
        }
    }

    private var isBeforeAfterChange: Bool {
        return activityType == .appCategorizationModified &&
               (key == "oldCategory" || key == "newCategory")
    }

    private var beforeAfterView: some View {
        HStack(spacing: 16) {
            if key == "oldCategory" {
                VStack(alignment: .leading, spacing: 4) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body)
                        .foregroundColor(.red)
                        .strikethrough()
                }
            } else if key == "newCategory" {
                VStack(alignment: .leading, spacing: 4) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

#Preview {
    let sampleActivity = ParentActivity(
        familyID: UUID(),
        triggeringUserID: "parent1",
        activityType: .appCategorizationModified,
        targetEntity: "AppCategorization",
        targetEntityID: UUID(),
        changes: CodableDictionary([
            "appName": "Khan Academy",
            "oldCategory": "Reward",
            "newCategory": "Learning",
            "childName": "Emma"
        ]),
        timestamp: Date().addingTimeInterval(-3600)
    )

    return ActivityDetailView(activity: sampleActivity)
}

#Preview("Points Adjustment") {
    let sampleActivity = ParentActivity(
        familyID: UUID(),
        triggeringUserID: "parent2",
        activityType: .pointsAdjusted,
        targetEntity: "ChildProfile",
        targetEntityID: UUID(),
        changes: CodableDictionary([
            "childName": "Alex",
            "pointsChange": "+100",
            "reason": "Completed weekly reading goal"
        ]),
        timestamp: Date().addingTimeInterval(-1800)
    )

    return ActivityDetailView(activity: sampleActivity)
}