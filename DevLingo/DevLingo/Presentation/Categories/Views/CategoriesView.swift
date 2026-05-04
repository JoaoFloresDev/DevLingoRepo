import SwiftUI

/// Browse all 13 phrase categories.
struct CategoriesView: View {
    // MARK: - Properties

    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showPaywall = false

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    headerTitle
                    categoriesGrid
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Header

    private var headerTitle: some View {
        HStack {
            Text(String(localized: "categories.title"))
                .font(AppFonts.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Grid

    @ViewBuilder
    private var categoriesGrid: some View {
        if viewModel.isLoading {
            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(0..<6, id: \.self) { _ in
                    SkeletonView(height: 130, cornerRadius: AppSpacing.cornerRadiusLarge)
                }
            }
        } else {
            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(viewModel.filteredCategories) { category in
                    categoryCell(for: category)
                }
            }
        }
    }

    // MARK: - Category Cell

    @ViewBuilder
    private func categoryCell(for category: PhraseCategory) -> some View {
        let isLocked = category.isPremium && !FeatureFlags.hasPremiumAccess()

        if isLocked {
            Button {
                showPaywall = true
                HapticManager.mediumImpact()
            } label: {
                CategoryCard(
                    category: category,
                    phraseCount: viewModel.phraseCount(for: category),
                    isLocked: true
                )
            }
        } else {
            NavigationLink(destination: CategoryDetailView(category: category)) {
                CategoryCard(
                    category: category,
                    phraseCount: viewModel.phraseCount(for: category)
                )
            }
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: PhraseCategory
    let phraseCount: Int
    var isLocked: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: AppSpacing.md) {
                Image(systemName: isLocked ? "lock.fill" : category.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(isLocked ? AppColors.textTertiary : category.color)

                Text(category.label)
                    .font(AppFonts.headline)
                    .foregroundStyle(isLocked ? AppColors.textTertiary : AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("\(phraseCount) \(String(localized: "categories.phrases"))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .padding(.vertical, AppSpacing.xl)
            .padding(.horizontal, AppSpacing.md)
            .background(isLocked ? AppColors.surface.opacity(0.6) : AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                    .strokeBorder(
                        isLocked ? AppColors.textTertiary.opacity(0.2) : category.color.opacity(0.2),
                        lineWidth: 1
                    )
            )

            if isLocked {
                Text("PRO")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.accent)
                    .clipShape(Capsule())
                    .padding(8)
            }
        }
    }
}
