import Foundation

/// A single English phrase for developers to learn.
struct Phrase: Codable, Identifiable, Hashable {
    // MARK: - Properties

    /// Unique identifier (e.g. "standup_001")
    let id: String

    /// The English phrase to learn.
    let english: String

    /// Context explaining when/where to use this phrase.
    let context: String

    /// Translations keyed by language code (e.g. "pt-BR": "Estou trabalhando nisso.")
    let translations: [String: String]

    /// Difficulty level.
    let difficulty: PhraseDifficulty

    /// Category this phrase belongs to.
    let category: PhraseCategory

    // MARK: - Helpers

    /// Get translation for a specific language.
    func translation(for language: UserLanguage) -> String {
        translations[language.code] ?? english
    }
}
