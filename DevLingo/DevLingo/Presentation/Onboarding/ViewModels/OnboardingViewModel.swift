import SwiftUI

/// ViewModel for Onboarding flow.
@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Published

    @Published var currentPage = 0
    @Published var selectedLanguage: UserLanguage = .ptBR
    @Published var showTranslations = true
    @Published var notificationCount = 2
    @Published var enableNotifications = true

    // MARK: - Properties

    private let storage = StorageService.shared
    let totalPages = 3

    // MARK: - Actions

    func nextPage() {
        if currentPage < totalPages - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                currentPage += 1
            }
            HapticManager.lightImpact()
        }
    }

    func previousPage() {
        if currentPage > 0 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                currentPage -= 1
            }
            HapticManager.lightImpact()
        }
    }

    func completeOnboarding() {
        // Save preferences
        storage.setString(selectedLanguage.code, forKey: StorageKeys.selectedLanguage)
        storage.setBool(showTranslations, forKey: StorageKeys.showTranslations)
        storage.setBool(enableNotifications, forKey: StorageKeys.notificationsEnabled)
        storage.setInt(notificationCount, forKey: StorageKeys.phraseNotificationsCount)
        storage.setBool(true, forKey: StorageKeys.hasCompletedOnboarding)

        // Schedule phrase notifications
        if enableNotifications {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if granted {
                    let phrases = PhraseService.shared.allPhrases
                    NotificationService.shared.schedulePhraseNotifications(
                        phrases: phrases,
                        language: selectedLanguage,
                        count: notificationCount
                    )
                }
            }
        }

        HapticManager.success()
    }
}
