import SwiftUI

/// ViewModel for the Home screen — today's phrases.
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published

    @Published var todayPhrases: [Phrase] = []
    @Published var completedIDs: Set<String> = []
    @Published var savedIDs: Set<String> = []
    @Published var isLoading = true
    @Published var showTranslations: Bool
    @Published var streakJustExtended = false
    @Published var showReminderCard = false

    // MARK: - Properties

    private let dailyService = DailyPhraseService.shared
    private let progressService = ProgressService.shared
    private let storage = StorageService.shared
    private var hasLoadedOnce = false
    private var hasTriggeredReviewThisSession = false

    var progress: UserProgress {
        progressService.getProgress()
    }

    /// Streak for the home counter — 0 once the chain is broken.
    var streakDays: Int {
        progressService.displayStreak
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
        showTranslations = storage.getBool(forKey: StorageKeys.showTranslations)
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
        dailyService.saveTodayToHistory()

        // Keep the streak reminder in sync (drops today's if already practiced)
        // and surface the opt-in card while the reminder is off.
        StreakReminderService.shared.reschedule()
        refreshReminderCard()

        // Schedule phrase notifications with today's phrases
        let notifCount = max(1, storage.getInt(forKey: StorageKeys.phraseNotificationsCount))
        if storage.getBool(forKey: StorageKeys.notificationsEnabled) {
            NotificationService.shared.schedulePhraseNotifications(
                phrases: todayPhrases,
                language: userLanguage,
                count: notifCount
            )
        }

        // Update widget with today's phrases
        WidgetService.shared.updateWidget(phrases: todayPhrases, language: userLanguage)
    }

    // MARK: - Actions

    func markCompleted(_ phrase: Phrase) {
        dailyService.markCompleted(phrase.id)
        completedIDs.insert(phrase.id)
        let streakUpdate = progressService.markPhraseCompleted(phrase)
        AnalyticsService.phraseLearned(category: phrase.category.rawValue, difficulty: phrase.difficulty.rawValue)
        HapticManager.success()

        if streakUpdate.extended {
            celebrateStreak(days: streakUpdate.days)
        }

        // First phrase of the day silences today's streak reminder.
        StreakReminderService.shared.reschedule()

        if !hasTriggeredReviewThisSession {
            hasTriggeredReviewThisSession = true
            ReviewService.shared.requestReviewIfEligible()
        }
    }

    // MARK: - Streak

    private func celebrateStreak(days: Int) {
        AnalyticsService.streakExtended(days: days)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            streakJustExtended = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            HapticManager.mediumImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.streakJustExtended = false
            }
        }
    }

    // MARK: - Streak Reminder

    func refreshReminderCard() {
        let reminder = StreakReminderService.shared
        showReminderCard = !reminder.isEnabled && !reminder.isCardDismissed
    }

    func dismissReminderCard() {
        StreakReminderService.shared.dismissCard()
        withAnimation(.easeOut(duration: 0.25)) {
            showReminderCard = false
        }
        HapticManager.selection()
    }

    func markUncompleted(_ phrase: Phrase) {
        dailyService.markUncompleted(phrase.id)
        completedIDs.remove(phrase.id)
        progressService.markPhraseUncompleted(phrase)
        HapticManager.lightImpact()
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
        storage.setBool(showTranslations, forKey: StorageKeys.showTranslations)
        HapticManager.selection()
    }

    func speak(_ phrase: Phrase) {
        SpeechManager.shared.speak(phrase.english)
        AnalyticsService.phraseListened(category: phrase.category.rawValue)
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
