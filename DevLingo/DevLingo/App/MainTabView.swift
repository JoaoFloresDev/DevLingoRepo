import SwiftUI

/// Main tab navigation.
struct MainTabView: View {
    // MARK: - Properties

    @State private var selectedTab = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(String(localized: "tab.home"), systemImage: "house.fill")
                }
                .tag(0)

            CategoriesView()
                .tabItem {
                    Label(String(localized: "tab.categories"), systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label(String(localized: "tab.history"), systemImage: "calendar")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label(String(localized: "tab.profile"), systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .tint(AppColors.primary)
        .onAppear {
            ReviewService.shared.requestReviewIfNeeded()
        }
    }
}
