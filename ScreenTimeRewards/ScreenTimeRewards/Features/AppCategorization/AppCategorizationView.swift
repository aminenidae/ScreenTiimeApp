//
//  AppCategorizationView.swift
//  ScreenTimeRewards
//
//  Created by James on 2025-09-26.
//  Updated by Quinn on 2025-09-27 to match existing SharedModels.

import SwiftUI
import SharedModels

struct AppCategorizationView: View {
    @StateObject private var viewModel = AppCategorizationViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading apps...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.apps.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        // Bulk categorization section
                        Section(header: Text("Bulk Actions").font(.headline)) {
                            HStack {
                                Text("Select apps below, then:")
                                Spacer()
                            }
                            
                            HStack {
                                Button("All to Learning") {
                                    viewModel.bulkCategorize(to: .learning)
                                }
                                .buttonStyle(.bordered)
                                
                                Button("All to Reward") {
                                    viewModel.bulkCategorize(to: .reward)
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Clear Selection") {
                                    viewModel.clearSelection()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.vertical)
                        }
                        
                        // App list
                        ForEach(viewModel.filteredApps, id: \.id) { app in
                            AppCategoryRowView(
                                app: app,
                                isSelected: viewModel.selectedApps.contains(app.bundleID),
                                selectedCategory: viewModel.appCategories[app.bundleID],
                                pointsPerHour: viewModel.appPoints[app.bundleID] ?? 0,
                                onCategoryChanged: { bundleID, category in
                                    viewModel.updateAppCategory(bundleID: bundleID, category: category)
                                },
                                onPointsChanged: { bundleID, points in
                                    viewModel.updatePointsPerHour(bundleID: bundleID, points: points)
                                },
                                onAppSelected: { bundleID in
                                    viewModel.toggleAppSelection(bundleID: bundleID)
                                }
                            )
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .searchable(text: $viewModel.searchText, prompt: "Search apps...")
                    .refreshable {
                        await viewModel.loadApps()
                    }
                }
            }
            .navigationTitle("App Categorization")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveChanges()
                    }
                    .disabled(viewModel.hasUnsavedChanges == false)
                    .accessibilityLabel("Save changes")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Refresh") {
                        Task {
                            await viewModel.loadApps()
                        }
                    }
                    .accessibilityLabel("Refresh app list")
                }
            }
            .alert("Validation Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadApps()
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Apps Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Install some apps to categorize them as learning or reward activities.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AppCategoryRowView: View {
    let app: AppMetadata
    let isSelected: Bool
    let selectedCategory: AppCategory?
    let pointsPerHour: Int
    let onCategoryChanged: (String, AppCategory?) -> Void
    let onPointsChanged: (String, Int) -> Void
    let onAppSelected: (String) -> Void
    
    var body: some View {
        HStack {
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
            
            // App icon and name
            if let iconData = app.iconData {
                // In a real implementation, we would convert the Data to an Image
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading) {
                Text(app.displayName)
                    .font(.headline)
                    .accessibilityLabel("App name: \(app.displayName)")
                
                // Category selection
                Picker("Category", selection: Binding(
                    get: { selectedCategory ?? nil },
                    set: { newValue in
                        onCategoryChanged(app.bundleID, newValue)
                    }
                )) {
                    Text("None").tag(nil as AppCategory?)
                    Text("Learning").tag(AppCategory?.some(.learning))
                    Text("Reward").tag(AppCategory?.some(.reward))
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Select category for \(app.displayName)")
                
                // Points per hour input
                HStack {
                    Text("Points/Hour:")
                        .accessibilityLabel("Points per hour for \(app.displayName)")
                    TextField("0", value: Binding(
                        get: { pointsPerHour },
                        set: { newValue in
                            onPointsChanged(app.bundleID, newValue)
                        }
                    ), formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .accessibilityLabel("Points per hour input for \(app.displayName)")
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle()) // Make the entire row tappable
        .onTapGesture {
            onAppSelected(app.bundleID)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    AppCategorizationView()
}