import Foundation

/// Centralized feature flags for the app.
enum FeatureFlags {
    // MARK: - Mock Data

    /// When `true`, the app uses mock/fake data instead of real data.
    /// Used to generate App Store screenshots with beautiful, curated content.
    static let isMockedData = false

    // MARK: - Monetization

    /// Set to `true` to enable in-app purchases and premium features.
    /// Set to `false` for initial free launch.
    static let premiumEnabled = false

    // MARK: - Features

    /// Enable text-to-speech pronunciation.
    static let speechEnabled = true

    /// Enable widget support.
    static let widgetEnabled = true

    // MARK: - Computed Flags

    /// Returns whether user currently has premium access.
    static func hasPremiumAccess() -> Bool {
        if !premiumEnabled { return true }
        return false
    }
}
