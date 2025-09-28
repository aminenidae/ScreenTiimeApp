import SwiftUI
import SharedModels

struct AchievementBadgesView: View {
    let badges: [AchievementBadge]
    let onBadgeSelected: (AchievementBadge) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievement Badges")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80), spacing: 16)
            ], spacing: 16) {
                ForEach(badges) { badge in
                    BadgeView(badge: badge) {
                        onBadgeSelected(badge)
                    }
                }
            }
        }
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let badge: AchievementBadge
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // Badge background
                    Circle()
                        .fill(badge.isRare ? Color.orange : Color.blue)
                        .frame(width: 60, height: 60)
                    
                    // Badge icon
                    Image(systemName: badge.icon)
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Text(badge.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Achievement Celebration View

struct AchievementCelebrationView: View {
    let badge: AchievementBadge
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🎉")
                .font(.system(size: 60))
            
            Text("New Badge Earned!")
                .font(.title)
                .fontWeight(.bold)
            
            ZStack {
                // Badge background
                Circle()
                    .fill(badge.isRare ? Color.orange : Color.blue)
                    .frame(width: 100, height: 100)
                
                // Badge icon
                Image(systemName: badge.icon)
                    .foregroundColor(.white)
                    .font(.title)
            }
            .padding(.vertical)
            
            VStack(spacing: 8) {
                Text(badge.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(badge.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Awesome!") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

struct AchievementBadgesView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementBadgesView(
            badges: [
                AchievementBadge(
                    childProfileID: "child1",
                    type: .streak(days: 7),
                    title: "Week Warrior",
                    description: "7-day learning streak",
                    earnedAt: Date(),
                    icon: "flame.fill",
                    isRare: false,
                    metadata: BadgeMetadata(pointsAwarded: 50)
                ),
                AchievementBadge(
                    childProfileID: "child1",
                    type: .points(points: 100),
                    title: "Point Master",
                    description: "Earned 100 points",
                    earnedAt: Date(),
                    icon: "star.fill",
                    isRare: true,
                    metadata: BadgeMetadata(pointsAwarded: 100)
                ),
                AchievementBadge(
                    childProfileID: "child1",
                    type: .time(hours: 10),
                    title: "Learning Machine",
                    description: "10 hours of learning",
                    earnedAt: Date(),
                    icon: "book.fill",
                    isRare: false,
                    metadata: BadgeMetadata()
                )
            ]
        ) { _ in }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}