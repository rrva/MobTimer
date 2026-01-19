import Foundation
import SwiftUI

@MainActor
@Observable
final class TimerViewModel {
    var participants: [Participant] = []
    var settings: TimerSettings = .default
    var state: TimerState = .stopped
    var remainingSeconds: Int = 0
    var currentDriverIndex: Int = 0
    var rotationCount: Int = 0
    var showingSettings: Bool = false
    var editingParticipantID: UUID?
    var showRotationFlash: Bool = false
    var showRotationWindow: Bool = false
    private(set) var pausedFromAwaitingDriver: Bool = false

    private var timerTask: Task<Void, Never>?
    private let notificationService = NotificationService.shared
    private let speechService = SpeechService.shared
    private let persistenceService = PersistenceService.shared

    static var isTestingMode: Bool {
        CommandLine.arguments.contains("--testing") || CommandLine.arguments.contains("-testing")
    }

    var activeParticipants: [Participant] {
        participants.filter { !$0.isAway }
    }

    var currentDriver: Participant? {
        guard !activeParticipants.isEmpty else { return nil }
        let index = currentDriverIndex % activeParticipants.count
        return activeParticipants[index]
    }

    var currentNavigator: Participant? {
        guard activeParticipants.count > 1 else { return nil }
        let nextIndex = (currentDriverIndex + 1) % activeParticipants.count
        return activeParticipants[nextIndex]
    }

    var nextDriver: Participant? {
        guard activeParticipants.count > 2 else { return nil }
        let upNextIndex = (currentDriverIndex + 2) % activeParticipants.count
        return activeParticipants[upNextIndex]
    }

    var statusText: String {
        switch state {
        case .stopped:
            return "--:--"
        case .running, .paused:
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        case .onBreak:
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            return String(format: "B %02d:%02d", minutes, seconds)
        case .awaitingDriver:
            return "ROTATE"
        }
    }

    var progress: Double {
        guard state != .stopped && state != .awaitingDriver else { return 0 }

        let totalSeconds: Int
        if state == .onBreak {
            totalSeconds = settings.breakDurationMinutes * 60
        } else {
            totalSeconds = settings.effectiveRotationSeconds
        }

        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var canStart: Bool {
        !activeParticipants.isEmpty && state == .stopped
    }

    var rotationsUntilBreak: Int? {
        guard let breakAfter = settings.breakAfterRotations else { return nil }
        return breakAfter - (rotationCount % breakAfter)
    }

    init() {
        Task {
            await loadData()
        }
    }

    func loadData() async {
        do {
            participants = try await persistenceService.loadParticipants()
            settings = try await persistenceService.loadSettings()
        } catch {
            participants = []
            settings = .default
        }
    }

    func saveParticipants() {
        Task {
            try? await persistenceService.saveParticipants(participants)
        }
    }

    func saveSettings() {
        Task {
            try? await persistenceService.saveSettings(settings)
        }
    }

    func addParticipant(name: String) {
        let participant = Participant(name: name)
        participants.append(participant)
        saveParticipants()
    }

    func removeParticipant(at indices: IndexSet) {
        participants.remove(atOffsets: indices)
        saveParticipants()
    }

    func removeParticipant(_ participant: Participant) {
        participants.removeAll { $0.id == participant.id }
        saveParticipants()
    }

    func updateParticipant(_ participant: Participant) {
        if let index = participants.firstIndex(where: { $0.id == participant.id }) {
            let wasCurrentDriver = currentDriver?.id == participant.id
            participants[index] = participant

            // If current driver is now away, rotate to next active
            if wasCurrentDriver && participant.isAway {
                advanceToNextDriver()
            }

            saveParticipants()
        }
    }

    func moveParticipants(from source: IndexSet, to destination: Int) {
        participants.move(fromOffsets: source, toOffset: destination)
        saveParticipants()
    }

    func moveParticipant(_ participantID: UUID, toBeforeParticipant targetID: UUID) {
        guard let sourceIndex = participants.firstIndex(where: { $0.id == participantID }),
              let targetIndex = participants.firstIndex(where: { $0.id == targetID }),
              sourceIndex != targetIndex else { return }

        let participant = participants.remove(at: sourceIndex)
        let newTargetIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        participants.insert(participant, at: newTargetIndex)
        saveParticipants()
    }

    func moveParticipantToEnd(_ participantID: UUID) {
        guard let sourceIndex = participants.firstIndex(where: { $0.id == participantID }) else { return }
        let participant = participants.remove(at: sourceIndex)
        participants.append(participant)
        saveParticipants()
    }

    func moveParticipantUp(_ participantID: UUID) {
        guard let index = participants.firstIndex(where: { $0.id == participantID }),
              index > 0 else { return }
        participants.swapAt(index, index - 1)
        saveParticipants()
    }

    func moveParticipantDown(_ participantID: UUID) {
        guard let index = participants.firstIndex(where: { $0.id == participantID }),
              index < participants.count - 1 else { return }
        participants.swapAt(index, index + 1)
        saveParticipants()
    }

    func toggleAway(for participant: Participant) {
        var updated = participant
        updated.isAway = !participant.isAway
        updateParticipant(updated)
    }

    func start() {
        guard canStart else { return }
        remainingSeconds = settings.effectiveRotationSeconds
        state = .running
        startTimer()

        Task {
            _ = await notificationService.requestAuthorization()
        }
    }

    func pause() {
        guard state == .running || state == .onBreak || state == .awaitingDriver else { return }

        // Track if we're pausing from awaiting driver state
        pausedFromAwaitingDriver = (state == .awaitingDriver)
        if pausedFromAwaitingDriver {
            showRotationWindow = false
        }

        timerTask?.cancel()
        timerTask = nil
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }

        // If we paused from awaiting driver, restore that state
        if pausedFromAwaitingDriver {
            pausedFromAwaitingDriver = false
            state = .awaitingDriver
            showRotationWindow = true
        } else {
            state = .running
            startTimer()
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        state = .stopped
        remainingSeconds = 0
        rotationCount = 0
        showRotationWindow = false
        pausedFromAwaitingDriver = false
    }

    func skip() {
        rotateToNext()
    }

    func acknowledgeRotation() {
        guard state == .awaitingDriver else { return }
        showRotationWindow = false
        remainingSeconds = settings.effectiveRotationSeconds
        state = .running
        startTimer()
    }

    func skipTurn() {
        guard state == .awaitingDriver else { return }
        // Advance to next driver while staying in awaiting state
        advanceToNextDriver()
        triggerRotationFlash()
        announceRotation()
    }

    func reset() {
        stop()
        currentDriverIndex = 0
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }

                await MainActor.run {
                    self?.tick()
                }
            }
        }
    }

    private func tick() {
        guard state == .running || state == .onBreak else { return }

        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            handleTimerComplete()
        }
    }

    private func handleTimerComplete() {
        if state == .onBreak {
            endBreak()
        } else {
            rotateToNext()
        }
    }

    private func rotateToNext() {
        rotationCount += 1
        advanceToNextDriver()

        // Trigger visual flash
        triggerRotationFlash()

        // Check if break is due
        if let breakAfter = settings.breakAfterRotations,
           rotationCount > 0,
           rotationCount % breakAfter == 0 {
            startBreak()
        } else {
            // Pause timer and show rotation window for acknowledgment
            timerTask?.cancel()
            timerTask = nil
            state = .awaitingDriver
            showRotationWindow = true
            announceRotation()
        }
    }

    private func triggerRotationFlash() {
        showRotationFlash = true
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            showRotationFlash = false
        }
    }

    private func advanceToNextDriver() {
        guard !activeParticipants.isEmpty else { return }
        currentDriverIndex = (currentDriverIndex + 1) % activeParticipants.count
    }

    private func announceRotation() {
        guard let driver = currentDriver else { return }

        Task {
            await notificationService.sendRotationNotification(
                driverName: driver.name,
                playSound: settings.playSoundOnRotation
            )

            if settings.speakAnnouncement {
                await speechService.speakRotationAnnouncement(
                    template: settings.announcementTemplate,
                    driverName: driver.name
                )
            }
        }
    }

    private func startBreak() {
        state = .onBreak
        remainingSeconds = settings.breakDurationMinutes * 60

        Task {
            await notificationService.sendBreakNotification(
                durationMinutes: settings.breakDurationMinutes
            )

            if settings.speakAnnouncement {
                await speechService.speakBreakAnnouncement(
                    durationMinutes: settings.breakDurationMinutes
                )
            }
        }
    }

    private func endBreak() {
        state = .running
        triggerRotationFlash()
        announceRotation()
        remainingSeconds = settings.effectiveRotationSeconds
    }

    func updateSettings(_ newSettings: TimerSettings) {
        settings = newSettings
        saveSettings()
    }

    func resetSettingsToDefault() {
        settings = .default
        saveSettings()
    }
}
