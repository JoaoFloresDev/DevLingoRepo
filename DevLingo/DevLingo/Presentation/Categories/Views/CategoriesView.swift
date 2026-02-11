import SwiftUI

/// Browse all 12 phrase categories.
struct CategoriesView: View {
    // MARK: - Properties

    @StateObject private var viewModel = CategoriesViewModel()

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
                    searchBar
                    categoriesGrid
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
            Text(String(localized: "categories.title"))
                .font(AppFonts.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textTertiary)
                .font(.system(size: 16))

            TextField(String(localized: "categories.search"), text: $viewModel.searchText)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }

    // MARK: - Grid

    private var categoriesGrid: some View {
        Group {
            if viewModel.isLoading {
                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(0..<6, id: \.self) { _ in
                        SkeletonView(height: 130, cornerRadius: AppSpacing.cornerRadiusLarge)
                    }
                }
            } else {
                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(viewModel.filteredCategories) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            CategoryCard(
                                category: category,
                                phraseCount: viewModel.phraseCount(for: category)
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: PhraseCategory
    let phraseCount: Int

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: category.icon)
                .font(.system(size: 28))
                .foregroundStyle(category.color)

            Text(category.label)
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("\(phraseCount) \(String(localized: "categories.phrases"))")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .padding(.horizontal, AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                .strokeBorder(category.color.opacity(0.2), lineWidth: 1)
        )
    }
}
