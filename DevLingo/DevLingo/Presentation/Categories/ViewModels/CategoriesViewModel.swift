import SwiftUI

/// ViewModel for Categories screen.
final class CategoriesViewModel: ObservableObject {
    // MARK: - Published

    @Published var categories: [PhraseCategory] = PhraseCategory.allCases
    @Published var isLoading = true
    @Published var searchText = ""

    // MARK: - Properties

    private let phraseService = PhraseService.shared
    private var hasLoadedOnce = false

    // MARK: - Computed

    var filteredCategories: [PhraseCategory] {
        if searchText.isEmpty { return categories }
        return categories.filter { $0.label.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Data

    func loadData() {
        if !hasLoadedOnce {
            isLoading = true
            hasLoadedOnce = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.isLoading = false
                }
            }
        } else {
            objectWillChange.send()
        }
    }

    func phraseCount(for category: PhraseCategory) -> Int {
        phraseService.phrases(for: category).count
    }

    func phrases(for category: PhraseCategory) -> [Phrase] {
        phraseService.phrases(for: category)
    }
}
