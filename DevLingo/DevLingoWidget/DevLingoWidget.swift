import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct PhraseEntry: TimelineEntry {
    let date: Date
    let english: String
    let context: String
    let translation: String
    let category: String
    let categoryIcon: String
    let difficulty: String

    static let placeholder = PhraseEntry(
        date: .now,
        english: "Can you review my pull request?",
        context: "Asking a teammate for a code review",
        translation: "Você pode revisar meu pull request?",
        category: "Code Review",
        categoryIcon: "eye.fill",
        difficulty: "easy"
    )
}

// MARK: - Timeline Provider

struct DevLingoTimelineProvider: TimelineProvider {
    private let storage = UserDefaults(suiteName: "group.com.gambitstudio.devlingo")

    func placeholder(in context: Context) -> PhraseEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PhraseEntry) -> Void) {
        completion(getEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PhraseEntry>) -> Void) {
        let entry = getEntry()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func getEntry() -> PhraseEntry {
        // Read shared data from App Group
        guard let data = storage?.data(forKey: "widgetPhrases"),
              let phrases = try? JSONDecoder().decode([WidgetPhrase].self, from: data),
              !phrases.isEmpty else {
            return .placeholder
        }

        // Rotate through phrases based on time
        let hour = Calendar.current.component(.hour, from: .now)
        let index = hour % phrases.count
        let phrase = phrases[index]

        return PhraseEntry(
            date: .now,
            english: phrase.english,
            context: phrase.context,
            translation: phrase.translation,
            category: phrase.category,
            categoryIcon: phrase.categoryIcon,
            difficulty: phrase.difficulty
        )
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

// MARK: - Widget View

struct DevLingoWidget: Widget {
    let kind: String = "DevLingoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DevLingoTimelineProvider()) { entry in
            DevLingoWidgetView(entry: entry)
                .containerBackground(Color(hex: "000000"), for: .widget)
        }
        .configurationDisplayName("DevLingo")
        .description("Learn English phrases for developers")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Views

struct DevLingoWidgetView: View {
    let entry: PhraseEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        default:
            mediumWidget
        }
    }

    // MARK: - Small

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: entry.categoryIcon)
                    .font(.system(size: 10))
                Text(entry.category)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(Color(hex: "5E5CE6"))

            Spacer()

            Text(entry.english)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(4)

            Spacer()

            difficultyBadge
        }
        .padding(12)
    }

    // MARK: - Medium

    private var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: entry.categoryIcon)
                        .font(.system(size: 11))
                    Text(entry.category)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(Color(hex: "5E5CE6"))

                Spacer()

                difficultyBadge
            }

            Text(entry.english)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(entry.context)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "636366"))
                .lineLimit(1)

            Text(entry.translation)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "8E8E93"))
                .lineLimit(2)
        }
        .padding(14)
    }

    // MARK: - Large

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "5E5CE6"))

                Text("DevLingo")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                difficultyBadge
            }

            Divider()
                .background(Color(hex: "3A3A3C"))

            HStack(spacing: 4) {
                Image(systemName: entry.categoryIcon)
                    .font(.system(size: 11))
                Text(entry.category)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(Color(hex: "5E5CE6"))

            Text(entry.english)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(3)

            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "5E5CE6").opacity(0.5))
                    .frame(width: 3)

                Text(entry.context)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "636366"))
                    .lineLimit(2)
            }

            Spacer()

            Text(entry.translation)
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: "8E8E93"))
                .lineLimit(3)

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Difficulty Badge

    private var difficultyBadge: some View {
        let color: Color = {
            switch entry.difficulty {
            case "easy": return Color(hex: "30D158")
            case "medium": return Color(hex: "FF9F0A")
            case "hard": return Color(hex: "FF453A")
            default: return Color(hex: "8E8E93")
            }
        }()

        return Text(entry.difficulty.capitalized)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
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
