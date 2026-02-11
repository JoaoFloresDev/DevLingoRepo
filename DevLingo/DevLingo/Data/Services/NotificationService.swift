import UserNotifications
import Foundation

/// Manages local notifications including phrase delivery.
final class NotificationService {
    // MARK: - Singleton

    static let shared = NotificationService()

    // MARK: - Properties

    private let center = UNUserNotificationCenter.current()
    private let storage = StorageService.shared

    // MARK: - Init

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Daily Reminder

    func scheduleDailyReminder(at hour: Int, minute: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [AppConstants.dailyReminderNotification])

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.daily_reminder.title")
        content.body = String(localized: "notification.daily_reminder.body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: AppConstants.dailyReminderNotification,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Phrase Notifications (1 to 4 per day)

    func schedulePhraseNotifications(phrases: [Phrase], language: UserLanguage, count: Int) {
        // Remove old phrase notifications
        let ids = (0..<4).map { "devlingo.phrase.notification.\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: ids)

        guard count > 0, !phrases.isEmpty else { return }

        // Spread notifications across waking hours (9am to 8pm)
        let startHour = 9
        let endHour = 20
        let interval = (endHour - startHour) / max(count, 1)

        let selectedPhrases = Array(phrases.shuffled().prefix(min(count, 4)))

        for (index, phrase) in selectedPhrases.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "💬 \(phrase.english)"
            content.body = phrase.context
            content.subtitle = phrase.translation(for: language)
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = startHour + (index * interval)
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "devlingo.phrase.notification.\(index)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    // MARK: - Streak Reminder

    func scheduleStreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [AppConstants.streakReminderNotification])

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.streak_reminder.title")
        content.body = String(localized: "notification.streak_reminder.body")
        content.sound = .default

        // 8 PM reminder
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: AppConstants.streakReminderNotification,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Cancel

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
