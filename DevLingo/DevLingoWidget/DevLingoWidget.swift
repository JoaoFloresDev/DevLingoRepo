import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct PhraseEntry: TimelineEntry {
    let date: Date
    let english: String
    let translation: String

    static let placeholder = PhraseEntry(
        date: .now,
        english: "Can you review my pull request?",
        translation: "Você pode revisar meu pull request?"
    )
}

// MARK: - Timeline Provider

struct DevLingoTimelineProvider: TimelineProvider {
    private let storage = UserDefaults(suiteName: "group.com.gambitstudio.devlingo")

    func placeholder(in context: Context) -> PhraseEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PhraseEntry) -> Void) {
        let phrases = loadPhrases()
        guard !phrases.isEmpty else {
            completion(.placeholder)
            return
        }
        let phrase = phrases[0]
        completion(PhraseEntry(
            date: .now,
            english: phrase.english,
            translation: phrase.translation
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PhraseEntry>) -> Void) {
        let phrases = loadPhrases()

        guard !phrases.isEmpty else {
            let entry = PhraseEntry.placeholder
            let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            return
        }

        var entries: [PhraseEntry] = []
        let calendar = Calendar.current
        let now = Date()

        for i in 0..<phrases.count {
            let entryDate = calendar.date(byAdding: .hour, value: i * 2, to: now) ?? now
            let phrase = phrases[i % phrases.count]

            entries.append(PhraseEntry(
                date: entryDate,
                english: phrase.english,
                translation: phrase.translation
            ))
        }

        let refreshDate = calendar.date(byAdding: .hour, value: phrases.count * 2, to: now) ?? now
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }

    private func loadPhrases() -> [WidgetPhrase] {
        guard let data = storage?.data(forKey: "widgetPhrases"),
              let phrases = try? JSONDecoder().decode([WidgetPhrase].self, from: data),
              !phrases.isEmpty else {
            return []
        }
        return phrases
    }
}

// MARK: - Widget Phrase (shared model)

struct WidgetPhrase: Codable {
    let english: String
    let context: String
    let translation: String
    let category: String
    let categoryIcon: String
    let difficulty: String
}

// MARK: - Widget

struct DevLingoWidget: Widget {
    let kind: String = "DevLingoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DevLingoTimelineProvider()) { entry in
            DevLingoWidgetView(entry: entry)
                .containerBackground(Color(hex: "000000"), for: .widget)
        }
        .configurationDisplayName(String(localized: "widget.name"))
        .description(String(localized: "widget.description"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget View

struct DevLingoWidgetView: View {
    let entry: PhraseEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(entry.english)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(lineLimit)

            Spacer()
        }
        .padding(padding)
    }

    // MARK: - Sizing

    private var fontSize: CGFloat {
        switch family {
        case .systemSmall: return 15
        case .systemMedium: return 17
        case .systemLarge: return 22
        default: return 17
        }
    }

    private var lineLimit: Int {
        switch family {
        case .systemSmall: return 5
        case .systemMedium: return 3
        case .systemLarge: return 6
        default: return 3
        }
    }

    private var padding: CGFloat {
        switch family {
        case .systemSmall: return 14
        case .systemMedium: return 16
        case .systemLarge: return 20
        default: return 16
        }
    }
}

// MARK: - Color Hex (Widget)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
