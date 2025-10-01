import SwiftUI

struct PointsBalanceView: View {
    let points: Int
    let animationScale: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Text("My Points")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("\(points)")
                    .font(.system(size: 48))
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .scaleEffect(animationScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationScale)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    PointsBalanceView(points: 450, animationScale: 1.0)
}