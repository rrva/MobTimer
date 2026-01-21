import SwiftUI

struct TimerControlsView: View {
    @Bindable var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Add theme property derived from view model settings for convenience
    private var theme: AppTheme {
        viewModel.settings.theme
    }

    var body: some View {
        HStack(spacing: 12) {
            switch viewModel.state {
            case .stopped:
                startButton

            case .running:
                pauseButton
                skipButton

            case .paused:
                resumeButton
                stopButton
                if viewModel.pausedFromAwaitingDriver {
                    Text("Rotation Paused")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.Colors.warning(for: theme))
                } else {
                    skipButton
                }

            case .onBreak:
                pauseButton
                Text("On Break")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.Colors.warning(for: theme))

            case .awaitingDriver:
                Text("Awaiting Driver")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.Colors.primary(for: theme))
                stopButton
            }
        }
    }

    private var startButton: some View {
        Button {
            viewModel.start()
            dismiss()
        } label: {
            Label("Start", systemImage: "play.fill")
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.Colors.primary(for: theme))
        .disabled(!viewModel.canStart)
    }

    private var pauseButton: some View {
        Button {
            viewModel.pause()
        } label: {
            Label("Pause", systemImage: "pause.fill")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
    }

    private var resumeButton: some View {
        Button {
            viewModel.resume()
            dismiss()
        } label: {
            Label("Resume", systemImage: "play.fill")
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.Colors.primary(for: theme))
    }

    private var stopButton: some View {
        Button {
            viewModel.stop()
        } label: {
            Label("Stop", systemImage: "stop.fill")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
    }

    private var skipButton: some View {
        Button {
            viewModel.skip()
        } label: {
            Label("Skip", systemImage: "forward.fill")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
        .tint(Theme.Colors.secondary(for: theme))
    }
}

#Preview {
    VStack(spacing: 20) {
        let vm1 = TimerViewModel()
        TimerControlsView(viewModel: vm1)

        let vm2 = TimerViewModel()
        TimerControlsView(viewModel: vm2)
            .onAppear {
                vm2.addParticipant(name: "Alice")
                vm2.addParticipant(name: "Bob")
            }
    }
    .padding()
}
