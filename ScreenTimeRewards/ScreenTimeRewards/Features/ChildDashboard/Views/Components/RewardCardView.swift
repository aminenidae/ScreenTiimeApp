import SwiftUI
import SharedModels

struct RewardCardView: View {
    let reward: Reward
    let hasSufficientPoints: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Reward image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(hasSufficientPoints ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(height: 60)
                    .overlay(
                        Image(systemName: "gift.fill")
                            .foregroundColor(hasSufficientPoints ? .blue : .gray)
                            .font(.title2)
                    )
                
                Text(reward.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(reward.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(reward.pointCost)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(hasSufficientPoints ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                )
            }
            .padding()
            .frame(width: 150, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(hasSufficientPoints ? 0.1 : 0.05), radius: 4, x: 0, y: 2)
            )
        }
        .disabled(!hasSufficientPoints)
        .opacity(hasSufficientPoints ? 1.0 : 0.6)
    }
}

#Preview {
    let reward = Reward(
        id: "1",
        name: "Game Time",
        description: "30 minutes of game time",
        pointCost: 50,
        imageURL: nil,
        isActive: true,
        createdAt: Date()
    )
    
    return RewardCardView(reward: reward, hasSufficientPoints: true, onTap: {})
}