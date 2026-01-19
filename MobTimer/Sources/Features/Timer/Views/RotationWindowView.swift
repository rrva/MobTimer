import SwiftUI

struct RotationWindowView: View {
    @Bindable var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: viewModel.showRotationWindow)

                Text("ROTATE!")
                    .font(.system(size: 32, weight: .bold))
            }

            // Driver/Navigator card
            VStack(spacing: 16) {
                if let driver = viewModel.currentDriver {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)

                        Text("\(driver.name), you're driving!")
                            .font(.title2.weight(.semibold))
                    }
                }

                if let navigator = viewModel.currentNavigator {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)

                        Text("Navigator: \(navigator.name)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                if let nextUp = viewModel.nextDriver {
                    Text("Up next: \(nextUp.name)")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            // Rotation info
            HStack(spacing: 8) {
                Text("Rotation \(viewModel.rotationCount)")
                Text("•")
                    .foregroundStyle(.tertiary)
                Text(turnDurationText)
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            // Ready button
            Button {
                viewModel.acknowledgeRotation()
            } label: {
                Text("Ready to Drive!")
                    .font(.headline)
                    .frame(minWidth: 180)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: [])

            // Secondary actions
            HStack(spacing: 24) {
                Button {
                    viewModel.skipTurn()
                } label: {
                    Text("Skip Turn")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button {
                    viewModel.pause()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(32)
        .frame(width: 400, height: 380)
        .background(.regularMaterial)
    }

    private var turnDurationText: String {
        let seconds = viewModel.settings.effectiveRotationSeconds
        if seconds >= 60 {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s") turn"
        } else {
            return "\(seconds) second turn"
        }
    }
}

#Preview {
    let viewModel = TimerViewModel()
    return RotationWindowView(viewModel: viewModel)
        .onAppear {
            viewModel.addParticipant(name: "Alice")
            viewModel.addParticipant(name: "Bob")
            viewModel.addParticipant(name: "Charlie")
        }
}
