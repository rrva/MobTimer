import Foundation
import AVFoundation

actor SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func speakRotationAnnouncement(template: String, driverName: String) {
        let message = template.replacingOccurrences(of: "{name}", with: driverName)
        speak(text: message)
    }

    func speakBreakAnnouncement(durationMinutes: Int) {
        speak(text: "Time for a \(durationMinutes) minute break.")
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
