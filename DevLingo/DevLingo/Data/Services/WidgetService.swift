import Foundation
import WidgetKit

/// Shares phrase data with the widget via App Groups.
final class WidgetService {
    // MARK: - Singleton

    static let shared = WidgetService()

    // MARK: - Properties

    private let storage: UserDefaults?

    // MARK: - Init

    private init() {
        storage = UserDefaults(suiteName: AppConstants.appGroupID)
    }

    // MARK: - Update Widget

    func updateWidget(phrases: [Phrase], language: UserLanguage) {
        let widgetPhrases = phrases.map { phrase in
            WidgetPhraseData(
                id: phrase.id,
                english: phrase.english,
                context: phrase.context,
                translation: phrase.translation(for: language),
                category: phrase.category.label,
                categoryIcon: phrase.category.icon,
                difficulty: phrase.difficulty.rawValue
            )
        }

        if let data = try? JSONEncoder().encode(widgetPhrases) {
            storage?.set(data, forKey: StorageKeys.widgetPhrases)
        }

        let currentIndex = storage?.integer(forKey: StorageKeys.widgetCurrentIndex) ?? 0
        if currentIndex >= widgetPhrases.count {
            storage?.set(0, forKey: StorageKeys.widgetCurrentIndex)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: AppConstants.widgetKind)
    }
}

/// Codable model shared between app and widget.
struct WidgetPhraseData: Codable {
    let id: String
    let english: String
    let context: String
    let translation: String
    let category: String
    let categoryIcon: String
    let difficulty: String
}
