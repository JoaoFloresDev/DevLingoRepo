import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct PhraseEntry: TimelineEntry {
    let date: Date
    let english: String
    let translation: String
    let secondEnglish: String?
    let secondTranslation: String?

    static let placeholder = PhraseEntry(
        date: .now,
        english: "Can you review my pull request?",
        translation: "Você pode revisar meu pull request?",
        secondEnglish: "Let's circle back on this",
        secondTranslation: "Vamos retomar isso"
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
        let second = phrases.count > 1 ? phrases[1] : nil
        completion(PhraseEntry(
            date: .now,
            english: phrase.english,
            translation: phrase.translation,
            secondEnglish: second?.english,
            secondTranslation: second?.translation
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
            let secondIndex = (i + 1) % phrases.count
            let second = phrases.count > 1 ? phrases[secondIndex] : nil

            entries.append(PhraseEntry(
                date: entryDate,
                english: phrase.english,
                translation: phrase.translation,
                secondEnglish: second?.english,
                secondTranslation: second?.translation
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
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryRectangular, .accessoryInline
        ])
    }
}

// MARK: - Widget View

struct DevLingoWidgetView: View {
    let entry: PhraseEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemLarge:
            largeView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        default:
            standardView
        }
    }

    // MARK: - Standard View (Small / Medium)

    private var standardView: some View {
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

    // MARK: - Large View (Two Phrases)

    private var largeView: some View {
        VStack(spacing: 0) {
            phraseCard(english: entry.english)

            Divider()
                .background(Color.white.opacity(0.15))
                .padding(.horizontal, 16)

            if let second = entry.secondEnglish {
                phraseCard(english: second)
            } else {
                phraseCard(english: entry.english)
            }
        }
        .padding(.vertical, 8)
    }

    private func phraseCard(english: String) -> some View {
        VStack(spacing: 6) {
            Spacer()

            Image(systemName: "text.bubble.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "5E5CE6").opacity(0.7))

            Text(english)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Accessory Views (Lock Screen)

    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("DevLingo", systemImage: "text.bubble.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(entry.english)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accessoryInlineView: some View {
        Label(entry.english, systemImage: "text.bubble.fill")
            .lineLimit(1)
    }

    // MARK: - Sizing

    private var fontSize: CGFloat {
        switch family {
        case .systemSmall: return 15
        case .systemMedium: return 17
        default: return 17
        }
    }

    private var lineLimit: Int {
        switch family {
        case .systemSmall: return 5
        case .systemMedium: return 3
        default: return 3
        }
    }

    private var padding: CGFloat {
        switch family {
        case .systemSmall: return 8
        case .systemMedium: return 10
        default: return 10
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
