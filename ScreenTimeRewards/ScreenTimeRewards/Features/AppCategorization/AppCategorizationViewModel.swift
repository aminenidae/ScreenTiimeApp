//
//  AppCategorizationViewModel.swift
//  ScreenTimeRewards
//
//  Created by James on 2025-09-27.
//  Updated by James on 2025-09-27 to implement enhanced app categorization functionality.

import Foundation
import Combine
import FamilyControlsKit
import SharedModels
import CloudKitService

@MainActor
class AppCategorizationViewModel: ObservableObject {
    @Published var apps: [AppMetadata] = []
    @Published var filteredApps: [AppMetadata] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var hasUnsavedChanges = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedApps: Set<String> = []
    
    // Public properties for view access
    var appCategories: [String: AppCategory] { _appCategories }
    var appPoints: [String: Int] { _appPoints }
    
    private var _appCategories: [String: AppCategory] = [:]
    private var _appPoints: [String: Int] = [:]
    private let appDiscoveryService = AppDiscoveryService()
    private let appCategorizationRepository = AppCategorizationRepository()
    private var cancellables = Set<AnyCancellable>()
    private let childProfileID = UUID() // In a real implementation, this would be provided
    private var selectedFilter: AppFilter = .all
    
    init() {
        setupSearchFilter()
    }
    
    func loadApps() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch installed apps using AppDiscoveryService
            let installedApps = try await appDiscoveryService.fetchInstalledApps()
            // Convert FamilyControlsKit AppMetadata to SharedModels AppMetadata
            apps = installedApps.map { app in
                AppMetadata(
                    id: UUID().uuidString,
                    bundleID: app.bundleID,
                    displayName: app.displayName,
                    isSystemApp: app.isSystemApp,
                    iconData: nil // In a real implementation, we would convert the Data to an Image
                )
            }.sorted { $0.displayName < $1.displayName }
            
            // Load existing categorizations
            try await loadExistingCategorizations()
            
            // Apply initial filter
            filterApps()
        } catch {
            showError(message: "Error loading apps: \(error.localizedDescription)")
        }
    }
    
    private func loadExistingCategorizations() async throws {
        // Load existing categorizations from repository
        let categorizations = try await appCategorizationRepository.fetchCategorizations(for: childProfileID.uuidString)
        
        // Map categorizations to local storage
        for categorization in categorizations {
            _appCategories[categorization.appBundleID] = categorization.category
            _appPoints[categorization.appBundleID] = categorization.pointsPerHour
        }
    }
    
    private func setupSearchFilter() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.filterApps()
            }
            .store(in: &cancellables)
    }
    
    func filterApps() {
        applyCombinedFilter()
    }
    
    func applyFilter(_ filter: AppFilter) {
        selectedFilter = filter
        applyCombinedFilter()
    }
    
    private func applyCombinedFilter() {
        var result = apps
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { app in
                app.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .learning:
            result = result.filter { app in
                _appCategories[app.bundleID] == .learning
            }
        case .reward:
            result = result.filter { app in
                _appCategories[app.bundleID] == .reward
            }
        case .all:
            // No additional filtering needed
            break
        }
        
        filteredApps = result
    }
    
    func updateAppCategory(bundleID: String, category: AppCategory?) {
        _appCategories[bundleID] = category
        hasUnsavedChanges = true
        
        // If category is changed to reward, remove points
        if category == .reward {
            _appPoints.removeValue(forKey: bundleID)
        }
    }
    
    func updatePointsPerHour(bundleID: String, points: Int) {
        // Validate that points are non-negative
        guard points >= 0 else {
            showError(message: "Points per hour must be non-negative")
            return
        }
        
        _appPoints[bundleID] = points
        hasUnsavedChanges = true
    }
    
    func saveChanges() {
        // Validate that there are no conflicts
        if !validateCategorizations() {
            return
        }
        
        Task {
            do {
                try await saveCategorizationsToRepository()
                hasUnsavedChanges = false
                // Show success feedback
                showError(message: "Changes saved successfully!")
            } catch {
                showError(message: "Error saving categorizations: \(error.localizedDescription)")
            }
        }
    }
    
    private func validateCategorizations() -> Bool {
        // Check for conflicts - an app cannot be in both Learning and Reward categories
        // Since we're using a single category per app, this validation is simpler
        // We just need to ensure that the categorization data is consistent
        
        // Validate that points are set for learning apps
        for (bundleID, category) in _appCategories {
            if category == .learning && (_appPoints[bundleID] ?? 0) <= 0 {
                showError(message: "Learning apps must have points per hour greater than 0")
                return false
            }
        }
        
        return true
    }
    
    private func saveCategorizationsToRepository() async throws {
        // Convert local storage to AppCategorization models and save
        for (bundleID, category) in _appCategories {
            guard let category = category else { continue }
            let points = _appPoints[bundleID] ?? 0
            
            // Find the app metadata
            guard let app = apps.first(where: { $0.bundleID == bundleID }) else { continue }
            
            // Create AppCategorization model
            let appCategorization = AppCategorization(
                id: UUID().uuidString,
                appBundleID: bundleID,
                category: category,
                childProfileID: childProfileID.uuidString,
                pointsPerHour: points,
                createdAt: Date()
            )
            
            // Save to repository
            try await appCategorizationRepository.saveCategorization(appCategorization)
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - User Experience Enhancements
    
    func toggleAppSelection(bundleID: String) {
        if selectedApps.contains(bundleID) {
            selectedApps.remove(bundleID)
        } else {
            selectedApps.insert(bundleID)
        }
    }
    
    func selectAllApps() {
        selectedApps = Set(apps.map { $0.bundleID })
    }
    
    func clearSelection() {
        selectedApps.removeAll()
    }
    
    func bulkCategorize(to category: AppCategory) {
        for bundleID in selectedApps {
            updateAppCategory(bundleID: bundleID, category: category)
            
            // For learning apps, set default points
            if category == .learning {
                updatePointsPerHour(bundleID: bundleID, points: 10)
            }
        }
        clearSelection()
        hasUnsavedChanges = true
        filterApps() // Refresh the filtered list
    }
}