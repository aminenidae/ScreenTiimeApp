//
//  ContentView.swift
//  ScreenTimeApp
//
//  Created by Amine Nidae on 2025-09-25.
//

import SwiftUI
import CoreData
import FamilyControlsKit
import DesignSystem
import SharedModels

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack {
                // Use components from the ScreenTimeRewards package
                Image(systemName: "star.fill")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Screen Time Rewards")
                    .font(.title)
                    .padding()

                Text("Integrated with ScreenTimeRewards package!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // You can add more components from the package here
            }
            .navigationTitle("Home")
            .padding()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
