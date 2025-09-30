import SwiftUI
import SharedModels

/// View for displaying conflict notifications
struct ConflictNotificationView: View {
    let conflict: ConflictMetadata
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Conflict Detected")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Multiple parents edited the same \(conflict.recordType) simultaneously")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button("Resolve") {
                onTap()
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    let sampleConflict = ConflictMetadata(
        familyID: "sample-family",
        recordType: "ChildProfile",
        recordID: "sample-record",
        conflictingChanges: [
            ConflictChange(
                userID: "parent1",
                changeType: .update,
                fieldChanges: [
                    FieldChange(fieldName: "name", oldValue: "John", newValue: "Johnny")
                ],
                timestamp: Date(),
                deviceInfo: "iPhone"
            )
        ],
        resolutionStrategy: .manualSelection
    )
    
    return ConflictNotificationView(conflict: sampleConflict) {
        print("Resolve tapped")
    }
}