import Foundation

/// UserDefaults storage keys.
enum StorageKeys {
    // MARK: - Onboarding
    static let hasCompletedOnboarding = "hasCompletedOnboarding"

    // MARK: - Language
    static let selectedLanguage = "selectedLanguage"

    // MARK: - Daily Phrases
    static let todayPhraseIDs = "todayPhraseIDs"
    static let todayDate = "todayDate"
    static let completedPhraseIDs = "completedPhraseIDs"
    static let savedPhraseIDs = "savedPhraseIDs"
    static let shownPhraseIDs = "shownPhraseIDs"

    // MARK: - Streak
    static let currentStreak = "currentStreak"
    static let longestStreak = "longestStreak"
    static let lastActiveDate = "lastActiveDate"

    // MARK: - Stats
    static let totalPhrasesLearned = "totalPhrasesLearned"
    static let phrasesByCategory = "phrasesByCategory"
    static let phrasesByDifficulty = "phrasesByDifficulty"

    // MARK: - Notifications
    static let notificationsEnabled = "notificationsEnabled"
    static let dailyReminderTime = "dailyReminderTime"

    // MARK: - Review
    static let appOpenCount = "appOpenCount"
    static let lastReviewRequestDate = "lastReviewRequestDate"
    static let hasRequestedReview = "hasRequestedReview"

    // MARK: - Appearance
    static let preferredColorScheme = "preferredColorScheme"
}
