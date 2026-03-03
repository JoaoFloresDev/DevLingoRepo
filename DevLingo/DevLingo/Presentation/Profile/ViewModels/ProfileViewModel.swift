import SwiftUI

/// ViewModel for Profile screen.
@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published

    @Published var progress = UserProgress()
    @Published var savedCount = 0
    @Published var hardCount = 0

    // MARK: - Properties

    private let storage = StorageService.shared

    // MARK: - Public Methods

    func loadData() {
        if FeatureFlags.isMockedData {
            progress = MockDataProvider.mockProgress
            savedCount = 12
            hardCount = 8
        } else {
            progress = ProgressService.shared.getProgress()
            savedCount = storage.getStringSet(forKey: StorageKeys.savedPhraseIDs).count
            hardCount = storage.getStringSet(forKey: "hardPhraseIDs").count
        }
    }
}
