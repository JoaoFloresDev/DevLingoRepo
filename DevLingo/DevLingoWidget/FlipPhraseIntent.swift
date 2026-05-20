import AppIntents
import Foundation
import WidgetKit

// MARK: - Direction

enum PhraseFlipDirection: String, AppEnum {
    case previous
    case next

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Direction"
    static var caseDisplayRepresentations: [PhraseFlipDirection: DisplayRepresentation] = [
        .previous: "Previous",
        .next: "Next"
    ]
}

// MARK: - Intent

struct FlipPhraseIntent: AppIntent {
    // MARK: - Metadata

    static var title: LocalizedStringResource = "Flip Phrase"
    static var isDiscoverable: Bool = false

    // MARK: - Parameters

    @Parameter(title: "Direction")
    var direction: PhraseFlipDirection

    // MARK: - Init

    init() {}

    init(direction: PhraseFlipDirection) {
        self.direction = direction
    }

    // MARK: - Perform

    func perform() async throws -> some IntentResult {
        let store = UserDefaults(suiteName: "group.com.gambitstudio.devlingo")

        guard let data = store?.data(forKey: "widgetPhrases"),
              let phrases = try? JSONDecoder().decode([WidgetPhrase].self, from: data),
              !phrases.isEmpty else {
            return .result()
        }

        let total = phrases.count
        let current = store?.integer(forKey: "widgetCurrentIndex") ?? 0
        let next: Int

        switch direction {
        case .next:
            next = (current + 1) % total
        case .previous:
            next = (current - 1 + total) % total
        }

        store?.set(next, forKey: "widgetCurrentIndex")
        WidgetCenter.shared.reloadTimelines(ofKind: "DevLingoWidget")

        return .result()
    }
}
