import Foundation

struct TimerSettings: Codable, Sendable, Equatable {
    var rotationDurationMinutes: Int
    var rotationDurationSeconds: Int?
    var breakAfterRotations: Int?
    var breakDurationMinutes: Int
    var playSoundOnRotation: Bool
    var speakAnnouncement: Bool
    var announcementTemplate: String
    var intellijIntegrationEnabled: Bool
    var intellijPluginURL: String

    init(
        rotationDurationMinutes: Int = 5,
        rotationDurationSeconds: Int? = nil,
        breakAfterRotations: Int? = nil,
        breakDurationMinutes: Int = 10,
        playSoundOnRotation: Bool = true,
        speakAnnouncement: Bool = true,
        announcementTemplate: String = "Time's up! {name} is now driving.",
        intellijIntegrationEnabled: Bool = false,
        intellijPluginURL: String = "http://localhost:8765"
    ) {
        self.rotationDurationMinutes = rotationDurationMinutes
        self.rotationDurationSeconds = rotationDurationSeconds
        self.breakAfterRotations = breakAfterRotations
        self.breakDurationMinutes = breakDurationMinutes
        self.playSoundOnRotation = playSoundOnRotation
        self.speakAnnouncement = speakAnnouncement
        self.announcementTemplate = announcementTemplate
        self.intellijIntegrationEnabled = intellijIntegrationEnabled
        self.intellijPluginURL = intellijPluginURL
    }

    var effectiveRotationSeconds: Int {
        if let seconds = rotationDurationSeconds {
            return seconds
        }
        return rotationDurationMinutes * 60
    }

    static let `default` = TimerSettings()
}
