import Foundation
import UserNotifications

/// Schedules the daily "keep your streak" local reminder.
///
/// One-shot requests for the next 7 days are kept in sync on every app open,
/// after every practice and after every preference change — today's reminder is
/// dropped as soon as the user has already practiced, and re-created for the
/// following days. Identifiers are date-stamped so reconciliation is deterministic.
final class StreakReminderService {
    // MARK: - Singleton

    static let shared = StreakReminderService()

    // MARK: - Constants

    static let identifierPrefix = "devlingo.streak.reminder."
    static let defaultHour = 19
    static let defaultMinute = 0

    // MARK: - Properties

    private let center = UNUserNotificationCenter.current()
    private let storage = StorageService.shared

    // MARK: - Init

    private init() {}

    // MARK: - Preferences

    var isEnabled: Bool {
        storage.getBool(forKey: StorageKeys.streakReminderEnabled)
    }

    var isCardDismissed: Bool {
        storage.getBool(forKey: StorageKeys.streakReminderCardDismissed)
    }

    func dismissCard() {
        storage.setBool(true, forKey: StorageKeys.streakReminderCardDismissed)
    }

    /// Stored as "HH:mm"; defaults to 19:00 when never set.
    var reminderTime: (hour: Int, minute: Int) {
        guard let raw = storage.getString(forKey: StorageKeys.streakReminderTime) else {
            return (Self.defaultHour, Self.defaultMinute)
        }
        let parts = raw.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2,
              let hour = parts.first, (0...23).contains(hour),
              let minute = parts.last, (0...59).contains(minute) else {
            return (Self.defaultHour, Self.defaultMinute)
        }
        return (hour, minute)
    }

    /// The reminder time as a Date (today), for binding into a DatePicker.
    var reminderTimeAsDate: Date {
        let time = reminderTime
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = time.hour
        comps.minute = time.minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    func setTime(from date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = comps.hour ?? Self.defaultHour
        let minute = comps.minute ?? Self.defaultMinute
        storage.setString(String(format: "%02d:%02d", hour, minute), forKey: StorageKeys.streakReminderTime)
        reschedule()
    }

    // MARK: - Enable / Disable

    /// Callers must have notification permission granted before enabling.
    func enable() {
        storage.setBool(true, forKey: StorageKeys.streakReminderEnabled)
        reschedule()
    }

    func disable() {
        storage.setBool(false, forKey: StorageKeys.streakReminderEnabled)
        reschedule()
    }

    // MARK: - Scheduling

    /// Reconciles the pending reminders with the current state: removes every
    /// streak request, then re-adds one per upcoming day. Today is skipped when
    /// the user already practiced or the chosen time already passed.
    func reschedule() {
        Task { await rescheduleAsync() }
    }

    private func rescheduleAsync() async {
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(Self.identifierPrefix) }
        if !ours.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ours)
        }

        guard isEnabled else { return }

        let time = reminderTime
        let practicedToday = ProgressService.shared.practicedToday
        let calendar = Calendar.current
        let now = Date()

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: now) else { continue }

            var comps = calendar.dateComponents([.year, .month, .day], from: day)
            comps.hour = time.hour
            comps.minute = time.minute

            guard let fireDate = calendar.date(from: comps) else { continue }
            if offset == 0 && (practicedToday || fireDate <= now) { continue }

            let content = UNMutableNotificationContent()
            content.title = String(localized: "streak.reminder.title")
            content.body = String(localized: "streak.reminder.body")
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: Self.identifierPrefix + Self.dayKey(for: comps),
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            )
            do {
                try await center.add(request)
            } catch {
                continue
            }
        }

        #if DEBUG
        await logPending()
        #endif
    }

    /// Locale-independent date key ("2026-9-2") built from Int components.
    private static func dayKey(for comps: DateComponents) -> String {
        "\(comps.year ?? 0)-\(comps.month ?? 0)-\(comps.day ?? 0)"
    }

    #if DEBUG
    /// QA visibility — prints the pending streak reminders so simulator runs can
    /// assert scheduling through the console log.
    private func logPending() async {
        let pending = await center.pendingNotificationRequests()
        let ours = pending
            .filter { $0.identifier.hasPrefix(Self.identifierPrefix) }
            .map(\.identifier)
            .sorted()
        let time = reminderTime
        NSLog("[StreakReminder] enabled=%d time=%02d:%02d pending=%d ids=%@",
              isEnabled ? 1 : 0, time.hour, time.minute, ours.count, ours.joined(separator: ","))
    }
    #endif
}
