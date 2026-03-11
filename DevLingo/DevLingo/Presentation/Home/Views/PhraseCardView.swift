import SwiftUI

/// Card displaying a single phrase with context and translation.
struct PhraseCardView: View {
    // MARK: - Properties

    let phrase: Phrase
    let language: UserLanguage
    let showTranslation: Bool
    let isCompleted: Bool
    let isSaved: Bool
    let onComplete: () -> Void
    let onUncomplete: () -> Void
    let onSave: () -> Void
    let onSpeak: () -> Void

    @State private var showLocalTranslation = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Top row: difficulty badge + category + actions
            topRow

            // English phrase
            Text(phrase.english)
                .font(AppFonts.phraseEnglish)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Context
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textTertiary)

                Text(phrase.context)
                    .font(AppFonts.phraseContext)
                    .foregroundStyle(AppColors.textTertiary)
            }

            // Translation (toggle)
            if showTranslation || showLocalTranslation {
                translationView
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Bottom actions
            bottomRow
        }
        .padding(AppSpacing.lg)
        .background(isCompleted ? AppColors.surface.opacity(0.6) : AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                .strokeBorder(
                    isCompleted ? AppColors.secondary.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showTranslation)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showLocalTranslation)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCompleted)
    }

    // MARK: - Top Row

    private var topRow: some View {
        HStack(spacing: AppSpacing.sm) {
            // Difficulty badge
            DifficultyBadge(difficulty: phrase.difficulty)

            // Category
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: phrase.category.icon)
                    .font(.system(size: 10))
                Text(phrase.category.label)
                    .font(AppFonts.caption2)
            }
            .foregroundStyle(phrase.category.color)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(phrase.category.color.opacity(0.15))
            .clipShape(Capsule())

            Spacer()

            // Completed check
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.secondary)
                    .font(.system(size: 18))
            }
        }
    }

    // MARK: - Translation

    private var translationView: some View {
        HStack(spacing: AppSpacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.primary.opacity(0.5))
                .frame(width: 3)

            Text(phrase.translation(for: language))
                .font(AppFonts.phraseTranslation)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.leading, AppSpacing.xs)
    }

    // MARK: - Bottom Row

    private var bottomRow: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.lg) {
                // Listen
                Button(action: onSpeak) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                        Text(String(localized: "phrase.listen"))
                            .font(AppFonts.body)
                    }
                    .foregroundStyle(AppColors.primary)
                    .padding(.vertical, AppSpacing.xs)
                }
                .pressAnimation()

                // Show/hide translation
                if !showTranslation {
                    Button {
                        withAnimation { showLocalTranslation.toggle() }
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: showLocalTranslation ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 16))
                            Text(showLocalTranslation
                                 ? String(localized: "phrase.hide_translation")
                                 : String(localized: "phrase.show_translation"))
                                .font(AppFonts.body)
                        }
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.vertical, AppSpacing.xs)
                    }
                }

                Spacer()

                // Save
                Button(action: onSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundStyle(isSaved ? AppColors.accent : AppColors.textTertiary)
                        .padding(AppSpacing.xs)
                }
                .pressAnimation()
            }

            // Complete / Uncomplete
            if isCompleted {
                Button(action: onUncomplete) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 14, weight: .bold))
                        Text(String(localized: "phrase.undo_learned"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
                }
                .pressAnimation()
            } else {
                Button(action: onComplete) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text(String(localized: "phrase.learned"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(AppColors.secondary)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(AppColors.secondary.opacity(0.15))
                    .clipShape(Capsule())
                }
                .pressAnimation()
            }
        }
    }
}
