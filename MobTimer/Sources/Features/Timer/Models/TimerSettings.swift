import Foundation

struct TimerSettings: Codable, Sendable, Equatable {
    var rotationDurationMinutes: Int
    var rotationDurationSeconds: Int?
    var breakAfterRotations: Int?
    var breakDurationMinutes: Int
    var playSoundOnRotation: Bool
    var speakAnnouncement: Bool
    var announcementTemplate: String
    var randomizeRotation: Bool
    var useSecondsForTesting: Bool
    var enableGitCoauthors: Bool

    init(
        rotationDurationMinutes: Int = 5,
        rotationDurationSeconds: Int? = nil,
        breakAfterRotations: Int? = nil,
        breakDurationMinutes: Int = 10,
        playSoundOnRotation: Bool = true,
        speakAnnouncement: Bool = true,
        announcementTemplate: String = "Time's up! {name} is now driving.",
        randomizeRotation: Bool = false,
        useSecondsForTesting: Bool = false,
        enableGitCoauthors: Bool = false
    ) {
        self.rotationDurationMinutes = rotationDurationMinutes
        self.rotationDurationSeconds = rotationDurationSeconds
        self.breakAfterRotations = breakAfterRotations
        self.breakDurationMinutes = breakDurationMinutes
        self.playSoundOnRotation = playSoundOnRotation
        self.speakAnnouncement = speakAnnouncement
        self.announcementTemplate = announcementTemplate
        self.randomizeRotation = randomizeRotation
        self.useSecondsForTesting = useSecondsForTesting
        self.enableGitCoauthors = enableGitCoauthors
    }

    var effectiveRotationSeconds: Int {
        if let seconds = rotationDurationSeconds {
            return seconds
        }
        return rotationDurationMinutes * 60
    }

    static let `default` = TimerSettings()
}
