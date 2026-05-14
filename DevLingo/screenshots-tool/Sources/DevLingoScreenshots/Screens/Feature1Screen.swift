import SwiftUI
import GambitScreenshotKit

// MARK: - Categories Screen (faithful recreation of CategoriesView)

struct Feature1Screen: View {
    let locale: String

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            MockTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                iOSStatusBar(foreground: .white)
                VStack(spacing: 16) {
                    header
                    grid
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        Text(LocalizedLabels.categoriesTitle[locale] ?? "")
            .font(.system(size: 34, weight: .bold))
            .foregroundStyle(MockTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(MockCategory.all.prefix(12).enumerated()), id: \.offset) { _, cat in
                cell(for: cat)
            }
        }
    }

    private func cell(for cat: MockCategory) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                Image(systemName: cat.isPremium ? "lock.fill" : cat.icon)
                    .font(.system(size: 30))
                    .foregroundStyle(cat.isPremium ? MockTheme.textTertiary : cat.color)

                Text(cat.label(locale: locale))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(cat.isPremium ? MockTheme.textTertiary : MockTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("\(phraseCount(for: cat)) \(LocalizedLabels.phrasesCountSuffix[locale] ?? "")")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MockTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .padding(.vertical, 22)
            .padding(.horizontal, 12)
            .background(cat.isPremium ? MockTheme.surface.opacity(0.6) : MockTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        cat.isPremium ? MockTheme.textTertiary.opacity(0.2) : cat.color.opacity(0.2),
                        lineWidth: 1
                    )
            )

            if cat.isPremium {
                Text("PRO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(MockTheme.accent)
                    .clipShape(Capsule())
                    .padding(8)
            }
        }
    }

    private func phraseCount(for cat: MockCategory) -> Int {
        // Stable mapping
        switch cat.icon {
        case "person.3.fill":               return 320
        case "chevron.left.forwardslash.chevron.right": return 310
        case "bubble.left.and.bubble.right.fill":       return 295
        case "video.fill":                  return 280
        case "arrow.triangle.pull":         return 265
        case "envelope.fill":               return 240
        case "gearshape.fill":              return 350
        case "ant.fill":                    return 215
        case "cup.and.saucer.fill":         return 220
        case "person.2.fill":               return 195
        case "questionmark.bubble.fill":    return 180
        case "doc.text.fill":               return 200
        case "hand.wave.fill":              return 170
        default:                            return 250
        }
    }
}
