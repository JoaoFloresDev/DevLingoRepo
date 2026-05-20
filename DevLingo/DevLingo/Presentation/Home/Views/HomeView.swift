import SwiftUI

/// Home screen — today's 10 phrases.
struct HomeView: View {
    // MARK: - Properties

    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var router = AppRouter.shared
    @State private var highlightedPhraseID: String?

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        headerSection
                        streakAndProgress
                        translationToggle
                        phrasesSection
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.xxl)
                }
                .onChange(of: router.pendingPhraseID) { _, newValue in
                    guard let id = newValue else { return }
                    focusPhrase(id, proxy: proxy)
                }
                .onChange(of: viewModel.isLoading) { _, isLoading in
                    if !isLoading, let id = router.pendingPhraseID {
                        focusPhrase(id, proxy: proxy)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    // MARK: - Deep Link

    private func focusPhrase(_ id: String, proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                proxy.scrollTo(id, anchor: .center)
            }
            withAnimation(.easeOut(duration: 0.2)) {
                highlightedPhraseID = id
            }
            HapticManager.lightImpact()
            router.clearPendingPhrase()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.4)) {
                    if highlightedPhraseID == id {
                        highlightedPhraseID = nil
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(String(localized: "home.greeting"))
                .font(AppFonts.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            Text(String(localized: "home.title"))
                .font(AppFonts.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Streak & Progress

    private var streakAndProgress: some View {
        HStack(spacing: AppSpacing.md) {
            // Streak card
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(AppColors.accent)
                        .font(.system(size: 20))

                    Text("\(viewModel.progress.currentStreak)")
                        .font(AppFonts.statNumber)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text(String(localized: "home.streak_days"))
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))

            // Progress card
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.secondary)
                        .font(.system(size: 20))

                    Text("\(viewModel.completedCount)/\(viewModel.todayPhrases.count)")
                        .font(AppFonts.statNumber)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text(String(localized: "home.today_progress"))
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))

            // Level card
            VStack(spacing: AppSpacing.xs) {
                Text("Lv.\(viewModel.progress.level)")
                    .font(AppFonts.statNumber)
                    .foregroundStyle(AppColors.primary)

                Text(viewModel.progress.levelTitle)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        }
    }

    // MARK: - Translation Toggle

    private var translationToggle: some View {
        HStack {
            Image(systemName: viewModel.showTranslations ? "eye.fill" : "eye.slash.fill")
                .foregroundStyle(AppColors.primary)
                .font(.system(size: 14))

            Text(viewModel.showTranslations
                 ? String(localized: "home.translations_visible")
                 : String(localized: "home.translations_hidden"))
                .font(AppFonts.footnote)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Toggle("", isOn: Binding(
                get: { viewModel.showTranslations },
                set: { _ in viewModel.toggleTranslations() }
            ))
            .tint(AppColors.primary)
            .labelsHidden()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }

    // MARK: - Phrases Section

    private var phrasesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(String(localized: "home.todays_phrases"))
                    .font(AppFonts.title3)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()
            }

            if viewModel.isLoading {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonView(height: 120, cornerRadius: AppSpacing.cornerRadiusLarge)
                }
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(Array(viewModel.todayPhrases.enumerated()), id: \.element.id) { index, phrase in
                        PhraseCardView(
                            phrase: phrase,
                            language: viewModel.userLanguage,
                            showTranslation: viewModel.showTranslations,
                            isCompleted: viewModel.isCompleted(phrase),
                            isSaved: viewModel.isSaved(phrase),
                            onComplete: { viewModel.markCompleted(phrase) },
                            onUncomplete: { viewModel.markUncompleted(phrase) },
                            onSave: { viewModel.toggleSaved(phrase) },
                            onSpeak: { viewModel.speak(phrase) }
                        )
                        .id(phrase.id)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                                .stroke(AppColors.primary, lineWidth: highlightedPhraseID == phrase.id ? 2 : 0)
                                .animation(.easeOut(duration: 0.25), value: highlightedPhraseID)
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                        .animation(
                            .spring(response: 0.35, dampingFraction: 0.85).delay(Double(index) * 0.04),
                            value: viewModel.todayPhrases.count
                        )
                    }
                }
            }
        }
    }
}
