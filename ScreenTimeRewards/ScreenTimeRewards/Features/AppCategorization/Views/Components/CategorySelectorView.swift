//
//  CategorySelectorView.swift
//  ScreenTimeRewards
//
//  Created by James on 2025-09-27.
//

import SwiftUI
import SharedModels

struct CategorySelectorView: View {
    @Binding var selectedCategory: AppCategory?
    var onCategoryChanged: (AppCategory?) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
                .accessibilityLabel("App category selection")
            
            Picker("Category", selection: $selectedCategory) {
                Text("None").tag(nil as AppCategory?)
                Text("Learning").tag(AppCategory?.some(.learning))
                Text("Reward").tag(AppCategory?.some(.reward))
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Select app category")
        }
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(.learning))
}