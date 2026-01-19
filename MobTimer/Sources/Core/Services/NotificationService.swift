import Foundation
import UserNotifications
import AppKit

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

    func playSound() {
        NSSound.beep()
    }
}
