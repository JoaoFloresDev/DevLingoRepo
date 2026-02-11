import Foundation

/// App-wide constants.
enum AppConstants {
    // MARK: - App Info
    static let appName = "DevLingo"
    static let bundleID = "com.gambitstudio.devlingo"
    static let appGroupID = "group.com.gambitstudio.devlingo"

    // MARK: - Phrases
    static let phrasesPerDay = 10
    static let easyPerDay = 4
    static let mediumPerDay = 4
    static let hardPerDay = 2
    static let totalPhrases = 3600
    static let totalCategories = 12

    // MARK: - StoreKit Product IDs (v2)
    static let monthlyProductID = "devlingo.pro.monthly"
    static let yearlyProductID = "devlingo.pro.yearly"

    static var allProductIDs: [String] {
        [monthlyProductID, yearlyProductID]
    }

    // MARK: - Defaults
    static let reviewMinimumLaunches = 5
    static let reviewCooldownDays = 60

    // MARK: - Notification Identifiers
    static let dailyReminderNotification = "devlingo.notification.daily.reminder"
    static let streakReminderNotification = "devlingo.notification.streak.reminder"

    // MARK: - Widget
    static let widgetKind = "DevLingoWidget"
    static let widgetRefreshInterval: TimeInterval = 2 * 60 * 60 // 2 hours
}
