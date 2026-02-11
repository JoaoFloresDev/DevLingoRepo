import Foundation

/// Manages daily phrase selection and completion tracking.
final class DailyPhraseService {
    // MARK: - Singleton

    static let shared = DailyPhraseService()

    // MARK: - Properties

    private let storage = StorageService.shared
    private let phraseService = PhraseService.shared

    // MARK: - Init

    private init() {}

    // MARK: - Today's Phrases

    func getTodayPhrases() -> [Phrase] {
        let today = Date().dayString

        // Check if we already selected phrases for today
        if let savedDate = storage.getString(forKey: StorageKeys.todayDate),
           savedDate == today {
            let ids = storage.getStringArray(forKey: StorageKeys.todayPhraseIDs)
            if !ids.isEmpty {
                return phraseService.phrases(by: ids)
            }
        }

        // Select new phrases for today
        let phrases = selectDailyPhrases()
        let ids = phrases.map { $0.id }

        storage.setString(today, forKey: StorageKeys.todayDate)
        storage.setStringArray(ids, forKey: StorageKeys.todayPhraseIDs)

        // Track shown phrases
        var shownIDs = storage.getStringSet(forKey: StorageKeys.shownPhraseIDs)
        ids.forEach { shownIDs.insert($0) }
        storage.setStringSet(shownIDs, forKey: StorageKeys.shownPhraseIDs)

        return phrases
    }

    // MARK: - Selection Algorithm

    private func selectDailyPhrases() -> [Phrase] {
        let shownIDs = storage.getStringSet(forKey: StorageKeys.shownPhraseIDs)
        let allPhrases = phraseService.allPhrases

        // Filter out already shown phrases (reset if pool exhausted)
        var available = allPhrases.filter { !shownIDs.contains($0.id) }
        if available.count < AppConstants.phrasesPerDay {
            storage.setStringSet([], forKey: StorageKeys.shownPhraseIDs)
            available = allPhrases
        }

        // Group by difficulty
        let easy = available.filter { $0.difficulty == .easy }.shuffled()
        let medium = available.filter { $0.difficulty == .medium }.shuffled()
        let hard = available.filter { $0.difficulty == .hard }.shuffled()

        // Pick: 4 easy, 4 medium, 2 hard
        var selected: [Phrase] = []
        selected.append(contentsOf: easy.prefix(AppConstants.easyPerDay))
        selected.append(contentsOf: medium.prefix(AppConstants.mediumPerDay))
        selected.append(contentsOf: hard.prefix(AppConstants.hardPerDay))

        // Ensure category balance (max 2 from same category)
        selected = balanceCategories(selected, available: available)

        return selected.shuffled()
    }

    private func balanceCategories(_ phrases: [Phrase], available: [Phrase]) -> [Phrase] {
        var result = phrases
        var categoryCounts: [PhraseCategory: Int] = [:]

        for phrase in result {
            categoryCounts[phrase.category, default: 0] += 1
        }

        // Replace phrases from over-represented categories
        let usedIDs = Set(result.map { $0.id })
        for (category, count) in categoryCounts where count > 2 {
            let excess = count - 2
            let toRemove = result.filter { $0.category == category }.suffix(excess)
            result.removeAll { toRemove.contains($0) }

            // Find replacements from under-represented categories
            let underRepresented = PhraseCategory.allCases.filter { (categoryCounts[$0] ?? 0) == 0 }
            for cat in underRepresented.prefix(excess) {
                if let replacement = available.first(where: { $0.category == cat && !usedIDs.contains($0.id) }) {
                    result.append(replacement)
                }
            }
        }

        // Ensure we have exactly 10
        while result.count < AppConstants.phrasesPerDay {
            if let extra = available.first(where: { !Set(result.map { $0.id }).contains($0.id) }) {
                result.append(extra)
            } else {
                break
            }
        }

        return Array(result.prefix(AppConstants.phrasesPerDay))
    }

    // MARK: - Completion

    func markCompleted(_ phraseID: String) {
        var completed = storage.getStringSet(forKey: StorageKeys.completedPhraseIDs)
        completed.insert(phraseID)
        storage.setStringSet(completed, forKey: StorageKeys.completedPhraseIDs)
    }

    func isCompleted(_ phraseID: String) -> Bool {
        storage.getStringSet(forKey: StorageKeys.completedPhraseIDs).contains(phraseID)
    }

    func todayCompletedCount() -> Int {
        let todayIDs = Set(storage.getStringArray(forKey: StorageKeys.todayPhraseIDs))
        let completed = storage.getStringSet(forKey: StorageKeys.completedPhraseIDs)
        return todayIDs.intersection(completed).count
    }

    // MARK: - Saved/Favorites

    func toggleSaved(_ phraseID: String) {
        var saved = storage.getStringSet(forKey: StorageKeys.savedPhraseIDs)
        if saved.contains(phraseID) {
            saved.remove(phraseID)
        } else {
            saved.insert(phraseID)
        }
        storage.setStringSet(saved, forKey: StorageKeys.savedPhraseIDs)
    }

    func isSaved(_ phraseID: String) -> Bool {
        storage.getStringSet(forKey: StorageKeys.savedPhraseIDs).contains(phraseID)
    }

    func savedPhrases() -> [Phrase] {
        let ids = Array(storage.getStringSet(forKey: StorageKeys.savedPhraseIDs))
        return phraseService.phrases(by: ids)
    }

    // MARK: - History

    func getHistory() -> [DailyPhraseSet] {
        storage.get([DailyPhraseSet].self, forKey: "phraseHistory") ?? []
    }

    func saveTodayToHistory() {
        let today = Date()
        let ids = storage.getStringArray(forKey: StorageKeys.todayPhraseIDs)
        let completed = storage.getStringSet(forKey: StorageKeys.completedPhraseIDs)
        let todayCompleted = Set(ids).intersection(completed)

        let dailySet = DailyPhraseSet(
            id: today.dayString,
            date: today,
            phraseIDs: ids,
            completedIDs: todayCompleted
        )

        var history = getHistory()
        // Replace if today already exists
        history.removeAll { $0.id == dailySet.id }
        history.append(dailySet)

        // Keep last 365 days
        if history.count > 365 {
            history = Array(history.suffix(365))
        }

        storage.set(history, forKey: "phraseHistory")
    }
}
