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
                .foregroundStyle(isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                .strikethrough(isCompleted, color: AppColors.textTertiary)
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
        HStack(spacing: AppSpacing.lg) {
            // Listen
            Button(action: onSpeak) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 13))
                    Text(String(localized: "phrase.listen"))
                        .font(AppFonts.caption)
                }
                .foregroundStyle(AppColors.primary)
            }

            // Show/hide translation
            if !showTranslation {
                Button {
                    withAnimation { showLocalTranslation.toggle() }
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: showLocalTranslation ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 13))
                        Text(showLocalTranslation
                             ? String(localized: "phrase.hide_translation")
                             : String(localized: "phrase.show_translation"))
                            .font(AppFonts.caption)
                    }
                    .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()

            // Save
            Button(action: onSave) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 15))
                    .foregroundStyle(isSaved ? AppColors.accent : AppColors.textTertiary)
            }

            // Complete
            if !isCompleted {
                Button(action: onComplete) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                        Text(String(localized: "phrase.learned"))
                            .font(AppFonts.caption)
                    }
                    .foregroundStyle(AppColors.secondary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.secondary.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
    }
}
