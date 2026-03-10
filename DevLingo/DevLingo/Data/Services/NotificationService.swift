import UserNotifications
import Foundation

/// Manages local notifications — all notifications show phrases.
final class NotificationService {
    // MARK: - Singleton

    static let shared = NotificationService()

    // MARK: - Properties

    private let center = UNUserNotificationCenter.current()

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

    // MARK: - Schedule Phrase Notifications

    func schedulePhraseNotifications(phrases: [Phrase], language: UserLanguage, count: Int) {
        center.removeAllPendingNotificationRequests()

        guard count > 0, !phrases.isEmpty else { return }

        let clampedCount = min(count, 4)

        // Spread notifications across waking hours
        let hours: [Int] = {
            switch clampedCount {
            case 1: return [10]
            case 2: return [9, 18]
            case 3: return [9, 14, 19]
            case 4: return [9, 12, 16, 20]
            default: return [10]
            }
        }()

        // Schedule for the next 7 days with different phrases each day
        let shuffled = phrases.shuffled()
        var phraseIndex = 0

        for day in 0..<7 {
            for (slotIndex, hour) in hours.enumerated() {
                let phrase = shuffled[phraseIndex % shuffled.count]
                phraseIndex += 1

                let content = UNMutableNotificationContent()
                content.title = "DevLingo"
                content.body = phrase.english
                content.sound = .default

                guard let fireDate = Calendar.current.date(
                    byAdding: .day, value: day, to: Date()
                ) else { continue }

                var dateComponents = DateComponents()
                dateComponents.year = Calendar.current.component(.year, from: fireDate)
                dateComponents.month = Calendar.current.component(.month, from: fireDate)
                dateComponents.day = Calendar.current.component(.day, from: fireDate)
                dateComponents.hour = hour
                dateComponents.minute = 0

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents, repeats: false
                )
                let request = UNNotificationRequest(
                    identifier: "devlingo.phrase.\(day).\(slotIndex)",
                    content: content,
                    trigger: trigger
                )

                center.add(request)
            }
        }
    }

    // MARK: - Cancel

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
