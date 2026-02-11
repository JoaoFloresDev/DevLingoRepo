import Foundation

/// Represents a day's set of 10 phrases.
struct DailyPhraseSet: Codable, Identifiable {
    // MARK: - Properties

    let id: String // date string "yyyy-MM-dd"
    let date: Date
    let phraseIDs: [String]
    var completedIDs: Set<String>

    // MARK: - Computed

    var progress: Double {
        guard !phraseIDs.isEmpty else { return 0 }
        return Double(completedIDs.count) / Double(phraseIDs.count)
    }

    var isComplete: Bool {
        completedIDs.count >= phraseIDs.count
    }

    var completedCount: Int {
        completedIDs.count
    }

    var totalCount: Int {
        phraseIDs.count
    }
}
