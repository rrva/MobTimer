import Foundation
import UserNotifications
import AppKit

enum SoundEffect: String, Codable, CaseIterable, Sendable {
    case none = "None"
    case subtle = "Subtle Pop"
    case chime = "Gentle Chime"
    case bell = "Soft Bell"
    case glass = "Glass"
    case ping = "Ping"
    case beep = "System Beep"

    var systemSoundName: String? {
        switch self {
        case .none: return nil
        case .subtle: return "Pop"
        case .chime: return "Blow"
        case .bell: return "Sosumi"
        case .glass: return "Glass"
        case .ping: return "Ping"
        case .beep: return "Basso"
        }
    }
}

actor NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
            return granted
        } catch {
            return false
        }
    }

    func sendRotationNotification(driverName: String, playSound: Bool) async {
        let content = UNMutableNotificationContent()
        content.title = "Rotation Time!"
        content.body = "\(driverName) is now driving."
        if playSound {
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // Notification failed, continue silently
        }
    }

    func sendBreakNotification(durationMinutes: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Break Time!"
        content.body = "Take a \(durationMinutes)-minute break."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // Notification failed, continue silently
        }
    }

    nonisolated func playSound(_ effect: SoundEffect) {
        guard let soundName = effect.systemSoundName else { return }

        DispatchQueue.main.async {
            if let sound = NSSound(named: NSSound.Name(soundName)) {
                sound.play()
            } else {
                // Fallback to beep if sound not found
                NSSound.beep()
            }
        }
    }

    func playSound() {
        NSSound.beep()
    }
}
