import SwiftUI
import StoreKit

/// Profile screen showing user stats and settings.
struct ProfileView: View {
    // MARK: - Properties

    @StateObject private var viewModel = ProfileViewModel()
    @State private var showLanguagePicker = false
    @State private var showNotificationSettings = false
    @State private var showLearnedPhrases = false
    @State private var showSavedPhrases = false
    @State private var showHardPhrases = false

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
                    appInfoFooter
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .onAppear { viewModel.loadData() }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLearnedPhrases) {
            PhraseListSheet(
                title: String(localized: "profile.total_learned"),
                phrases: viewModel.getLearnedPhrases(),
                language: viewModel.userLanguage
            )
        }
        .sheet(isPresented: $showSavedPhrases) {
            PhraseListSheet(
                title: String(localized: "profile.saved"),
                phrases: viewModel.getSavedPhrases(),
                language: viewModel.userLanguage
            )
        }
        .sheet(isPresented: $showHardPhrases) {
            PhraseListSheet(
                title: String(localized: "profile.hard"),
                phrases: viewModel.getHardPhrases(),
                language: viewModel.userLanguage
            )
        }
    }

    // MARK: - Header

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

    // MARK: - Level Card

    private var levelCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "profile.level \(viewModel.progress.level)"))
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

            Text(String(localized: "profile.phrases_to_next \(viewModel.progress.phrasesToNextLevel)"))
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
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
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

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: 0) {
            Button { showLearnedPhrases = true } label: {
                statsRow(
                    icon: "checkmark.circle.fill",
                    color: AppColors.secondary,
                    title: String(localized: "profile.total_learned"),
                    value: "\(viewModel.progress.totalPhrasesLearned)"
                )
            }

            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)

            Button { showSavedPhrases = true } label: {
                statsRow(
                    icon: "bookmark.fill",
                    color: AppColors.primary,
                    title: String(localized: "profile.saved"),
                    value: "\(viewModel.savedCount)"
                )
            }

            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)

            Button { showHardPhrases = true } label: {
                statsRow(
                    icon: "exclamationmark.triangle.fill",
                    color: AppColors.accent,
                    title: String(localized: "profile.hard"),
                    value: "\(viewModel.hardCount)"
                )
            }
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
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

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(spacing: 0) {
            Button { showLanguagePicker = true } label: {
                settingsRow(icon: "globe", title: String(localized: "profile.language"),
                            detail: viewModel.currentLanguageName)
            }

            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)

            Button { showNotificationSettings = true } label: {
                settingsRow(icon: "bell.fill", title: String(localized: "profile.notifications"))
            }

            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)

            Button { rateApp() } label: {
                settingsRow(icon: "star.fill", title: String(localized: "profile.rate_app"))
            }

            Divider().background(AppColors.surfaceSecondary).padding(.horizontal)

            ShareLink(
                item: URL(string: "https://apps.apple.com/app/devlingo/id6759974641")!,
                subject: Text("DevLingo"),
                message: Text(String(localized: "profile.share_message"))
            ) {
                settingsRow(icon: "square.and.arrow.up", title: String(localized: "profile.share_app"))
            }
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
    }

    private func settingsRow(icon: String, title: String, detail: String? = nil) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.primary)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            if let detail {
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, 14)
    }

    // MARK: - App Info

    private var appInfoFooter: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("DevLingo")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)

            Text(String(localized: "profile.version \(appVersion)"))
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.md)
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        HapticManager.success()
    }
}
