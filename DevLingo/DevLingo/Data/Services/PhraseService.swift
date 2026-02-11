import Foundation

/// Loads and manages the phrase database.
final class PhraseService {
    // MARK: - Singleton

    static let shared = PhraseService()

    // MARK: - Properties

    private(set) var allPhrases: [Phrase] = []
    private(set) var phrasesByCategory: [PhraseCategory: [Phrase]] = [:]
    private var isLoaded = false

    // MARK: - Init

    private init() {}

    // MARK: - Loading

    func loadPhrases() {
        guard !isLoaded else { return }

        for category in PhraseCategory.allCases {
            let phrases = loadCategory(category)
            phrasesByCategory[category] = phrases
            allPhrases.append(contentsOf: phrases)
        }

        isLoaded = true
    }

    private func loadCategory(_ category: PhraseCategory) -> [Phrase] {
        guard let url = Bundle.main.url(forResource: category.fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([Phrase].self, from: data)) ?? []
    }

    // MARK: - Queries

    func phrases(for category: PhraseCategory) -> [Phrase] {
        phrasesByCategory[category] ?? []
    }

    func phrase(by id: String) -> Phrase? {
        allPhrases.first { $0.id == id }
    }

    func phrases(by ids: [String]) -> [Phrase] {
        let idSet = Set(ids)
        let map = Dictionary(uniqueKeysWithValues: allPhrases.filter { idSet.contains($0.id) }.map { ($0.id, $0) })
        return ids.compactMap { map[$0] }
    }

    func search(_ query: String) -> [Phrase] {
        let lowered = query.lowercased()
        return allPhrases.filter {
            $0.english.lowercased().contains(lowered) ||
            $0.context.lowercased().contains(lowered)
        }
    }

    func phrases(difficulty: PhraseDifficulty) -> [Phrase] {
        allPhrases.filter { $0.difficulty == difficulty }
    }
}
