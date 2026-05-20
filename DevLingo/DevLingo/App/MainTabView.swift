import SwiftUI

/// Main tab navigation.
struct MainTabView: View {
    // MARK: - Properties

    @StateObject private var router = AppRouter.shared
    @State private var showPaywall = false

    // MARK: - Body

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Label(String(localized: "tab.home"), systemImage: "house.fill")
                }
                .tag(0)

            NavigationStack {
                CategoriesView()
            }
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
            checkPaywallOnLaunch()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Private

    private func checkPaywallOnLaunch() {
        guard !FeatureFlags.hasPremiumAccess() else { return }
        let count = ReviewService.shared.launchCount()
        if count >= 15 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showPaywall = true
            }
        }
    }
}
