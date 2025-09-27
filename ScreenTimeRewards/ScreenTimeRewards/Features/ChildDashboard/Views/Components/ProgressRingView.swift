import SwiftUI

struct ProgressRingView: View {
    let currentPoints: Int
    let goalPoints: Int
    let ringSize: CGFloat = 120
    
    private var progress: Double {
        guard goalPoints > 0 else { return 0 }
        return Double(currentPoints) / Double(goalPoints)
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 12
                )
                .frame(width: ringSize, height: ringSize)
            
            // Progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.green]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Points text in center
            VStack(spacing: 4) {
                Text("\(currentPoints)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("/ \(goalPoints)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ProgressRingView(currentPoints: 45, goalPoints: 100)
}