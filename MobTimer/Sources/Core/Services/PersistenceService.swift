import Foundation

actor PersistenceService {
    static let shared = PersistenceService()

    private let fileManager = FileManager.default
    private let participantsFileName = "participants.json"
    private let settingsFileName = "settings.json"

    private var applicationSupportDirectory: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[0].appendingPathComponent("MobTimer", isDirectory: true)

        if !fileManager.fileExists(atPath: appSupportURL.path) {
            try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        }

        return appSupportURL
    }

    private var participantsFileURL: URL {
        applicationSupportDirectory.appendingPathComponent(participantsFileName)
    }

    private var settingsFileURL: URL {
        applicationSupportDirectory.appendingPathComponent(settingsFileName)
    }

    private init() {}

    func saveParticipants(_ participants: [Participant]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(participants)
        try data.write(to: participantsFileURL, options: .atomic)
    }

    func loadParticipants() throws -> [Participant] {
        guard fileManager.fileExists(atPath: participantsFileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: participantsFileURL)
        let decoder = JSONDecoder()
        return try decoder.decode([Participant].self, from: data)
    }

    func saveSettings(_ settings: TimerSettings) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(settings)
        try data.write(to: settingsFileURL, options: .atomic)
    }

    func loadSettings() throws -> TimerSettings {
        guard fileManager.fileExists(atPath: settingsFileURL.path) else {
            return .default
        }

        let data = try Data(contentsOf: settingsFileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(TimerSettings.self, from: data)
    }
}
