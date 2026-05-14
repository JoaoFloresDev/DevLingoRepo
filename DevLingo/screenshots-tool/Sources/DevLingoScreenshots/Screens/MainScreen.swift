import SwiftUI
import GambitScreenshotKit

// MARK: - Home Screen (faithful recreation of HomeView)

struct MainScreen: View {
    let locale: String

    var body: some View {
        ZStack {
            MockTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                iOSStatusBar(foreground: .white)
                VStack(spacing: 16) {
                    header
                    statsRow
                    translationToggle
                    phrasesSection
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header (greeting + large title)

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedLabels.greeting[locale] ?? "")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(MockTheme.textSecondary)
            Text(LocalizedLabels.homeTitle[locale] ?? "")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(MockTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - 3 stat cards (streak / today / level)

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(MockTheme.accent)
                    Text("47")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(MockTheme.textPrimary)
                }
                Text(LocalizedLabels.streakDays[locale] ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(MockTheme.textSecondary)
            }
            statCard {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(MockTheme.secondary)
                    Text("3/5")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(MockTheme.textPrimary)
                }
                Text(LocalizedLabels.todayProgress[locale] ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(MockTheme.textSecondary)
            }
            statCard {
                Text("Lv.12")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(MockTheme.primary)
                Text(LocalizedLabels.levelTitle[locale] ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(MockTheme.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    private func statCard<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        VStack(spacing: 4) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Translation toggle row

    private var translationToggle: some View {
        HStack(spacing: 10) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 14))
                .foregroundStyle(MockTheme.primary)
            Text(translationLabel())
                .font(.system(size: 14))
                .foregroundStyle(MockTheme.textSecondary)
            Spacer()
            // Toggle visual (off)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(MockTheme.surfaceSecondary)
                    .frame(width: 50, height: 30)
                Circle()
                    .fill(.white)
                    .frame(width: 26, height: 26)
                    .padding(.leading, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func translationLabel() -> String {
        switch locale {
        case "pt-BR": return "Traduções ocultas"
        case "es-ES", "es-MX": return "Traducciones ocultas"
        default: return "Translations hidden"
        }
    }

    // MARK: - Today's phrases section

    private var phrasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(todayPhrasesLabel())
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(MockTheme.textPrimary)
                .padding(.top, 4)

            ForEach(Array(MockPhrasesFactory.todayPhrases(locale: locale).prefix(3))) { phrase in
                PhraseCard(phrase: phrase, locale: locale, showTranslation: false)
            }
        }
    }

    private func todayPhrasesLabel() -> String {
        switch locale {
        case "pt-BR": return "Frases de hoje"
        case "es-ES", "es-MX": return "Frases de hoy"
        default: return "Today's phrases"
        }
    }
}

// MARK: - Phrase Card (shared component matching PhraseCardView)

struct PhraseCard: View {
    let phrase: MockPhrase
    let locale: String
    let showTranslation: Bool
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top row: difficulty + category chip + completed check
            HStack(spacing: 8) {
                Text(phrase.difficulty.label(locale: locale))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(phrase.difficulty.color)
                    .clipShape(Capsule())

                HStack(spacing: 4) {
                    Image(systemName: phrase.category.icon)
                        .font(.system(size: 10))
                    Text(phrase.category.label(locale: locale))
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(phrase.category.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(phrase.category.color.opacity(0.15))
                .clipShape(Capsule())

                Spacer()

                if phrase.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(MockTheme.secondary)
                }
            }

            // English phrase
            Text(phrase.english)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(MockTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            // Context row
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                Text(phrase.context)
                    .font(.system(size: 13))
                    .lineLimit(1)
            }
            .foregroundStyle(MockTheme.textTertiary)

            // Translation block (only if showTranslation)
            if showTranslation {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(MockTheme.primary.opacity(0.5))
                        .frame(width: 3)
                    Text(phrase.translation)
                        .font(.system(size: 15))
                        .foregroundStyle(MockTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Bottom actions
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 16))
                    Text(LocalizedLabels.listen[locale] ?? "Listen")
                        .font(.system(size: 15))
                }
                .foregroundStyle(MockTheme.primary)

                HStack(spacing: 6) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 16))
                    Text(translationShowLabel())
                        .font(.system(size: 15))
                }
                .foregroundStyle(MockTheme.textSecondary)

                Spacer()

                Image(systemName: phrase.completed ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 18))
                    .foregroundStyle(phrase.completed ? MockTheme.accent : MockTheme.textTertiary)
            }

            // Mark as learned button
            if phrase.completed {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 13, weight: .bold))
                    Text(undoLearnedLabel())
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(MockTheme.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(MockTheme.surfaceSecondary)
                .clipShape(Capsule())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                    Text(LocalizedLabels.learnedDone[locale] ?? "Learned")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(MockTheme.secondary)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(MockTheme.secondary.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(18)
        .background(phrase.completed ? MockTheme.surface.opacity(0.6) : MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    phrase.completed ? MockTheme.secondary.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }

    private func translationShowLabel() -> String {
        switch locale {
        case "pt-BR": return "Ver tradução"
        case "es-ES", "es-MX": return "Ver traducción"
        default: return "Show translation"
        }
    }

    private func undoLearnedLabel() -> String {
        switch locale {
        case "pt-BR": return "Desfazer"
        case "es-ES", "es-MX": return "Deshacer"
        default: return "Undo"
        }
    }
}
