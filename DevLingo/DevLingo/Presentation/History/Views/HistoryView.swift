import SwiftUI

/// History screen with calendar and past phrases.
struct HistoryView: View {
    // MARK: - Properties

    @StateObject private var viewModel = HistoryViewModel()

    private let weekdays = Calendar.current.shortWeekdaySymbols

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    headerTitle
                    calendarSection
                    selectedDayPhrases
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    // MARK: - Header

    private var headerTitle: some View {
        HStack {
            Text(String(localized: "history.title"))
                .font(AppFonts.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Month navigation
            HStack {
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }

                Spacer()

                Text(viewModel.monthTitle)
                    .font(AppFonts.title3)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }
            }

            // Weekday headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: AppSpacing.sm) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            if viewModel.isLoading {
                SkeletonView(height: 250, cornerRadius: AppSpacing.cornerRadius)
            } else {
                calendarGrid
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let firstWeekday = viewModel.firstWeekday
        let daysInMonth = viewModel.daysInMonth
        let offset = firstWeekday - 1

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: AppSpacing.sm) {
            // Empty cells for offset
            ForEach(0..<offset, id: \.self) { _ in
                Color.clear.frame(height: 40)
            }

            // Day cells
            ForEach(1...daysInMonth, id: \.self) { day in
                DayCell(
                    day: day,
                    hasData: viewModel.hasData(for: day),
                    progress: viewModel.completionProgress(for: day),
                    isSelected: viewModel.selectedDate?.dayOfMonth == day,
                    isToday: viewModel.dateForDay(day).isToday
                ) {
                    viewModel.selectDay(day)
                }
            }
        }
    }

    // MARK: - Selected Day Phrases

    @ViewBuilder
    private var selectedDayPhrases: some View {
        if let date = viewModel.selectedDate {
            let phrases = viewModel.phrasesForSelectedDate()

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text(date.shortDateString)
                        .font(AppFonts.title3)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    if let set = viewModel.dailySet(for: date) {
                        Text("\(set.completedCount)/\(set.totalCount)")
                            .font(AppFonts.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                if phrases.isEmpty {
                    emptyDayState
                } else {
                    let storage = StorageService.shared
                    let showTrans = storage.getBool(forKey: "showTranslations")
                    let langCode = storage.getString(forKey: StorageKeys.selectedLanguage) ?? "pt-BR"
                    let lang = UserLanguage(rawValue: langCode) ?? .ptBR

                    ForEach(phrases) { phrase in
                        MiniPhraseCard(phrase: phrase, language: lang, showTranslation: showTrans)
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    // MARK: - Empty Day

    private var emptyDayState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.textTertiary)

            Text(String(localized: "history.no_phrases"))
                .font(AppFonts.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let day: Int
    let hasData: Bool
    let progress: Double
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(AppColors.primary)
                } else if isToday {
                    Circle()
                        .strokeBorder(AppColors.primary, lineWidth: 2)
                } else if hasData {
                    Circle()
                        .fill(AppColors.secondary.opacity(progress))
                }

                Text("\(day)")
                    .font(AppFonts.footnote)
                    .foregroundStyle(
                        isSelected ? .white :
                        hasData ? AppColors.textPrimary :
                        AppColors.textTertiary
                    )
            }
            .frame(height: 40)
        }
    }
}

// MARK: - Mini Phrase Card

struct MiniPhraseCard: View {
    let phrase: Phrase
    let language: UserLanguage
    let showTranslation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                DifficultyBadge(difficulty: phrase.difficulty)
                Spacer()
                Image(systemName: phrase.category.icon)
                    .font(.system(size: 12))
                    .foregroundStyle(phrase.category.color)
            }

            Text(phrase.english)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textPrimary)

            Text(phrase.context)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textTertiary)

            if showTranslation {
                Text(phrase.translation(for: language))
                    .font(AppFonts.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }
}
