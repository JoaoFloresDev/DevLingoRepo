import SwiftUI

/// ViewModel for the Home screen — today's phrases.
final class HomeViewModel: ObservableObject {
    // MARK: - Published

    @Published var todayPhrases: [Phrase] = []
    @Published var completedIDs: Set<String> = []
    @Published var savedIDs: Set<String> = []
    @Published var isLoading = true
    @Published var showTranslations: Bool

    // MARK: - Properties

    private let dailyService = DailyPhraseService.shared
    private let progressService = ProgressService.shared
    private let storage = StorageService.shared
    private var hasLoadedOnce = false

    var progress: UserProgress {
        progressService.getProgress()
    }

    var completedCount: Int {
        let todayIDs = Set(todayPhrases.map { $0.id })
        return todayIDs.intersection(completedIDs).count
    }

    var todayProgress: Double {
        guard !todayPhrases.isEmpty else { return 0 }
        return Double(completedCount) / Double(todayPhrases.count)
    }

    // MARK: - Init

    init() {
        showTranslations = storage.getBool(forKey: "showTranslations")
    }

    // MARK: - Data

    func loadData() {
        if !hasLoadedOnce {
            isLoading = true
            hasLoadedOnce = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.fetchPhrases()
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.isLoading = false
                }
            }
        } else {
            fetchPhrases()
        }
    }

    private func fetchPhrases() {
        todayPhrases = dailyService.getTodayPhrases()
        completedIDs = storage.getStringSet(forKey: StorageKeys.completedPhraseIDs)
        savedIDs = storage.getStringSet(forKey: StorageKeys.savedPhraseIDs)
        progressService.updateStreak()
        dailyService.saveTodayToHistory()
    }

    // MARK: - Actions

    func markCompleted(_ phrase: Phrase) {
        dailyService.markCompleted(phrase.id)
        completedIDs.insert(phrase.id)
        progressService.markPhraseCompleted(phrase)
        HapticManager.success()
    }

    func toggleSaved(_ phrase: Phrase) {
        dailyService.toggleSaved(phrase.id)
        if savedIDs.contains(phrase.id) {
            savedIDs.remove(phrase.id)
        } else {
            savedIDs.insert(phrase.id)
        }
        HapticManager.lightImpact()
    }

    func isCompleted(_ phrase: Phrase) -> Bool {
        completedIDs.contains(phrase.id)
    }

    func isSaved(_ phrase: Phrase) -> Bool {
        savedIDs.contains(phrase.id)
    }

    func toggleTranslations() {
        showTranslations.toggle()
        storage.setBool(showTranslations, forKey: "showTranslations")
        HapticManager.selection()
    }

    func speak(_ phrase: Phrase) {
        SpeechManager.shared.speak(phrase.english)
        HapticManager.lightImpact()
    }

    // MARK: - Language

    var userLanguage: UserLanguage {
        guard let code = storage.getString(forKey: StorageKeys.selectedLanguage),
              let lang = UserLanguage(rawValue: code) else {
            return .ptBR
        }
        return lang
    }
}
