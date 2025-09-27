import SwiftUI

struct DailyTimeLimitSetting: View {
    @Binding var dailyTimeLimit: Int

    private let minLimit = 0
    private let maxLimit = 480 // 8 hours
    private let stepValue = 15

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Time Limit")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                Text(timeFormatted(minutes: dailyTimeLimit))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
            }

            Text("Set the maximum screen time allowed per day. Use 0 for unlimited time.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Button(action: decreaseLimit) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(dailyTimeLimit > minLimit ? .blue : .gray)
                }
                .disabled(dailyTimeLimit <= minLimit)
                .accessibilityLabel("Decrease daily time limit")
                .accessibilityHint("Decreases limit by \(stepValue) minutes")

                Slider(
                    value: Binding(
                        get: { Double(dailyTimeLimit) },
                        set: { newValue in
                            let rounded = Int(newValue / Double(stepValue)) * stepValue
                            dailyTimeLimit = max(minLimit, min(maxLimit, rounded))
                        }
                    ),
                    in: Double(minLimit)...Double(maxLimit),
                    step: Double(stepValue)
                )
                .accentColor(.blue)

                Button(action: increaseLimit) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(dailyTimeLimit < maxLimit ? .blue : .gray)
                }
                .disabled(dailyTimeLimit >= maxLimit)
                .accessibilityLabel("Increase daily time limit")
                .accessibilityHint("Increases limit by \(stepValue) minutes")
            }

            // Quick preset buttons
            HStack(spacing: 8) {
                ForEach(presetValues, id: \\.self) { preset in
                    Button(action: { dailyTimeLimit = preset }) {
                        Text(preset == 0 ? "Unlimited" : timeFormatted(minutes: preset))
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(dailyTimeLimit == preset ? Color.blue : Color(.tertiarySystemBackground))
                            )
                            .foregroundColor(dailyTimeLimit == preset ? .white : .primary)
                    }
                    .accessibilityLabel("Set to \(preset == 0 ? "unlimited" : timeFormatted(minutes: preset))")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Daily time limit setting")
        .accessibilityValue("Current limit: \(timeFormatted(minutes: dailyTimeLimit))")
    }

    private var presetValues: [Int] {
        [0, 60, 120, 180, 240]
    }

    private func decreaseLimit() {
        let newValue = dailyTimeLimit - stepValue
        dailyTimeLimit = max(minLimit, newValue)
    }

    private func increaseLimit() {
        let newValue = dailyTimeLimit + stepValue
        dailyTimeLimit = min(maxLimit, newValue)
    }

    private func timeFormatted(minutes: Int) -> String {
        if minutes == 0 {
            return "Unlimited"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours == 0 {
            return "\(remainingMinutes)m"
        } else if remainingMinutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        DailyTimeLimitSetting(dailyTimeLimit: .constant(120))
        DailyTimeLimitSetting(dailyTimeLimit: .constant(0))
        DailyTimeLimitSetting(dailyTimeLimit: .constant(300))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}