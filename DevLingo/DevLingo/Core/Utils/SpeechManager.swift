import AVFoundation

/// Text-to-speech manager for phrase pronunciation.
final class SpeechManager {
    // MARK: - Singleton

    static let shared = SpeechManager()

    // MARK: - Properties

    private let synthesizer = AVSpeechSynthesizer()

    // MARK: - Init

    private init() {}

    // MARK: - Public

    func speak(_ text: String, language: String = "en-US") {
        guard FeatureFlags.speechEnabled else { return }
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}
