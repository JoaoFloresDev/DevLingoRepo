import Foundation

/// User progress and statistics.
struct UserProgress: Codable {
    // MARK: - Properties

    var totalPhrasesLearned: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDate: Date?
    var phrasesByCategory: [String: Int] = [:]
    var phrasesByDifficulty: [String: Int] = [:]

    // MARK: - Computed

    var level: Int {
        totalPhrasesLearned / 50 + 1
    }

    var levelTitle: String {
        switch level {
        case 1...2: return String(localized: "level.beginner")
        case 3...5: return String(localized: "level.elementary")
        case 6...10: return String(localized: "level.intermediate")
        case 11...20: return String(localized: "level.advanced")
        default: return String(localized: "level.fluent")
        }
    }

    var phrasesToNextLevel: Int {
        let nextLevelThreshold = level * 50
        return nextLevelThreshold - totalPhrasesLearned
    }

    var levelProgress: Double {
        let base = (level - 1) * 50
        let current = totalPhrasesLearned - base
        return Double(current) / 50.0
    }

    // MARK: - Mutations

    mutating func markPhraseCompleted(_ phrase: Phrase) {
        totalPhrasesLearned += 1

        let catKey = phrase.category.rawValue
        phrasesByCategory[catKey] = (phrasesByCategory[catKey] ?? 0) + 1

        let diffKey = phrase.difficulty.rawValue
        phrasesByDifficulty[diffKey] = (phrasesByDifficulty[diffKey] ?? 0) + 1
    }

    mutating func markPhraseUncompleted(_ phrase: Phrase) {
        totalPhrasesLearned = max(0, totalPhrasesLearned - 1)

        let catKey = phrase.category.rawValue
        phrasesByCategory[catKey] = max(0, (phrasesByCategory[catKey] ?? 0) - 1)

        let diffKey = phrase.difficulty.rawValue
        phrasesByDifficulty[diffKey] = max(0, (phrasesByDifficulty[diffKey] ?? 0) - 1)
    }

    /// The streak as the user should see it RIGHT NOW — 0 when the chain is already
    /// broken (last practice was before yesterday), even before the next practice
    /// resets the stored counter.
    var displayStreak: Int {
        guard let last = lastActiveDate else { return 0 }
        let days = Date().daysFrom(last)
        return days <= 1 ? currentStreak : 0
    }

    /// Registers today as a practice day (date-only, device calendar/timezone).
    /// Called when a phrase is learned — the streak is defined by practice days,
    /// never by merely opening the app.
    /// Returns `true` when this practice EXTENDED the streak (first phrase of a new day).
    @discardableResult
    mutating func registerPracticeDay() -> Bool {
        let today = Date().startOfDay
        guard let lastDate = lastActiveDate?.startOfDay else {
            currentStreak = 1
            longestStreak = max(longestStreak, 1)
            lastActiveDate = today
            return true
        }

        let daysDiff = today.daysFrom(lastDate)

        if daysDiff == 0 {
            // Already counted today.
            return false
        }
        if daysDiff < 0 {
            // Clock/timezone moved backwards — never punish the user for it.
            return false
        }

        currentStreak = daysDiff == 1 ? currentStreak + 1 : 1
        longestStreak = max(longestStreak, currentStreak)
        lastActiveDate = today
        return true
    }
}
