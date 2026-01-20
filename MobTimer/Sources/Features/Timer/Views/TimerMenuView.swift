import SwiftUI

struct TimerMenuView: View {
    @Bindable var viewModel: TimerViewModel

    var body: some View {
        Group {
            if viewModel.showingSettings {
                SettingsView(viewModel: viewModel)
            } else {
                mainView
            }
        }
    }

    private var mainView: some View {
        VStack(spacing: 16) {
            if viewModel.isTestingMode {
                Text("TESTING MODE")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }

            CircularProgressView(
                progress: viewModel.progress,
                remainingText: viewModel.statusText,
                driverName: viewModel.currentDriver?.name,
                navigatorName: viewModel.currentNavigator?.name,
                isOnBreak: viewModel.state == .onBreak,
                isAwaitingDriver: viewModel.state == .awaitingDriver,
                rotationsUntilBreak: viewModel.rotationsUntilBreak,
                showFlash: viewModel.showRotationFlash
            )

            TimerControlsView(viewModel: viewModel)

            if viewModel.activeParticipants.isEmpty && viewModel.state == .stopped {
                warningView
            }

            Divider()

            ParticipantListView(viewModel: viewModel)

            Divider()

            quitButton
        }
        .padding()
        .frame(width: 300)
    }

    private var warningView: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Add participants to start")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var quitButton: some View {
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Text("Quit MobTimer")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimerMenuView(viewModel: TimerViewModel())
}
