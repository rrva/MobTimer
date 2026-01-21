import Foundation

enum PersistenceError: LocalizedError {
    case applicationSupportNotFound
    case directoryCreationFailed(Error)
    case encodingFailed(Error)
    case decodingFailed(Error)
    case writeFailed(Error)
    case readFailed(Error)

    var errorDescription: String? {
        switch self {
        case .applicationSupportNotFound:
            return "Could not find Application Support directory"
        case .directoryCreationFailed(let error):
            return "Failed to create storage directory: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .writeFailed(let error):
            return "Failed to write file: \(error.localizedDescription)"
        case .readFailed(let error):
            return "Failed to read file: \(error.localizedDescription)"
        }
    }
}

actor PersistenceService {
    static let shared = PersistenceService()

    private let fileManager = FileManager.default
    private let participantsFileName = "participants.json"
    private let settingsFileName = "settings.json"

    private var applicationSupportDirectory: URL {
        get throws {
            guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw PersistenceError.applicationSupportNotFound
            }
            let mobTimerURL = appSupportURL.appendingPathComponent("MobTimer", isDirectory: true)

            if !fileManager.fileExists(atPath: mobTimerURL.path) {
                do {
                    try fileManager.createDirectory(at: mobTimerURL, withIntermediateDirectories: true)
                } catch {
                    throw PersistenceError.directoryCreationFailed(error)
                }
            }

            return mobTimerURL
        }
    }

    private func participantsFileURL() throws -> URL {
        return try applicationSupportDirectory.appendingPathComponent(participantsFileName)
    }

    private func settingsFileURL() throws -> URL {
        return try applicationSupportDirectory.appendingPathComponent(settingsFileName)
    }

    private init() {}

    func saveParticipants(_ participants: [Participant]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data: Data
        do {
            data = try encoder.encode(participants)
        } catch {
            throw PersistenceError.encodingFailed(error)
        }
        do {
            try data.write(to: participantsFileURL(), options: .atomic)
        } catch {
            throw PersistenceError.writeFailed(error)
        }
    }

    func loadParticipants() throws -> [Participant] {
        let fileURL = try participantsFileURL()
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw PersistenceError.readFailed(error)
        }
        do {
            return try JSONDecoder().decode([Participant].self, from: data)
        } catch {
            throw PersistenceError.decodingFailed(error)
        }
    }

    func saveSettings(_ settings: TimerSettings) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data: Data
        do {
            data = try encoder.encode(settings)
        } catch {
            throw PersistenceError.encodingFailed(error)
        }
        do {
            try data.write(to: settingsFileURL(), options: .atomic)
        } catch {
            throw PersistenceError.writeFailed(error)
        }
    }

    func loadSettings() throws -> TimerSettings {
        let fileURL = try settingsFileURL()
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return .default
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw PersistenceError.readFailed(error)
        }
        do {
            return try JSONDecoder().decode(TimerSettings.self, from: data)
        } catch {
            throw PersistenceError.decodingFailed(error)
        }
    }

    func writeActiveMobsters(_ participants: [Participant]) throws {
        let coAuthorLines = participants
            .filter { !$0.isAway && !$0.email.isEmpty }
            .map { participant in
                "Co-Authored-By: \(participant.name) <\(participant.email)>"
            }
        let content = coAuthorLines.joined(separator: "\n")
        let filePath = try applicationSupportDirectory.appendingPathComponent("active-mobsters")
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            throw PersistenceError.writeFailed(error)
        }
    }
}
