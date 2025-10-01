//
//  FilterBarView.swift
//  ScreenTimeRewards
//
//  Created by James on 2025-09-27.
//

import SwiftUI
import SharedModels

struct FilterBarView: View {
    @Binding var selectedFilter: AppFilter
    var onFilterChanged: (AppFilter) -> Void = { _ in }
    
    var body: some View {
        HStack {
            ForEach(AppFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                    onFilterChanged(filter)
                }) {
                    Text(filter.title)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .cornerRadius(20)
                }
                .accessibilityLabel("Filter by \(filter.title)")
                .accessibilityValue(selectedFilter == filter ? "Selected" : "Not selected")
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}


#Preview {
    FilterBarView(selectedFilter: .constant(.all))
}