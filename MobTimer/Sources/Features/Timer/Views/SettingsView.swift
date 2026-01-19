import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: TimerViewModel

    @State private var rotationDuration: Int = 5
    @State private var useSecondsMode: Bool = false
    @State private var rotationDurationSeconds: Int = 10
    @State private var enableBreaks: Bool = false
    @State private var breakAfterRotations: Int = 4
    @State private var breakDuration: Int = 10
    @State private var playSound: Bool = true
    @State private var speakAnnouncement: Bool = true
    @State private var announcementTemplate: String = ""

    private var isTestingMode: Bool {
        TimerViewModel.isTestingMode
    }

    private static let buildTimestamp: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter.string(from: Date())
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Settings")
                    .font(.headline)

                Spacer()

                Button {
                    viewModel.showingSettings = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            GroupBox("Timer") {
                VStack(alignment: .leading, spacing: 8) {
                    if isTestingMode {
                        Toggle("Use seconds (testing)", isOn: $useSecondsMode)

                        if useSecondsMode {
                            HStack {
                                Text("Rotation duration:")
                                Picker("", selection: $rotationDurationSeconds) {
                                    ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { secs in
                                        Text("\(secs) sec").tag(secs)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 100)
                            }
                        } else {
                            HStack {
                                Text("Rotation duration:")
                                Picker("", selection: $rotationDuration) {
                                    ForEach([1, 2, 3, 4, 5, 7, 10, 15, 20, 25, 30], id: \.self) { mins in
                                        Text("\(mins) min").tag(mins)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 100)
                            }
                        }
                    } else {
                        HStack {
                            Text("Rotation duration:")
                            Picker("", selection: $rotationDuration) {
                                ForEach([1, 2, 3, 4, 5, 7, 10, 15, 20, 25, 30], id: \.self) { mins in
                                    Text("\(mins) min").tag(mins)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 100)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            GroupBox("Breaks") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Enable break reminders", isOn: $enableBreaks)

                    if enableBreaks {
                        HStack {
                            Text("Break after:")
                            Picker("", selection: $breakAfterRotations) {
                                ForEach([2, 3, 4, 5, 6, 8, 10], id: \.self) { count in
                                    Text("\(count) rotations").tag(count)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 120)
                        }

                        HStack {
                            Text("Break duration:")
                            Picker("", selection: $breakDuration) {
                                ForEach([5, 10, 15, 20, 30], id: \.self) { mins in
                                    Text("\(mins) min").tag(mins)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 100)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            GroupBox("Notifications") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Play sound on rotation", isOn: $playSound)
                    Toggle("Speak announcement", isOn: $speakAnnouncement)

                    if speakAnnouncement {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Announcement template:")
                                .font(.caption)
                            TextField("Template", text: $announcementTemplate)
                                .textFieldStyle(.roundedBorder)
                            Text("Use {name} for the driver's name")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Divider()

            HStack {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Cancel") {
                    viewModel.showingSettings = false
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    saveSettings()
                    viewModel.showingSettings = false
                }
                .buttonStyle(.borderedProminent)
            }

            Text("Build: \(Self.buildTimestamp)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(width: 350)
        .onAppear {
            loadCurrentSettings()
        }
    }

    private func loadCurrentSettings() {
        let settings = viewModel.settings
        rotationDuration = settings.rotationDurationMinutes
        if let seconds = settings.rotationDurationSeconds {
            useSecondsMode = true
            rotationDurationSeconds = seconds
        } else {
            useSecondsMode = false
        }
        enableBreaks = settings.breakAfterRotations != nil
        breakAfterRotations = settings.breakAfterRotations ?? 4
        breakDuration = settings.breakDurationMinutes
        playSound = settings.playSoundOnRotation
        speakAnnouncement = settings.speakAnnouncement
        announcementTemplate = settings.announcementTemplate
    }

    private func saveSettings() {
        let newSettings = TimerSettings(
            rotationDurationMinutes: rotationDuration,
            rotationDurationSeconds: useSecondsMode ? rotationDurationSeconds : nil,
            breakAfterRotations: enableBreaks ? breakAfterRotations : nil,
            breakDurationMinutes: breakDuration,
            playSoundOnRotation: playSound,
            speakAnnouncement: speakAnnouncement,
            announcementTemplate: announcementTemplate.isEmpty
                ? TimerSettings.default.announcementTemplate
                : announcementTemplate
        )
        viewModel.updateSettings(newSettings)
    }

    private func resetToDefaults() {
        let defaults = TimerSettings.default
        rotationDuration = defaults.rotationDurationMinutes
        enableBreaks = defaults.breakAfterRotations != nil
        breakAfterRotations = defaults.breakAfterRotations ?? 4
        breakDuration = defaults.breakDurationMinutes
        playSound = defaults.playSoundOnRotation
        speakAnnouncement = defaults.speakAnnouncement
        announcementTemplate = defaults.announcementTemplate
    }
}

#Preview {
    SettingsView(viewModel: TimerViewModel())
}
