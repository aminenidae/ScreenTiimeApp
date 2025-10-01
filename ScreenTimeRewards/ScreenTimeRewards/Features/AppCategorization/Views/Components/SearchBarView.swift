//
//  SearchBarView.swift
//  ScreenTimeRewards
//
//  Created by James on 2025-09-27.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var onSearch: () -> Void = {}
    var onClear: () -> Void = {}
    
    var body: some View {
        HStack {
            TextField("Search apps...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearch()
                }
                .accessibilityLabel("Search for apps")
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    SearchBarView(text: .constant("Test"))
}