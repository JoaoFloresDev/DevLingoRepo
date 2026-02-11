import Foundation

/// Centralized feature flags.
enum FeatureFlags {
    /// Show mock data for App Store screenshots.
    static let isMockedData = false

    /// Enable premium/paywall features (v2).
    static let premiumEnabled = false

    /// Enable text-to-speech pronunciation.
    static let speechEnabled = true

    /// Enable widget support.
    static let widgetEnabled = true
}
