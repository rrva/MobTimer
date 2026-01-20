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
                // Position window near top of screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    positionRotationWindowAtTop()
                }
            } else {
                dismissWindow(id: "rotation-window")
            }
        }
    }
}

private func positionRotationWindowAtTop() {
    guard let window = NSApplication.shared.windows.first(where: { $0.title == "Rotation" }) else {
        return
    }
    guard let screen = window.screen ?? NSScreen.main else {
        return
    }

    let visibleFrame = screen.visibleFrame
    let windowSize = window.frame.size

    // Center horizontally, position near top (40pt below menu bar)
    let x = visibleFrame.midX - windowSize.width / 2
    let y = visibleFrame.maxY - windowSize.height - 40

    window.setFrameOrigin(CGPoint(x: x, y: y))
}
