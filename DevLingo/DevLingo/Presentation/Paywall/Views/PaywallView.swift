import SwiftUI
import StoreKit

// MARK: - PaywallTheme

/// Brand gradient + accents for the paywall, matching DevLingo's indigo→purple identity.
/// Mirrors the steps / PaywallKit paywall model.
enum PaywallTheme {
    /// Dark canvas with a subtle purple tint at the top.
    static let gradient = LinearGradient(
        colors: [Color(hex: "1A1430"), Color.black],
        startPoint: .top,
        endPoint: .bottom
    )
    /// Hero crown gradient (indigo → purple).
    static let crownGradient = LinearGradient(
        colors: [AppColors.primary, Color(hex: "BF5AF2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - PaywallView

/// Premium paywall — steps/PaywallKit model in DevLingo's purple theme: brand gradient,
/// pulsing crown header, benefit list, selectable plans (yearly / monthly with optional
/// 3-day trial), gradient CTA, restore and legal links.
struct PaywallView: View {
    // MARK: - Properties

    /// Where the paywall was opened from (analytics): post_onboarding / launch / category_locked / profile.
    var source: String = "unknown"

    // MARK: - State

    @StateObject private var purchaseService = PurchaseService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: Plan = .yearly
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    @State private var showHeader = false
    @State private var showBenefits = false
    @State private var showPlans = false
    @State private var showButton = false
    @State private var iconPulse = false

    private enum Plan { case monthly, yearly }

    // MARK: - Constants

    private let benefits: [(String, String)] = [
        ("square.grid.2x2.fill", String(localized: "paywall.benefit_all_categories")),
        ("text.quote", String(localized: "paywall.benefit_phrases")),
        ("sparkles", String(localized: "paywall.benefit_new_content")),
        ("headphones", String(localized: "paywall.benefit_support"))
    ]

    // MARK: - Computed Properties

    private var selectedProduct: Product? {
        selectedPlan == .yearly ? purchaseService.yearlyProduct : purchaseService.monthlyProduct
    }

    private var hasFreeTrial: Bool {
        selectedPlan == .yearly && purchaseService.yearlyProduct?.subscription?.introductoryOffer != nil
    }

    private var ctaTitle: String {
        hasFreeTrial ? String(localized: "paywall.start_trial") : String(localized: "paywall.subscribe")
    }

    private var savingsPercent: Int? {
        guard let monthly = purchaseService.monthlyProduct,
              let yearly = purchaseService.yearlyProduct else { return nil }
        let monthlyYear = monthly.price * 12
        guard monthlyYear > 0 else { return nil }
        let percent = Int((((monthlyYear - yearly.price) / monthlyYear) as NSDecimalNumber).doubleValue * 100)
        return percent > 0 ? percent : nil
    }

    private var yearlyBadge: String? {
        if purchaseService.yearlyProduct?.subscription?.introductoryOffer != nil {
            return String(localized: "paywall.free_trial_badge")
        }
        if let percent = savingsPercent {
            return String(localized: "paywall.save \(percent)")
        }
        return String(localized: "paywall.best_value")
    }

    // MARK: - View Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PaywallTheme.gradient.ignoresSafeArea()

            if purchaseService.isPremium {
                subscribedScroll
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header
                        benefitsList
                        plans
                        footnote
                        ctaButton
                        footer
                    }
                    .padding(.bottom, 28)
                }
            }

            closeButton
        }
        .onAppear {
            startAnimations()
            if !purchaseService.isPremium {
                AnalyticsService.paywallShown(source: source)
            }
            if purchaseService.products.isEmpty {
                Task { await purchaseService.loadProducts() }
            }
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button {
            HapticManager.selection()
            if !purchaseService.isPremium {
                AnalyticsService.paywallDismissed(source: source)
            }
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
                .frame(width: 44, height: 44)
        }
        .padding(.trailing, 8)
        .padding(.top, 4)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 96, height: 96)
                    .scaleEffect(iconPulse ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: iconPulse)
                Image(systemName: "crown.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(PaywallTheme.crownGradient)
            }
            .padding(.top, 64)

            Text(String(localized: "paywall.title"))
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(String(localized: "paywall.subtitle"))
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .opacity(showHeader ? 1 : 0)
        .offset(y: showHeader ? 0 : 20)
        .padding(.bottom, 22)
    }

    // MARK: - Benefits

    private var benefitsList: some View {
        VStack(spacing: 14) {
            ForEach(benefits, id: \.1) { item in
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.12)).frame(width: 44, height: 44)
                        Image(systemName: item.0)
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.primary)
                    }
                    Text(item.1)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 24)
        .opacity(showBenefits ? 1 : 0)
        .offset(y: showBenefits ? 0 : 20)
    }

    // MARK: - Plans

    @ViewBuilder
    private var plans: some View {
        VStack(spacing: 10) {
            PaywallPlanCard(
                title: String(localized: "paywall.yearly"),
                price: purchaseService.yearlyProduct?.displayPrice,
                period: String(localized: "paywall.per_year"),
                badge: yearlyBadge,
                isSelected: selectedPlan == .yearly,
                isLoading: purchaseService.yearlyProduct == nil
            ) { HapticManager.selection(); selectedPlan = .yearly }

            PaywallPlanCard(
                title: String(localized: "paywall.monthly"),
                price: purchaseService.monthlyProduct?.displayPrice,
                period: String(localized: "paywall.per_month"),
                badge: nil,
                isSelected: selectedPlan == .monthly,
                isLoading: purchaseService.monthlyProduct == nil
            ) { HapticManager.selection(); selectedPlan = .monthly }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .opacity(showPlans ? 1 : 0)
        .offset(y: showPlans ? 0 : 20)
    }

    @ViewBuilder
    private var footnote: some View {
        if let error = errorMessage {
            Text(error)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
        }
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Button(action: subscribe) {
            ZStack {
                if isPurchasing {
                    ProgressView().tint(.white)
                } else {
                    Text(ctaTitle)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(PaywallTheme.crownGradient)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 18, y: 6)
        }
        .pressAnimation()
        .disabled(isPurchasing || selectedProduct == nil)
        .opacity(selectedProduct == nil ? 0.6 : 1.0)
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
        .opacity(showButton ? 1 : 0)
        .offset(y: showButton ? 0 : 20)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 12) {
            Button { Task { await restore() } } label: {
                Text(String(localized: "paywall.restore"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            Text("·").foregroundStyle(.white.opacity(0.4))
            Link(String(localized: "paywall.privacy_link"),
                 destination: URL(string: AppConstants.privacyPolicyURL)!)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Text("·").foregroundStyle(.white.opacity(0.4))
            Link(String(localized: "paywall.terms_link"),
                 destination: URL(string: AppConstants.termsOfUseURL)!)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .opacity(showButton ? 1 : 0)
    }

    // MARK: - Subscribed State

    private var subscribedScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .frame(width: 96, height: 96)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(PaywallTheme.crownGradient)
                }
                .padding(.top, 96)

                Text(String(localized: "paywall.subscribed_title"))
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "paywall.subscribed_subtitle"))
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                VStack(spacing: 14) {
                    ForEach(benefits, id: \.1) { item in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.12)).frame(width: 44, height: 44)
                                Image(systemName: item.0)
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppColors.primary)
                            }
                            Text(item.1)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                            Spacer(minLength: 0)
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)

                Text(String(localized: "paywall.thanks"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Actions

    private func subscribe() {
        guard let product = selectedProduct else {
            errorMessage = String(localized: "paywall.error_title")
            return
        }
        errorMessage = nil
        isPurchasing = true
        let plan = selectedPlan == .yearly ? "yearly" : "monthly"
        AnalyticsService.purchaseStarted(product: plan, source: source)
        Task {
            do {
                let success = try await purchaseService.purchase(product)
                isPurchasing = false
                if success {
                    AnalyticsService.purchaseSuccess(product: plan, source: source)
                    HapticManager.success()
                    dismiss()
                } else {
                    AnalyticsService.purchaseFailed(product: plan, source: source, reason: "cancelled")
                }
            } catch {
                isPurchasing = false
                HapticManager.error()
                errorMessage = error.localizedDescription
                AnalyticsService.purchaseFailed(product: plan, source: source, reason: error.localizedDescription)
            }
        }
    }

    private func restore() async {
        isPurchasing = true
        await purchaseService.restorePurchases()
        isPurchasing = false
        AnalyticsService.restoreCompleted(success: purchaseService.isPremium)
        if purchaseService.isPremium {
            HapticManager.success()
            dismiss()
        } else {
            HapticManager.error()
            errorMessage = String(localized: "paywall.error_title")
        }
    }

    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.5)) { showHeader = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation(.easeOut(duration: 0.5)) { showBenefits = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { withAnimation(.easeOut(duration: 0.5)) { showPlans = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { withAnimation(.easeOut(duration: 0.5)) { showButton = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { iconPulse = true }
    }
}
