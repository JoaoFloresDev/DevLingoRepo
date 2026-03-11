import SwiftUI

/// Sheet displaying a list of phrases (learned, saved, or hard).
struct PhraseListSheet: View {
    // MARK: - Properties

    let title: String
    let phrases: [Phrase]
    let language: UserLanguage

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.textTertiary)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)

                if phrases.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.textTertiary)

                        Text(String(localized: "profile.no_phrases"))
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(phrases) { phrase in
                                phraseRow(phrase)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.bottom, AppSpacing.xxl)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Subviews

    private func phraseRow(_ phrase: Phrase) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                DifficultyBadge(difficulty: phrase.difficulty)

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
            }

            Text(phrase.english)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Text(phrase.translation(for: language))
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }
}
