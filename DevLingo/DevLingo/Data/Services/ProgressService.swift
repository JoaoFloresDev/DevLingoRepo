import Foundation

/// Result of registering a learned phrase against the streak.
struct StreakUpdate {
    let extended: Bool
    let days: Int
}

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
        storage.get(UserProgress.self, forKey: StorageKeys.userProgress) ?? UserProgress()
    }

    func saveProgress(_ progress: UserProgress) {
        storage.set(progress, forKey: StorageKeys.userProgress)
    }

    /// Marks a phrase learned and registers today as a practice day.
    /// Returns whether this practice extended the streak (first phrase of a new day)
    /// and the resulting streak length, so the caller can celebrate.
    @discardableResult
    func markPhraseCompleted(_ phrase: Phrase) -> StreakUpdate {
        var progress = getProgress()
        progress.markPhraseCompleted(phrase)
        let extended = progress.registerPracticeDay()
        saveProgress(progress)
        return StreakUpdate(extended: extended, days: progress.currentStreak)
    }

    func markPhraseUncompleted(_ phrase: Phrase) {
        var progress = getProgress()
        progress.markPhraseUncompleted(phrase)
        saveProgress(progress)
    }

    // MARK: - Stats

    var currentStreak: Int {
        getProgress().currentStreak
    }

    /// Streak for display — 0 when the chain is already broken.
    var displayStreak: Int {
        getProgress().displayStreak
    }

    /// Whether the user learned at least one phrase today.
    var practicedToday: Bool {
        getProgress().lastActiveDate?.isToday ?? false
    }

    var longestStreak: Int {
        getProgress().longestStreak
    }

    #if DEBUG
    /// QA hook — shifts the recorded last practice day back N days, so streak
    /// extension/break can be validated without waiting real days.
    func debugShiftLastPractice(byDays days: Int) {
        var progress = getProgress()
        guard let last = progress.lastActiveDate else { return }
        progress.lastActiveDate = Calendar.current.date(byAdding: .day, value: -days, to: last)
        saveProgress(progress)
    }
    #endif

    var totalPhrasesLearned: Int {
        getProgress().totalPhrasesLearned
    }

    var level: Int {
        getProgress().level
    }
}
