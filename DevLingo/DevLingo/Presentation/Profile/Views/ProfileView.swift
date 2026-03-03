import SwiftUI

/// Profile screen showing user stats and settings.
struct ProfileView: View {
    // MARK: - Properties

    @StateObject private var viewModel = ProfileViewModel()

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    headerSection
                    levelCard
                    statsSection
                    settingsSection
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .onAppear { viewModel.loadData() }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "profile.title"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(String(localized: "profile.subtitle"))
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(.top, AppSpacing.md)
    }

    private var levelCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "profile.level %lld", defaultValue: "Level \(viewModel.progress.level)"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(viewModel.progress.levelTitle)
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.primary)
                }
                Spacer()

                ZStack {
                    Circle()
                        .stroke(AppColors.surfaceSecondary, lineWidth: 8)
                        .frame(width: 70, height: 70)

                    Circle()
                        .trim(from: 0, to: viewModel.progress.levelProgress)
                        .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 70, height: 70)

                    Text("\(Int(viewModel.progress.levelProgress * 100))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }

            ProgressView(value: viewModel.progress.levelProgress)
                .tint(AppColors.primary)

            Text(String(localized: "profile.phrases_to_next %lld", defaultValue: "\(viewModel.progress.phrasesToNextLevel) phrases to next level"))
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textTertiary)

            Divider().background(AppColors.surfaceSecondary)

            HStack(spacing: AppSpacing.xl) {
                statItem(
                    icon: "flame.fill",
                    color: AppColors.accent,
                    value: "\(viewModel.progress.currentStreak)",
                    label: String(localized: "profile.current_streak")
                )

                statItem(
                    icon: "trophy.fill",
                    color: AppColors.secondary,
                    value: "\(viewModel.progress.longestStreak)",
                    label: String(localized: "profile.longest_streak")
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func statItem(icon: String, color: Color, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statsSection: some View {
        VStack(spacing: 0) {
            statsRow(
                icon: "checkmark.circle.fill",
                color: AppColors.secondary,
                title: String(localized: "profile.total_learned"),
                value: "\(viewModel.progress.totalPhrasesLearned)"
            )

            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)

            statsRow(
                icon: "bookmark.fill",
                color: AppColors.primary,
                title: String(localized: "profile.saved"),
                value: "\(viewModel.savedCount)"
            )

            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)

            statsRow(
                icon: "exclamationmark.triangle.fill",
                color: AppColors.accent,
                title: String(localized: "profile.hard"),
                value: "\(viewModel.hardCount)"
            )
        }
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func statsRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, 14)
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "globe", title: String(localized: "profile.language"))
            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)
            settingsRow(icon: "bell.fill", title: String(localized: "profile.notifications"))
            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)
            settingsRow(icon: "star.fill", title: String(localized: "profile.rate_app"))
            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)
            settingsRow(icon: "square.and.arrow.up", title: String(localized: "profile.share_app"))
            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)
            settingsRow(icon: "info.circle", title: String(localized: "profile.about"))
        }
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.primary)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, 14)
    }
}
