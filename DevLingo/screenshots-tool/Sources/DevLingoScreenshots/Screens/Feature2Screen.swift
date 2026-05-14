import SwiftUI
import GambitScreenshotKit

// MARK: - Phrase Detail (faithful recreation of CategoryDetailView)
// Shows: nav bar with category name, header info card, difficulty filter chips,
// one phrase card with translation visible (the "showing translation" state).

struct Feature2Screen: View {
    let locale: String

    var body: some View {
        let cat = MockCategory.codeReview
        let phrase = MockPhrasesFactory.detailPhrase(locale: locale)

        return ZStack {
            MockTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                iOSStatusBar(foreground: .white)
                navBar(title: cat.label(locale: locale))
                VStack(spacing: 14) {
                    headerInfoCard(cat: cat)
                    filterChips
                    PhraseCard(phrase: phrase, locale: locale, showTranslation: true)
                    PhraseCard(phrase: MockPhrasesFactory.todayPhrases(locale: locale)[0],
                               locale: locale, showTranslation: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - iOS-style inline nav bar

    private func navBar(title: String) -> some View {
        ZStack {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                    Text(backLabel())
                        .font(.system(size: 17))
                }
                .foregroundStyle(MockTheme.primary)
                Spacer()
            }
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(MockTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func backLabel() -> String {
        switch locale {
        case "pt-BR": return "Categorias"
        case "es-ES", "es-MX": return "Categorías"
        default: return "Categories"
        }
    }

    // MARK: - Header info card (icon + title + count)

    private func headerInfoCard(cat: MockCategory) -> some View {
        HStack(spacing: 18) {
            Image(systemName: cat.icon)
                .font(.system(size: 38))
                .foregroundStyle(cat.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(cat.label(locale: locale))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(MockTheme.textPrimary)
                Text("310 \(LocalizedLabels.phrasesCountSuffix[locale] ?? "")")
                    .font(.system(size: 15))
                    .foregroundStyle(MockTheme.textSecondary)
            }
            Spacer()
        }
        .padding(20)
        .background(MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Difficulty filter chips

    private var filterChips: some View {
        HStack(spacing: 10) {
            chip(text: allLabel(), color: MockTheme.primary, selected: true)
            chip(text: MockDifficulty.easy.label(locale: locale), color: MockTheme.easy, selected: false)
            chip(text: MockDifficulty.medium.label(locale: locale), color: MockTheme.medium, selected: false)
            chip(text: MockDifficulty.hard.label(locale: locale), color: MockTheme.hard, selected: false)
            Spacer()
        }
    }

    private func chip(text: String, color: Color, selected: Bool) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(selected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(selected ? color : color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func allLabel() -> String {
        switch locale {
        case "pt-BR": return "TODAS"
        case "es-ES", "es-MX": return "TODAS"
        default: return "ALL"
        }
    }
}
