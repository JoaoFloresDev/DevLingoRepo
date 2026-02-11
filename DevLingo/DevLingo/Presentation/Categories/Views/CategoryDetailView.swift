import SwiftUI

/// Detail view showing all phrases in a category.
struct CategoryDetailView: View {
    // MARK: - Properties

    let category: PhraseCategory

    @State private var selectedDifficulty: PhraseDifficulty?
    @State private var showTranslations = false
    @State private var savedIDs: Set<String> = []

    private let phraseService = PhraseService.shared
    private let dailyService = DailyPhraseService.shared
    private let storage = StorageService.shared

    private var phrases: [Phrase] {
        let all = phraseService.phrases(for: category)
        if let diff = selectedDifficulty {
            return all.filter { $0.difficulty == diff }
        }
        return all
    }

    private var userLanguage: UserLanguage {
        guard let code = storage.getString(forKey: StorageKeys.selectedLanguage),
              let lang = UserLanguage(rawValue: code) else { return .ptBR }
        return lang
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    headerInfo
                    difficultyFilter
                    phrasesList
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .navigationTitle(category.label)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            savedIDs = storage.getStringSet(forKey: StorageKeys.savedPhraseIDs)
            showTranslations = storage.getBool(forKey: "showTranslations")
        }
    }

    // MARK: - Header Info

    private var headerInfo: some View {
        HStack(spacing: AppSpacing.lg) {
            Image(systemName: category.icon)
                .font(.system(size: 36))
                .foregroundStyle(category.color)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(category.label)
                    .font(AppFonts.title2)
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(phraseService.phrases(for: category).count) \(String(localized: "categories.phrases"))")
                    .font(AppFonts.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
    }

    // MARK: - Difficulty Filter

    private var difficultyFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                FilterChip(
                    title: String(localized: "filter.all"),
                    isSelected: selectedDifficulty == nil,
                    color: AppColors.primary
                ) {
                    withAnimation(.spring(response: 0.25)) { selectedDifficulty = nil }
                }

                ForEach(PhraseDifficulty.allCases, id: \.self) { diff in
                    FilterChip(
                        title: diff.label,
                        isSelected: selectedDifficulty == diff,
                        color: diff.color
                    ) {
                        withAnimation(.spring(response: 0.25)) { selectedDifficulty = diff }
                    }
                }
            }
        }
    }

    // MARK: - Phrases List

    private var phrasesList: some View {
        LazyVStack(spacing: AppSpacing.md) {
            ForEach(phrases) { phrase in
                PhraseCardView(
                    phrase: phrase,
                    language: userLanguage,
                    showTranslation: showTranslations,
                    isCompleted: dailyService.isCompleted(phrase.id),
                    isSaved: savedIDs.contains(phrase.id),
                    onComplete: {
                        dailyService.markCompleted(phrase.id)
                        ProgressService.shared.markPhraseCompleted(phrase)
                        HapticManager.success()
                    },
                    onSave: {
                        dailyService.toggleSaved(phrase.id)
                        if savedIDs.contains(phrase.id) {
                            savedIDs.remove(phrase.id)
                        } else {
                            savedIDs.insert(phrase.id)
                        }
                        HapticManager.lightImpact()
                    },
                    onSpeak: { SpeechManager.shared.speak(phrase.english) }
                )
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.footnote)
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? color : color.opacity(0.15))
                .clipShape(Capsule())
        }
    }
}
