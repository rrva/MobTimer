import Foundation

enum TimerState: Sendable, Equatable {
    case stopped
    case running
    case paused
    case onBreak
    case awaitingDriver
}
