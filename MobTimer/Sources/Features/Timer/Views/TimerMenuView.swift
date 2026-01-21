import SwiftUI

struct TimerMenuView: View {
    @Bindable var viewModel: TimerViewModel
    
    private var theme: AppTheme {
        viewModel.settings.theme
    }

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
        VStack(spacing: 0) {
            // Main Timer Card
            VStack(spacing: 20) {
                if viewModel.isTestingMode {
                    Text("TESTING MODE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.Colors.warning(for: theme))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.warning(for: theme).opacity(0.1))
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
                    showFlash: viewModel.showRotationFlash,
                    theme: theme
                )
                .frame(maxWidth: .infinity)

                TimerControlsView(viewModel: viewModel)

                if viewModel.activeParticipants.isEmpty && viewModel.state == .stopped {
                    warningView
                }
            }
            .padding(20)
            .background(Theme.Colors.secondaryBackground)
            
            Divider()

            // Participant List Area
            VStack(spacing: 0) {
                ParticipantListView(viewModel: viewModel)
                    .padding(16)
                
                Divider()

                // Footer
                HStack {
                    Spacer()
                    quitButton
                }
                .padding(12)
                .background(Theme.Colors.secondaryBackground.opacity(0.5))
            }
        }
        .frame(width: 320)
    }

    private var warningView: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.Colors.warning(for: theme))
            Text("Add participants to start")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.warning(for: theme).opacity(0.1))
        .cornerRadius(8)
    }

    private var quitButton: some View {
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Text("Quit MobTimer")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimerMenuView(viewModel: TimerViewModel())
}
