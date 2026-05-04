import SwiftUI
import StoreKit

/// Full-screen paywall for premium subscription.
struct PaywallView: View {
    // MARK: - Properties

    @StateObject private var purchaseService = PurchaseService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    closeButton

                    if purchaseService.isPremium {
                        subscribedContent
                    } else {
                        purchaseContent
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxxl)
            }
        }
        .preferredColorScheme(.dark)
        .alert(String(localized: "paywall.error_title"), isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            preselectYearly()
        }
        .onReceive(purchaseService.$products) { _ in
            preselectYearly()
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Subscribed Content

    private var subscribedContent: some View {
        VStack(spacing: AppSpacing.xl) {
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.secondary)

                Text(String(localized: "paywall.subscribed_title"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(String(localized: "paywall.subscribed_subtitle"))
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 0) {
                benefitRow(icon: "square.grid.2x2.fill", text: String(localized: "paywall.benefit_all_categories"))
                Divider().background(AppColors.surfaceSecondary).padding(.horizontal)
                benefitRow(icon: "text.quote", text: String(localized: "paywall.benefit_phrases"))
                Divider().background(AppColors.surfaceSecondary).padding(.horizontal)
                benefitRow(icon: "sparkles", text: String(localized: "paywall.benefit_new_content"))
                Divider().background(AppColors.surfaceSecondary).padding(.horizontal)
                benefitRow(icon: "headphones", text: String(localized: "paywall.benefit_support"))
            }
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))

            Text(String(localized: "paywall.thanks"))
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppColors.secondary)
                .frame(width: 32)

            Text(text)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppColors.secondary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, 14)
    }

    // MARK: - Purchase Content

    private var purchaseContent: some View {
        VStack(spacing: AppSpacing.xl) {
            headerSection
            featuresSection
            productsSection
            restoreButton
            termsFooter
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.accent)

            Text(String(localized: "paywall.title"))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: "paywall.subtitle"))
                .font(.system(size: 17))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: AppSpacing.md) {
            featureRow(icon: "square.grid.2x2.fill", text: String(localized: "paywall.feature_all_categories"))
            featureRow(icon: "infinity", text: String(localized: "paywall.feature_unlimited"))
            featureRow(icon: "star.fill", text: String(localized: "paywall.feature_new_content"))
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppColors.accent)
                .frame(width: 32)

            Text(text)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.secondary)
        }
    }

    // MARK: - Products

    private var productsSection: some View {
        VStack(spacing: AppSpacing.md) {
            if purchaseService.isLoading {
                SkeletonView(height: 80, cornerRadius: AppSpacing.cornerRadiusLarge)
                SkeletonView(height: 80, cornerRadius: AppSpacing.cornerRadiusLarge)
            } else {
                if let yearly = purchaseService.yearlyProduct {
                    productCard(product: yearly, badge: String(localized: "paywall.best_value"))
                }

                if let monthly = purchaseService.monthlyProduct {
                    productCard(product: monthly, badge: nil)
                }
            }

            purchaseButton
        }
    }

    private func productCard(product: Product, badge: String?) -> some View {
        let isSelected = selectedProduct?.id == product.id

        return Button {
            selectedProduct = product
            HapticManager.selection()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: AppSpacing.sm) {
                        Text(product.displayName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColors.accent)
                                .clipShape(Capsule())
                        }
                    }

                    Text(product.description)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
            }
            .padding(AppSpacing.lg)
            .background(isSelected ? AppColors.accent.opacity(0.1) : AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                    .strokeBorder(
                        isSelected ? AppColors.accent : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .pressAnimation()
    }

    private var purchaseButton: some View {
        Button {
            Task { await handlePurchase() }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(String(localized: "paywall.subscribe"))
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(AppColors.accent)
            .clipShape(Capsule())
        }
        .pressAnimation()
        .disabled(selectedProduct == nil || isPurchasing)
        .opacity(selectedProduct == nil ? 0.5 : 1)
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button {
            Task {
                await purchaseService.restorePurchases()
                if purchaseService.isPremium {
                    HapticManager.success()
                    dismiss()
                }
            }
        } label: {
            Text(String(localized: "paywall.restore"))
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Terms & Legal

    private var termsFooter: some View {
        VStack(spacing: 12) {
            Text(String(localized: "paywall.subscription_info"))
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textTertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button {
                    if let url = URL(string: AppConstants.termsOfUseURL) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(String(localized: "paywall.terms_link"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .underline()
                }

                Button {
                    if let url = URL(string: AppConstants.privacyPolicyURL) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(String(localized: "paywall.privacy_link"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .underline()
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Actions

    private func preselectYearly() {
        if selectedProduct == nil, let yearly = purchaseService.yearlyProduct {
            selectedProduct = yearly
        } else if selectedProduct == nil, let first = purchaseService.products.last {
            selectedProduct = first
        }
    }

    private func handlePurchase() async {
        guard let product = selectedProduct else { return }
        isPurchasing = true

        do {
            let success = try await purchaseService.purchase(product)
            if success {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            HapticManager.error()
        }

        isPurchasing = false
    }
}
