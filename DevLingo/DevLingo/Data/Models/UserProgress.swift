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

    mutating func updateStreak() {
        let today = Date().startOfDay
        guard let lastDate = lastActiveDate?.startOfDay else {
            currentStreak = 1
            longestStreak = max(longestStreak, 1)
            lastActiveDate = today
            return
        }

        let daysDiff = today.daysFrom(lastDate)

        if daysDiff == 0 {
            // Same day, no change
            return
        } else if daysDiff == 1 {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastActiveDate = today
    }
}
