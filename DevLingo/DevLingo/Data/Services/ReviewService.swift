import StoreKit
import Foundation

/// Manages App Store review requests.
final class ReviewService {
    // MARK: - Singleton

    static let shared = ReviewService()

    // MARK: - Properties

    private let storage = StorageService.shared

    // MARK: - Init

    private init() {}

    // MARK: - Public

    func incrementLaunchCount() {
        let count = storage.getInt(forKey: StorageKeys.appOpenCount)
        storage.setInt(count + 1, forKey: StorageKeys.appOpenCount)
    }

    /// Returns the current app open count.
    func launchCount() -> Int {
        storage.getInt(forKey: StorageKeys.appOpenCount)
    }

    /// Request review only between 5th and 10th app open. Called when user taps "learned".
    func requestReviewIfEligible() {
        let count = launchCount()
        guard count >= 5 && count <= 10 else { return }

        // Check cooldown
        if let lastDate = storage.getDate(forKey: StorageKeys.lastReviewRequestDate) {
            let daysSince = Date().daysFrom(lastDate)
            guard daysSince >= AppConstants.reviewCooldownDays else { return }
        }

        Task { @MainActor in
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                if #available(iOS 18.0, *) {
                    AppStore.requestReview(in: scene)
                } else {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }

        storage.setDate(Date(), forKey: StorageKeys.lastReviewRequestDate)
    }
}
