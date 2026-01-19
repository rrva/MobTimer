import SwiftUI

@main
struct MobTimerApp: App {
    @State private var viewModel = TimerViewModel()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some Scene {
        MenuBarExtra {
            TimerMenuView(viewModel: viewModel)
        } label: {
            Label(viewModel.statusText, systemImage: "person.3.fill")
        }
        .menuBarExtraStyle(.window)

        Window("Rotation", id: "rotation-window") {
            RotationWindowView(viewModel: viewModel)
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .windowLevel(.floating)
        .onChange(of: viewModel.showRotationWindow) { _, shouldShow in
            if shouldShow {
                openWindow(id: "rotation-window")
            } else {
                dismissWindow(id: "rotation-window")
            }
        }
    }
}
