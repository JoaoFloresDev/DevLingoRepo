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

    // MARK: - Computed Properties

    var currentLanguageName: String {
        guard let code = storage.getString(forKey: StorageKeys.selectedLanguage),
              let lang = UserLanguage(rawValue: code) else {
            return UserLanguage.ptBR.nativeName
        }
        return lang.nativeName
    }

    // MARK: - Public Methods

    func loadData() {
        if FeatureFlags.isMockedData {
            progress = MockDataProvider.mockProgress
            savedCount = 12
            hardCount = 8
        } else {
            progress = ProgressService.shared.getProgress()
            savedCount = storage.getStringSet(forKey: StorageKeys.savedPhraseIDs).count
            hardCount = storage.getStringSet(forKey: StorageKeys.hardPhraseIDs).count
        }
    }

    func getLearnedPhrases() -> [Phrase] {
        let completedIDs = storage.getStringSet(forKey: StorageKeys.completedPhraseIDs)
        let allPhrases = PhraseService.shared.allPhrases
        return allPhrases.filter { completedIDs.contains($0.id) }
    }

    func getSavedPhrases() -> [Phrase] {
        let savedIDs = storage.getStringSet(forKey: StorageKeys.savedPhraseIDs)
        let allPhrases = PhraseService.shared.allPhrases
        return allPhrases.filter { savedIDs.contains($0.id) }
    }

    func getHardPhrases() -> [Phrase] {
        let allPhrases = PhraseService.shared.allPhrases
        return allPhrases.filter { $0.difficulty == .hard }
    }

    var userLanguage: UserLanguage {
        guard let code = storage.getString(forKey: StorageKeys.selectedLanguage),
              let lang = UserLanguage(rawValue: code) else {
            return .ptBR
        }
        return lang
    }
}
