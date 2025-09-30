import Foundation
import SharedModels

@MainActor
class ConflictResolutionViewModel: ObservableObject {
    @Published var selectedResolutionIndex: Int = 0
    @Published var isResolving: Bool = false
    @Published var errorMessage: String?
    
    private let conflict: ConflictMetadata
    private let conflictResolver: ConflictResolver
    
    init(
        conflict: ConflictMetadata,
        conflictResolver: ConflictResolver
    ) {
        self.conflict = conflict
        self.conflictResolver = conflictResolver
    }
    
    /// Applies the selected resolution strategy
    /// - Parameter completion: Completion handler with the resolved conflict
    func applyResolution(completion: @escaping (ConflictMetadata) -> Void) {
        isResolving = true
        errorMessage = nil
        
        Task {
            do {
                var resolvedConflict = conflict
                
                if selectedResolutionIndex >= 0 && selectedResolutionIndex < conflict.conflictingChanges.count {
                    // Use selected change
                    let selectedChange = conflict.conflictingChanges[selectedResolutionIndex]
                    resolvedConflict = ConflictMetadata(
                        id: conflict.id,
                        familyID: conflict.familyID,
                        recordType: conflict.recordType,
                        recordID: conflict.recordID,
                        conflictingChanges: conflict.conflictingChanges,
                        resolutionStrategy: .manualSelection,
                        resolvedBy: selectedChange.userID,
                        resolvedAt: Date(),
                        metadata: conflict.metadata
                    )
                } else {
                    // Attempt to merge changes
                    if let mergedChange = conflictResolver.mergeChanges(
                        conflict: conflict,
                        changes: conflict.conflictingChanges
                    ) {
                        resolvedConflict = ConflictMetadata(
                            id: conflict.id,
                            familyID: conflict.familyID,
                            recordType: conflict.recordType,
                            recordID: conflict.recordID,
                            conflictingChanges: [mergedChange],
                            resolutionStrategy: .automaticMerge,
                            resolvedBy: "system",
                            resolvedAt: Date(),
                            metadata: conflict.metadata
                        )
                    } else {
                        // Fallback to last-write-wins
                        if let winningChange = conflictResolver.resolveWithLastWriteWins(
                            conflict: conflict,
                            changes: conflict.conflictingChanges
                        ) {
                            resolvedConflict = ConflictMetadata(
                                id: conflict.id,
                                familyID: conflict.familyID,
                                recordType: conflict.recordType,
                                recordID: conflict.recordID,
                                conflictingChanges: conflict.conflictingChanges,
                                resolutionStrategy: .automaticLastWriteWins,
                                resolvedBy: winningChange.userID,
                                resolvedAt: Date(),
                                metadata: conflict.metadata
                            )
                        }
                    }
                }
                
                // Store the resolved conflict metadata
                try await conflictResolver.storeConflictMetadata(resolvedConflict)
                
                await MainActor.run {
                    isResolving = false
                    completion(resolvedConflict)
                }
            } catch {
                await MainActor.run {
                    isResolving = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}