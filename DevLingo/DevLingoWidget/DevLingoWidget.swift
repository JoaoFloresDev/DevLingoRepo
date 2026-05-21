import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

struct PhraseEntry: TimelineEntry {
    let date: Date
    let currentIndex: Int
    let total: Int
    let phrase: WidgetPhrase
    let nextPhrase: WidgetPhrase?

    static let placeholder = PhraseEntry(
        date: .now,
        currentIndex: 0,
        total: 2,
        phrase: WidgetPhrase(
            id: "placeholder_1",
            english: "Can you review my pull request?",
            context: "Code review",
            translation: "Você pode revisar meu pull request?",
            category: "Code Review",
            categoryIcon: "checkmark.seal.fill",
            difficulty: "medium"
        ),
        nextPhrase: WidgetPhrase(
            id: "placeholder_2",
            english: "Let's circle back on this",
            context: "Meetings",
            translation: "Vamos retomar isso",
            category: "Meetings",
            categoryIcon: "person.3.fill",
            difficulty: "medium"
        )
    )
}

// MARK: - Timeline Provider

struct DevLingoTimelineProvider: TimelineProvider {
    private let storage = UserDefaults(suiteName: "group.com.gambitstudio.devlingo")

    func placeholder(in context: Context) -> PhraseEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PhraseEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PhraseEntry>) -> Void) {
        let entry = makeEntry()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func makeEntry() -> PhraseEntry {
        let phrases = loadPhrases()
        guard !phrases.isEmpty else {
            return .placeholder
        }

        let total = phrases.count
        let storedIndex = storage?.integer(forKey: "widgetCurrentIndex") ?? 0
        let index = max(0, min(storedIndex, total - 1))
        let next = total > 1 ? phrases[(index + 1) % total] : nil

        return PhraseEntry(
            date: .now,
            currentIndex: index,
            total: total,
            phrase: phrases[index],
            nextPhrase: next
        )
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
    let id: String
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
        .contentMarginsDisabled()
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
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        default:
            mediumView
        }
    }

    // MARK: - Small View

    private var smallView: some View {
        paginationBackground
            .overlay {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    Link(destination: phraseURL(entry.phrase.id)) {
                        Text(entry.phrase.english)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)

                    Spacer()
                        .frame(height: 44)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottom) { paginationOverlay }
    }

    // MARK: - Medium View

    private var mediumView: some View {
        paginationBackground
            .overlay {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    Link(destination: phraseURL(entry.phrase.id)) {
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: entry.phrase.categoryIcon)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: "5E5CE6"))

                                Text(entry.phrase.category)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .lineLimit(1)
                            }

                            Text(entry.phrase.english)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)

                    Spacer()
                        .frame(height: 44)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottom) { paginationOverlay }
    }

    // MARK: - Large View (Two Phrases)

    private var largeView: some View {
        paginationBackground
            .overlay {
                VStack(spacing: 0) {
                    phraseLinkLarge(phrase: entry.phrase)

                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.horizontal, 16)

                    if let next = entry.nextPhrase {
                        phraseLinkLarge(phrase: next)
                    } else {
                        phraseLinkLarge(phrase: entry.phrase)
                    }

                    Spacer()
                        .frame(height: 44)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottom) { paginationOverlay }
    }

    private func phraseLinkLarge(phrase: WidgetPhrase) -> some View {
        Link(destination: phraseURL(phrase.id)) {
            VStack(spacing: 6) {
                Spacer(minLength: 0)

                HStack(spacing: 6) {
                    Image(systemName: phrase.categoryIcon)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "5E5CE6"))

                    Text(phrase.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }

                Text(phrase.english)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Accessory Views (Lock Screen)

    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("DevLingo", systemImage: "text.bubble.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(entry.phrase.english)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(phraseURL(entry.phrase.id))
    }

    private var accessoryInlineView: some View {
        Label(entry.phrase.english, systemImage: "text.bubble.fill")
            .lineLimit(1)
            .widgetURL(phraseURL(entry.phrase.id))
    }

    // MARK: - Pagination

    /// Full-widget tap surface: left half = previous, right half = next.
    /// Used as the base layer so taps outside the phrase Link fall through to navigation.
    @ViewBuilder
    private var paginationBackground: some View {
        if entry.total > 1 {
            HStack(spacing: 0) {
                Button(intent: FlipPhraseIntent(direction: .previous)) {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(intent: FlipPhraseIntent(direction: .next)) {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        } else {
            Color.clear
        }
    }

    /// Visual chevrons + dots anchored to the bottom of the widget. Not interactive.
    @ViewBuilder
    private var paginationOverlay: some View {
        if entry.total > 1 {
            HStack(spacing: 0) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 44, height: 44)

                indicatorDots
                    .frame(maxWidth: .infinity)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 44, height: 44)
            }
            .allowsHitTesting(false)
        }
    }

    private var indicatorDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<min(entry.total, 10), id: \.self) { i in
                Circle()
                    .fill(i == entry.currentIndex ? Color.white : Color.white.opacity(0.25))
                    .frame(width: 4, height: 4)
            }
        }
    }

    // MARK: - Helpers

    private func phraseURL(_ id: String) -> URL {
        URL(string: "devlingo://phrase/\(id)") ?? URL(string: "devlingo://home")!
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
