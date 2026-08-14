import Foundation
import FirebaseAnalytics

/// Thin, typed wrapper over Firebase Analytics. Centralizes every custom event so the
/// call sites stay declarative and the event/param names live in ONE place (Firebase
/// needs stable snake_case names ≤ 40 chars). No PII is ever sent — only feature usage.
enum AnalyticsService {
    // MARK: - Onboarding

    /// Onboarding finished (last step persisted `hasCompletedOnboarding`).
    static func onboardingCompleted(language: String, notificationsEnabled: Bool, notificationCount: Int) {
        log("onboarding_completed", [
            "language": language,
            "notifications": notificationsEnabled ? "true" : "false",
            "notification_count": notificationCount
        ])
    }

    // MARK: - Monetization Funnel

    /// Paywall became visible. `source`: post_onboarding / launch / category_locked / profile.
    static func paywallShown(source: String) {
        log("paywall_shown", ["source": source])
    }

    /// Paywall closed without a purchase.
    static func paywallDismissed(source: String) {
        log("paywall_dismissed", ["source": source])
    }

    /// User tapped subscribe. `product`: monthly / yearly.
    static func purchaseStarted(product: String, source: String) {
        log("purchase_started", ["product": product, "source": source])
    }

    static func purchaseSuccess(product: String, source: String) {
        log("purchase_success", ["product": product, "source": source])
    }

    /// Covers both StoreKit errors and user cancellation (`reason`).
    static func purchaseFailed(product: String, source: String, reason: String) {
        log("purchase_failed", ["product": product, "source": source, "reason": String(reason.prefix(90))])
    }

    static func restoreCompleted(success: Bool) {
        log("restore_completed", ["success": success ? "true" : "false"])
    }

    // MARK: - Learning

    /// User marked a phrase as learned.
    static func phraseLearned(category: String, difficulty: String) {
        log("phrase_learned", ["category": category, "difficulty": difficulty])
    }

    /// Text-to-speech pronunciation played.
    static func phraseListened(category: String) {
        log("phrase_listened", ["category": category])
    }

    /// A category was opened from the grid. `locked` = premium-gated at tap time.
    static func categoryOpened(category: String, locked: Bool) {
        log("category_opened", ["category": category, "locked": locked ? "true" : "false"])
    }

    // MARK: - Core

    private static func log(_ name: String, _ params: [String: Any]) {
        Analytics.logEvent(name, parameters: params.isEmpty ? nil : params)
    }
}
