import Foundation

/// Manages user progress and streak tracking.
final class ProgressService {
    // MARK: - Singleton

    static let shared = ProgressService()

    // MARK: - Properties

    private let storage = StorageService.shared

    // MARK: - Init

    private init() {}

    // MARK: - Progress

    func getProgress() -> UserProgress {
        storage.get(UserProgress.self, forKey: "userProgress") ?? UserProgress()
    }

    func saveProgress(_ progress: UserProgress) {
        storage.set(progress, forKey: "userProgress")
    }

    func markPhraseCompleted(_ phrase: Phrase) {
        var progress = getProgress()
        progress.markPhraseCompleted(phrase)
        progress.updateStreak()
        saveProgress(progress)
    }

    func updateStreak() {
        var progress = getProgress()
        progress.updateStreak()
        saveProgress(progress)
    }

    // MARK: - Stats

    var currentStreak: Int {
        getProgress().currentStreak
    }

    var longestStreak: Int {
        getProgress().longestStreak
    }

    var totalPhrasesLearned: Int {
        getProgress().totalPhrasesLearned
    }

    var level: Int {
        getProgress().level
    }
}
