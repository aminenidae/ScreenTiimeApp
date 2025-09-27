import SwiftUI

struct BedtimeEndSetting: View {
    @Binding var bedtimeEnd: Date?
    @State private var isEnabled: Bool = false
    @State private var selectedTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bedtime End")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .accessibilityLabel("Enable bedtime end")
                    .accessibilityHint("When enabled, apps will be allowed again starting at the selected time")
            }

            Text("Set when apps should be allowed again after bedtime. Apps will be unblocked starting at this time.")
                .font(.caption)
                .foregroundColor(.secondary)

            if isEnabled {
                VStack(spacing: 16) {
                    HStack {
                        Text("Bedtime ends at:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(timeFormatter.string(from: selectedTime))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }

                    DatePicker(
                        "Bedtime End Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .accessibilityLabel("Select bedtime end time")
                    .accessibilityValue(timeFormatter.string(from: selectedTime))
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isEnabled)
        .onAppear {
            if let bedtime = bedtimeEnd {
                isEnabled = true
                selectedTime = bedtime
            } else {
                isEnabled = false
            }
        }
        .onChange(of: isEnabled) { enabled in
            if enabled {
                bedtimeEnd = selectedTime
            } else {
                bedtimeEnd = nil
            }
        }
        .onChange(of: selectedTime) { newTime in
            if isEnabled {
                bedtimeEnd = newTime
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Bedtime end setting")
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
        BedtimeEndSetting(bedtimeEnd: .constant(nil))
        BedtimeEndSetting(bedtimeEnd: .constant(Calendar.current.date(from: DateComponents(hour: 7, minute: 0))))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}