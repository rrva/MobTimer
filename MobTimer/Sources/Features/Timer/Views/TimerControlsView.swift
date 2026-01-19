import SwiftUI

struct TimerControlsView: View {
    @Bindable var viewModel: TimerViewModel

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
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    skipButton
                }

            case .onBreak:
                pauseButton
                Text("On Break")
                    .font(.caption)
                    .foregroundStyle(.orange)

            case .awaitingDriver:
                Text("Awaiting Driver")
                    .font(.caption)
                    .foregroundStyle(.green)
                stopButton
            }
        }
    }

    private var startButton: some View {
        Button {
            viewModel.start()
        } label: {
            Label("Start", systemImage: "play.fill")
        }
        .disabled(!viewModel.canStart)
        .buttonStyle(.borderedProminent)
    }

    private var pauseButton: some View {
        Button {
            viewModel.pause()
        } label: {
            Label("Pause", systemImage: "pause.fill")
        }
        .buttonStyle(.bordered)
    }

    private var resumeButton: some View {
        Button {
            viewModel.resume()
        } label: {
            Label("Resume", systemImage: "play.fill")
        }
        .buttonStyle(.borderedProminent)
    }

    private var stopButton: some View {
        Button {
            viewModel.stop()
        } label: {
            Label("Stop", systemImage: "stop.fill")
        }
        .buttonStyle(.bordered)
    }

    private var skipButton: some View {
        Button {
            viewModel.skip()
        } label: {
            Label("Skip", systemImage: "forward.fill")
        }
        .buttonStyle(.bordered)
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
