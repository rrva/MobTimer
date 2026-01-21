import SwiftUI
import AppKit

@main
struct MobTimerApp: App {
    @State private var viewModel = TimerViewModel()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    private var menuBarIcon: String {
        switch viewModel.state {
        case .stopped: return "person.3"
        case .running: return "play.circle.fill"
        case .paused: return "pause.circle.fill"
        case .onBreak: return "cup.and.saucer.fill"
        case .awaitingDriver: return "exclamationmark.circle.fill"
        }
    }

    var body: some Scene {
        MenuBarExtra {
            TimerMenuView(viewModel: viewModel)
        } label: {
            Label(viewModel.statusText, systemImage: menuBarIcon)
        }
        .menuBarExtraStyle(.window)

        Window("Rotation", id: "rotation-window") {
            RotationWindowView(viewModel: viewModel)
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        .windowLevel(.floating)
        .onChange(of: viewModel.showRotationWindow) { _, shouldShow in
            if shouldShow {
                openWindow(id: "rotation-window")
                // Center window on screen
                DispatchQueue.main.async {
                    centerRotationWindow()
                }
            } else {
                dismissWindow(id: "rotation-window")
            }
        }
    }
}

private func centerRotationWindow() {
    guard let window = NSApplication.shared.windows.first(where: { $0.title == "Rotation" }) else {
        return
    }
    
    window.center()
}
