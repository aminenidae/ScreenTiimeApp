import SwiftUI
import SharedModels

// This is a simplified version of what would be in the DesignSystem package
// In a real implementation, this would contain reusable UI components

public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                )
        }
    }
}

public struct FamilyCardView: View {
    let family: Family
    
    public init(family: Family) {
        self.family = family
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(family.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Created: \(family.createdAt, formatter: itemFormatter)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Members: \(family.sharedWithUserIDs.count + 1)")
                Spacer()
                Text("Children: \(family.childProfileIDs.count)")
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
