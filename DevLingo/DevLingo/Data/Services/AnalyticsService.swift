import Foundation
import FirebaseAnalytics
import GambitCoreKit

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

    /// User marked a phrase as learned — this is the app's value moment.
    static func phraseLearned(category: String, difficulty: String) {
        log("phrase_learned", ["category": category, "difficulty": difficulty])
        coreAction("phrase_learned", ["category": category])
    }

    /// Text-to-speech pronunciation played.
    static func phraseListened(category: String) {
        log("phrase_listened", ["category": category])
        feature("pronunciation", source: "phrase")
    }

    /// A category was opened from the grid. `locked` = premium-gated at tap time.
    static func categoryOpened(category: String, locked: Bool) {
        log("category_opened", ["category": category, "locked": locked ? "true" : "false"])
    }

    // MARK: - Canonical (GambitStudio taxonomy)

    private static let coreActionKey = "analytics.didCoreAction"

    /// Activation: the moment the app delivered its value. `first` marks the very first
    /// time on this install, which is what predicts retention.
    static func coreAction(_ kind: String, _ params: [String: Any] = [:]) {
        let defaults = UserDefaults.standard
        let first = !defaults.bool(forKey: coreActionKey)
        if first { defaults.set(true, forKey: coreActionKey) }
        var all = params
        all["kind"] = kind
        all["first"] = first ? "true" : "false"
        log("core_action", all)
        // The activation moment is also the rating gate's trigger — the service decides
        // on its own whether this is the right time to ask.
        Task { @MainActor in
            RatingGateService.shared.recordPositiveEvent(trigger: .init(rawValue: kind))
        }
    }

    /// Rating gate funnel (rating_gate_shown / _yes / _no / _dismissed / _feedback).
    static func ratingGate(_ name: String, trigger: String) {
        log(name, ["trigger": trigger])
    }

    /// Feature adoption, comparable across every app in the lab.
    static func feature(_ name: String, source: String) {
        log("feature_used", ["name": name, "source": source])
    }

    static func screen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: name])
    }

    /// Each onboarding page appeared — shows exactly where people drop out.
    static func onboardingStepViewed(step: Int) {
        log("onboarding_step_viewed", ["step": step])
    }

    // MARK: - Core

    private static func log(_ name: String, _ params: [String: Any]) {
        Analytics.logEvent(name, parameters: params.isEmpty ? nil : params)
    }
}
