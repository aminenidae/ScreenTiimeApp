import SwiftUI
import SharedModels

struct ContentRestrictionsView: View {
    @Binding var contentRestrictions: [String: Bool]
    @State private var availableApps: [AppMetadata] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true

    private var filteredApps: [AppMetadata] {
        if searchText.isEmpty {
            return availableApps
        } else {
            return availableApps.filter { app in
                app.displayName.localizedCaseInsensitiveContains(searchText) ||
                app.bundleID.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("App Restrictions")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            Text("Control which apps can be used during restricted times. Disabled apps will be blocked during bedtime hours.")
                .font(.caption)
                .foregroundColor(.secondary)

            if !availableApps.isEmpty {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search apps...", text: $searchText)
                        .textFieldStyle(.plain)
                        .accessibilityLabel("Search for apps")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemBackground))
                )

                // Restriction summary
                restrictionSummary

                // Apps list
                if !filteredApps.isEmpty {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredApps) { app in
                            AppRestrictionRow(
                                app: app,
                                isRestricted: Binding(
                                    get: { contentRestrictions[app.bundleID] ?? false },
                                    set: { newValue in
                                        contentRestrictions[app.bundleID] = newValue
                                    }
                                )
                            )
                        }
                    }
                    .padding(.top, 8)
                } else if !searchText.isEmpty {
                    // No search results
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("No apps found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Try searching with different keywords")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                }
            } else if !isLoading {
                // No apps available
                VStack(spacing: 12) {
                    Image(systemName: "apps.iphone")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No apps available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("No compatible apps found on this device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
            }
        }
        .task {
            await loadAvailableApps()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("App restrictions settings")
    }

    private var restrictionSummary: some View {
        let restrictedCount = contentRestrictions.values.filter { $0 }.count
        let totalCount = availableApps.count

        return HStack {
            Text("\(restrictedCount) of \(totalCount) apps restricted")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            if restrictedCount > 0 {
                Button("Clear All") {
                    for bundleID in contentRestrictions.keys {
                        contentRestrictions[bundleID] = false
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
                .accessibilityLabel("Clear all restrictions")
            }
        }
    }

    private func loadAvailableApps() async {
        isLoading = true

        // Simulate loading available apps (in real implementation, this would come from app discovery service)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay

        // Mock data for preview/testing - in real implementation, fetch from device
        availableApps = [
            AppMetadata(id: "1", bundleID: "com.apple.mobilesafari", displayName: "Safari", isSystemApp: true, iconData: nil),
            AppMetadata(id: "2", bundleID: "com.apple.mobilemail", displayName: "Mail", isSystemApp: true, iconData: nil),
            AppMetadata(id: "3", bundleID: "com.apple.Music", displayName: "Music", isSystemApp: true, iconData: nil),
            AppMetadata(id: "4", bundleID: "com.apple.TV", displayName: "TV", isSystemApp: true, iconData: nil),
            AppMetadata(id: "5", bundleID: "com.apple.camera", displayName: "Camera", isSystemApp: true, iconData: nil),
            AppMetadata(id: "6", bundleID: "com.apple.Maps", displayName: "Maps", isSystemApp: true, iconData: nil)
        ]

        isLoading = false
    }
}

struct AppRestrictionRow: View {
    let app: AppMetadata
    @Binding var isRestricted: Bool

    var body: some View {
        HStack(spacing: 12) {
            // App icon placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "app.fill")
                        .foregroundColor(.secondary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(app.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(app.bundleID)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("Restrict \(app.displayName)", isOn: $isRestricted)
                .labelsHidden()
                .accessibilityLabel("Restrict \(app.displayName)")
                .accessibilityHint("When enabled, this app will be blocked during restricted times")
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            isRestricted.toggle()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isRestricted ? "Restricted" : "Allowed")
    }
}

#Preview {
    ContentRestrictionsView(contentRestrictions: .constant([
        "com.apple.mobilesafari": true,
        "com.apple.mobilemail": false,
        "com.apple.Music": true
    ]))
    .padding()
    .background(Color(.systemGroupedBackground))
}