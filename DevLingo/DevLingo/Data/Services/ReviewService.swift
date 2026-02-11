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

    func requestReviewIfNeeded() {
        let count = storage.getInt(forKey: StorageKeys.appOpenCount)
        let hasRequested = storage.getBool(forKey: StorageKeys.hasRequestedReview)

        guard count >= AppConstants.reviewMinimumLaunches, !hasRequested else { return }

        // Check cooldown
        if let lastDate = storage.getDate(forKey: StorageKeys.lastReviewRequestDate) {
            let daysSince = Date().daysFrom(lastDate)
            guard daysSince >= AppConstants.reviewCooldownDays else { return }
        }

        // Request review
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }

        storage.setBool(true, forKey: StorageKeys.hasRequestedReview)
        storage.setDate(Date(), forKey: StorageKeys.lastReviewRequestDate)
    }
}
