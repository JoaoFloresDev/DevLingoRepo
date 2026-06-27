import Foundation

/// App-wide constants.
enum AppConstants {
    // MARK: - App Info
    static let appName = "Devlingo"
    static let bundleID = "com.gambitstudio.devlingo"
    static let appGroupID = "group.com.gambitstudio.devlingo"

    // MARK: - Phrases
    static let phrasesPerDay = 10
    static let easyPerDay = 4
    static let mediumPerDay = 4
    static let hardPerDay = 2
    static let totalPhrases = 3900
    static let totalCategories = 13

    // MARK: - StoreKit Product IDs
    static let monthlyProductID = "monthly.devlingo.pro"
    static let yearlyProductID = "yearly.devlingo.pro"

    static var allProductIDs: [String] {
        [monthlyProductID, yearlyProductID]
    }

    // MARK: - URLs
    static let privacyPolicyURL = "https://drive.google.com/file/d/1fEHysu7rRdk9Hns4CCgK-4ty2_a57vR_/view?usp=sharing"
    static let termsOfUseURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

    // MARK: - Defaults
    static let reviewMinimumLaunches = 5
    static let reviewCooldownDays = 60

    /// From this app-open count onward, non-pro users see the paywall on launch.
    static let launchPaywallThreshold = 10

    // MARK: - Widget
    static let widgetKind = "DevLingoWidget"
    static let widgetRefreshInterval: TimeInterval = 2 * 60 * 60 // 2 hours
}
