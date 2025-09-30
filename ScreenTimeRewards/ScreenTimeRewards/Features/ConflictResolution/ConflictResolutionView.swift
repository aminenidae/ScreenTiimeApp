import SwiftUI
import SharedModels

/// View for resolving conflicts manually
struct ConflictResolutionView: View {
    @StateObject private var viewModel: ConflictResolutionViewModel
    private let conflict: ConflictMetadata
    private let onResolution: (ConflictMetadata) -> Void
    
    init(
        conflict: ConflictMetadata,
        conflictResolver: ConflictResolver,
        onResolution: @escaping (ConflictMetadata) -> Void
    ) {
        self.conflict = conflict
        self.onResolution = onResolution
        self._viewModel = StateObject(wrappedValue: ConflictResolutionViewModel(
            conflict: conflict,
            conflictResolver: conflictResolver
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                headerView
                conflictDetailsView
                resolutionOptionsView
                actionButtonsView
            }
            .padding()
            .navigationTitle("Conflict Resolution")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Conflict Detected")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Multiple parents made changes to the same \(conflict.recordType) at the same time.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var conflictDetailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conflicting Changes")
                .font(.headline)
            
            ForEach(conflict.conflictingChanges.indices, id: \.self) { index in
                let change = conflict.conflictingChanges[index]
                ConflictChangeView(change: change)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var resolutionOptionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resolution Options")
                .font(.headline)
            
            Picker("Select Resolution", selection: $viewModel.selectedResolutionIndex) {
                ForEach(0..<conflict.conflictingChanges.count, id: \.self) { index in
                    let change = conflict.conflictingChanges[index]
                    Text("Use \(change.userID)'s Changes")
                        .tag(index)
                }
                
                Text("Merge Non-conflicting Changes")
                    .tag(-1)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var actionButtonsView: some View {
        HStack {
            Button("Cancel") {
                // Dismiss without resolving
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Button("Apply Resolution") {
                viewModel.applyResolution { resolvedConflict in
                    onResolution(resolvedConflict)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

/// View for displaying individual conflict changes
struct ConflictChangeView: View {
    let change: ConflictChange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(change.userID)
                    .font(.headline)
                Spacer()
                Text(change.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(change.fieldChanges, id: \.fieldName) { fieldChange in
                HStack {
                    Text(fieldChange.fieldName)
                        .font(.subheadline)
                    Spacer()
                    if let oldValue = fieldChange.oldValue {
                        Text(oldValue)
                            .strikethrough()
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "arrow.right")
                        .foregroundColor(.accentColor)
                    if let newValue = fieldChange.newValue {
                        Text(newValue)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
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
                    FieldChange(fieldName: "name", oldValue: "John", newValue: "Johnny"),
                    FieldChange(fieldName: "pointBalance", oldValue: "100", newValue: "150")
                ],
                timestamp: Date().addingTimeInterval(-300),
                deviceInfo: "iPhone 12"
            ),
            ConflictChange(
                userID: "parent2",
                changeType: .update,
                fieldChanges: [
                    FieldChange(fieldName: "name", oldValue: "John", newValue: "Jonathan"),
                    FieldChange(fieldName: "pointBalance", oldValue: "100", newValue: "120")
                ],
                timestamp: Date().addingTimeInterval(-240),
                deviceInfo: "iPad Pro"
            )
        ],
        resolutionStrategy: .manualSelection
    )
    
    return ConflictResolutionView(
        conflict: sampleConflict,
        conflictResolver: ConflictResolver(
            permissionService: PermissionService(),
            conflictMetadataRepository: MockConflictMetadataRepository()
        )
    ) { _ in }
}

// Mock repository for preview
class MockConflictMetadataRepository: ConflictMetadataRepository {
    func createConflictMetadata(_ metadata: ConflictMetadata) async throws -> ConflictMetadata {
        return metadata
    }
    
    func fetchConflictMetadata(id: String) async throws -> ConflictMetadata? {
        return nil
    }
    
    func fetchConflicts(for familyID: String) async throws -> [ConflictMetadata] {
        return []
    }
    
    func updateConflictMetadata(_ metadata: ConflictMetadata) async throws -> ConflictMetadata {
        return metadata
    }
    
    func deleteConflictMetadata(id: String) async throws {
        // No-op
    }
}