import SwiftUI

/// Onboarding flow — 3 steps.
struct OnboardingView: View {
    // MARK: - Properties

    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage(StorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                progressDots
                    .padding(.top, AppSpacing.xl)

                // Content
                TabView(selection: $viewModel.currentPage) {
                    languagePage.tag(0)
                    translationPage.tag(1)
                    notificationPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.currentPage)

                // Bottom button
                bottomButton
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.xxl)
            }
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<viewModel.totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.currentPage ? AppColors.primary : AppColors.surfaceTertiary)
                    .frame(width: index == viewModel.currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: viewModel.currentPage)
            }
        }
    }

    // MARK: - Page 1: Language Selection

    private var languagePage: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.primary)
                .symbolEffect(.pulse.wholeSymbol, options: .repeating)

            Text(String(localized: "onboarding.select_language"))
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: "onboarding.select_language_subtitle"))
                .font(AppFonts.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            // Language grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                    ForEach(UserLanguage.allCases) { language in
                        Button {
                            viewModel.selectedLanguage = language
                            HapticManager.selection()
                        } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Text(language.flag)
                                    .font(.system(size: 24))

                                Text(language.nativeName)
                                    .font(AppFonts.subheadline)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .lineLimit(1)

                                Spacer()
                            }
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                viewModel.selectedLanguage == language
                                ? AppColors.primary.opacity(0.2)
                                : AppColors.surface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                                    .strokeBorder(
                                        viewModel.selectedLanguage == language
                                        ? AppColors.primary : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
            }

            Spacer()
        }
    }

    // MARK: - Page 2: Translation Preference

    private var translationPage: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "text.bubble.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.secondary)

            Text(String(localized: "onboarding.translation_title"))
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: "onboarding.translation_subtitle"))
                .font(AppFonts.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.screenPadding)

            VStack(spacing: AppSpacing.lg) {
                Button {
                    viewModel.showTranslations = true
                    HapticManager.selection()
                } label: {
                    optionCard(
                        icon: "eye.fill",
                        title: String(localized: "onboarding.show_translations"),
                        subtitle: String(localized: "onboarding.show_translations_desc"),
                        isSelected: viewModel.showTranslations
                    )
                }

                Button {
                    viewModel.showTranslations = false
                    HapticManager.selection()
                } label: {
                    optionCard(
                        icon: "eye.slash.fill",
                        title: String(localized: "onboarding.hide_translations"),
                        subtitle: String(localized: "onboarding.hide_translations_desc"),
                        isSelected: !viewModel.showTranslations
                    )
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()
        }
    }

    // MARK: - Page 3: Notifications

    private var notificationPage: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.accent)

            Text(String(localized: "onboarding.notifications_title"))
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: "onboarding.notifications_subtitle"))
                .font(AppFonts.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.screenPadding)

            // Count selector
            VStack(spacing: AppSpacing.md) {
                Text(String(localized: "onboarding.phrases_per_day"))
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)

                HStack(spacing: AppSpacing.lg) {
                    ForEach(1...4, id: \.self) { count in
                        Button {
                            viewModel.notificationCount = count
                            HapticManager.selection()
                        } label: {
                            VStack(spacing: AppSpacing.xs) {
                                Text("\(count)")
                                    .font(AppFonts.statNumber)
                                    .foregroundStyle(
                                        viewModel.notificationCount == count
                                        ? .white : AppColors.textSecondary
                                    )
                            }
                            .frame(width: 56, height: 56)
                            .background(
                                viewModel.notificationCount == count
                                ? AppColors.primary : AppColors.surface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
                        }
                    }
                }

                Text(String(localized: "onboarding.notifications_spread"))
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()
        }
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        Button {
            if viewModel.currentPage < viewModel.totalPages - 1 {
                viewModel.nextPage()
            } else {
                viewModel.completeOnboarding()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    hasCompletedOnboarding = true
                }
            }
        } label: {
            Text(viewModel.currentPage < viewModel.totalPages - 1
                 ? String(localized: "onboarding.next")
                 : String(localized: "onboarding.start"))
                .font(AppFonts.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        }
    }

    // MARK: - Option Card

    private func optionCard(icon: String, title: String, subtitle: String, isSelected: Bool) -> some View {
        HStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(isSelected ? AppColors.primary : AppColors.textTertiary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? AppColors.primary : AppColors.textTertiary)
                .font(.system(size: 22))
        }
        .padding(AppSpacing.lg)
        .background(isSelected ? AppColors.primary.opacity(0.1) : AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                .strokeBorder(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
        )
    }
}
