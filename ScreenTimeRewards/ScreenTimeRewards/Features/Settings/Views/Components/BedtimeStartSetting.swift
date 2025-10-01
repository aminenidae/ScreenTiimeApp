import SwiftUI

struct BedtimeStartSetting: View {
    @Binding var bedtimeStart: Date?
    @State private var isEnabled: Bool = false
    @State private var selectedTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bedtime Start")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .accessibilityLabel("Enable bedtime start")
                    .accessibilityHint("When enabled, apps will be restricted starting at the selected time")
            }

            Text("Set when apps should be restricted for bedtime. Apps will be blocked from this time until bedtime end.")
                .font(.caption)
                .foregroundColor(.secondary)

            if isEnabled {
                VStack(spacing: 16) {
                    HStack {
                        Text("Bedtime starts at:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(timeFormatter.string(from: selectedTime))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }

                    DatePicker(
                        "Bedtime Start Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .accessibilityLabel("Select bedtime start time")
                    .accessibilityValue(timeFormatter.string(from: selectedTime))
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isEnabled)
        .onAppear {
            if let bedtime = bedtimeStart {
                isEnabled = true
                selectedTime = bedtime
            } else {
                isEnabled = false
            }
        }
        .onChange(of: isEnabled) { enabled in
            if enabled {
                bedtimeStart = selectedTime
            } else {
                bedtimeStart = nil
            }
        }
        .onChange(of: selectedTime) { newTime in
            if isEnabled {
                bedtimeStart = newTime
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Bedtime start setting")
        .accessibilityValue(isEnabled ? "Enabled at \(timeFormatter.string(from: selectedTime))" : "Disabled")
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    VStack(spacing: 24) {
        BedtimeStartSetting(bedtimeStart: .constant(nil))
        BedtimeStartSetting(bedtimeStart: .constant(Calendar.current.date(from: DateComponents(hour: 20, minute: 0))))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}