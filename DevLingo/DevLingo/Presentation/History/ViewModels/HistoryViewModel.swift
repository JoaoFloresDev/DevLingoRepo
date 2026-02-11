import SwiftUI

/// ViewModel for History screen.
final class HistoryViewModel: ObservableObject {
    // MARK: - Published

    @Published var currentMonth = Date()
    @Published var selectedDate: Date?
    @Published var history: [DailyPhraseSet] = []
    @Published var isLoading = true

    // MARK: - Properties

    private let dailyService = DailyPhraseService.shared
    private let phraseService = PhraseService.shared
    private var hasLoadedOnce = false

    // MARK: - Computed

    var monthTitle: String {
        currentMonth.monthYear
    }

    var daysInMonth: Int {
        currentMonth.daysInMonth
    }

    var firstWeekday: Int {
        currentMonth.firstWeekdayOfMonth
    }

    var historyDates: Set<String> {
        Set(history.map { $0.id })
    }

    func dailySet(for date: Date) -> DailyPhraseSet? {
        history.first { $0.id == date.dayString }
    }

    func hasData(for day: Int) -> Bool {
        let date = dateForDay(day)
        return historyDates.contains(date.dayString)
    }

    func completionProgress(for day: Int) -> Double {
        let date = dateForDay(day)
        return dailySet(for: date)?.progress ?? 0
    }

    func dateForDay(_ day: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month], from: currentMonth)
        components.day = day
        return Calendar.current.date(from: components) ?? currentMonth
    }

    func phrasesForSelectedDate() -> [Phrase] {
        guard let date = selectedDate,
              let set = dailySet(for: date) else { return [] }
        return phraseService.phrases(by: set.phraseIDs)
    }

    // MARK: - Data

    func loadData() {
        if !hasLoadedOnce {
            isLoading = true
            hasLoadedOnce = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.fetchHistory()
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.isLoading = false
                }
            }
        } else {
            fetchHistory()
        }
    }

    private func fetchHistory() {
        history = dailyService.getHistory()
    }

    // MARK: - Navigation

    func previousMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentMonth = currentMonth.adding(months: -1)
            selectedDate = nil
        }
        HapticManager.selection()
    }

    func nextMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentMonth = currentMonth.adding(months: 1)
            selectedDate = nil
        }
        HapticManager.selection()
    }

    func selectDay(_ day: Int) {
        let date = dateForDay(day)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            if selectedDate?.isSameDay(as: date) == true {
                selectedDate = nil
            } else {
                selectedDate = date
            }
        }
        HapticManager.lightImpact()
    }
}
