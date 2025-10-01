//
//  BulkActionView.swift
//  ScreenTimeRewards
//
//  Created by James on 2025-09-27.
//

import SwiftUI
import SharedModels

struct BulkActionView: View {
    @Binding var isBulkMode: Bool
    @Binding var selectedAppsCount: Int
    var onSelectAll: () -> Void = {}
    var onSelectNone: () -> Void = {}
    var onBulkCategorize: (AppCategory) -> Void = { _ in }
    var onCancel: () -> Void = {}
    
    var body: some View {
        VStack {
            if isBulkMode {
                HStack {
                    Text("Selected: \(selectedAppsCount)")
                        .font(.headline)
                        .accessibilityLabel("Selected apps count: \(selectedAppsCount)")
                    
                    Spacer()
                    
                    Button("Cancel") {
                        onCancel()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Cancel bulk selection")
                }
                .padding(.horizontal)
                
                HStack {
                    Button("Select All") {
                        onSelectAll()
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectedAppsCount > 0 && selectedAppsCount == getTotalAppCount())
                    .accessibilityLabel("Select all apps")
                    
                    Button("Select None") {
                        onSelectNone()
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectedAppsCount == 0)
                    .accessibilityLabel("Deselect all apps")
                    
                    Spacer()
                    
                    Button("Learning") {
                        onBulkCategorize(.learning)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedAppsCount == 0)
                    .accessibilityLabel("Categorize selected apps as learning")
                    
                    Button("Reward") {
                        onBulkCategorize(.reward)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedAppsCount == 0)
                    .accessibilityLabel("Categorize selected apps as reward")
                }
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                HStack {
                    Text("Bulk Actions")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Select Apps") {
                        isBulkMode = true
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Enter bulk selection mode")
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private func getTotalAppCount() -> Int {
        // In a real implementation, this would be passed from the parent view
        // For now, we'll return a placeholder value
        return 100
    }
}

#Preview {
    BulkActionView(
        isBulkMode: .constant(false),
        selectedAppsCount: .constant(5)
    )
}