import SwiftUI
import FirebaseCore
import GambitCoreKit

@main
struct DevLingoApp: App {
    // MARK: - Properties

    @AppStorage(StorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(StorageKeys.preferredColorScheme) private var appearanceModeRaw: String = AppearanceMode.dark.rawValue

    @StateObject private var purchaseService = PurchaseService.shared
    @State private var showLaunchPaywall = false
    @State private var paywallSource = "launch"

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .dark
    }

    // MARK: - Init

    init() {
        FirebaseApp.configure()
        PhraseService.shared.loadPhrases()
        ReviewService.shared.incrementLaunchCount()
        configureAppearance()
        configureRatingGate()
    }

    // MARK: - Rating Gate

    /// Pre-gate before the native prompt: happy users go to the App Store, unhappy ones
    /// stay in the app with a feedback form (1-2 star intent never leaks to the store).
    private func configureRatingGate() {
        let service = RatingGateService.shared
        service.config = RatingGateConfig(
            questionTitle: String(localized: "rating.gate.question.title"),
            questionSubtitle: String(localized: "rating.gate.question.subtitle"),
            yesButton: String(localized: "rating.gate.yes"),
            noButton: String(localized: "rating.gate.no"),
            feedbackTitle: String(localized: "rating.gate.feedback.title"),
            feedbackPlaceholder: String(localized: "rating.gate.feedback.placeholder"),
            feedbackSend: String(localized: "rating.gate.feedback.send"),
            feedbackThanks: String(localized: "rating.gate.feedback.thanks")
        )
        service.onEvent = { event in
            AnalyticsService.ratingGate(event.name, trigger: event.trigger.rawValue)
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(appearanceMode.colorScheme)
            .ratingGate(accent: AppColors.primary)
            .onOpenURL { url in
                AppRouter.shared.handle(url: url)
            }
            .fullScreenCover(isPresented: $showLaunchPaywall) {
                PaywallView(source: paywallSource)
            }
            .onAppear(perform: evaluateLaunchPaywall)
            .onChange(of: hasCompletedOnboarding) { _, completed in
                guard completed else { return }
                presentPostOnboardingPaywall()
            }
        }
    }

    // MARK: - Post-Onboarding Paywall

    /// Shown once, right after the user finishes onboarding (unless already premium).
    private func presentPostOnboardingPaywall() {
        guard FeatureFlags.premiumEnabled else { return }

        // Let the onboarding→main transition settle before covering it.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard !purchaseService.isPremium else { return }
            paywallSource = "post_onboarding"
            showLaunchPaywall = true
        }
    }

    // MARK: - Launch Paywall

    /// From `launchPaywallThreshold` opens onward, non-pro users get the paywall on launch.
    private func evaluateLaunchPaywall() {
        guard FeatureFlags.premiumEnabled,
              hasCompletedOnboarding,
              ReviewService.shared.launchCount() >= AppConstants.launchPaywallThreshold else { return }

        // Give StoreKit a beat to resolve entitlements before deciding (avoids flashing
        // the paywall to a subscriber whose isPremium hasn't loaded yet on cold launch).
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard !purchaseService.isPremium else { return }
            paywallSource = "launch"
            showLaunchPaywall = true
        }
    }

    // MARK: - Appearance

    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(AppColors.surface)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(AppColors.background)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}
