import SwiftUI

/// Global router for deep links and cross-screen navigation.
@MainActor
final class AppRouter: ObservableObject {
    // MARK: - Singleton

    static let shared = AppRouter()

    // MARK: - Published

    @Published var selectedTab: Int = 0
    @Published var pendingPhraseID: String?

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    /// Handle a deep link URL (e.g. devlingo://phrase/standup_001).
    func handle(url: URL) {
        guard url.scheme == "devlingo" else { return }

        let host = url.host?.lowercased() ?? ""
        let pathID = url.pathComponents.dropFirst().first

        switch host {
        case "phrase":
            if let id = pathID {
                selectedTab = 0
                pendingPhraseID = id
            }
        case "home":
            selectedTab = 0
        default:
            break
        }
    }

    /// Called by HomeView once it has consumed the pending phrase ID.
    func clearPendingPhrase() {
        pendingPhraseID = nil
    }
}
