import SwiftUI

// MARK: - PaywallPlanCard

/// One selectable subscription option in the paywall (steps/PaywallKit model, purple theme):
/// translucent card over the brand gradient, radio indicator, price on the right,
/// optional badge (trial / savings).
struct PaywallPlanCard: View {
    // MARK: - Properties

    let title: String
    let price: String?
    let period: String
    let badge: String?
    let isSelected: Bool
    let isLoading: Bool
    let onTap: () -> Void

    // MARK: - View Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                radio

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    if let badge {
                        Text(badge.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppColors.primary))
                    }
                }

                Spacer(minLength: 0)

                priceColumn
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                    .fill(Color.white.opacity(isSelected ? 0.16 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                            .stroke(AppColors.primary, lineWidth: isSelected ? 2 : 0)
                    )
            )
        }
        .pressAnimation()
    }

    // MARK: - Subviews

    private var radio: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? AppColors.primary : Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 24, height: 24)
            if isSelected {
                Circle().fill(AppColors.primary).frame(width: 12, height: 12)
            }
        }
    }

    @ViewBuilder
    private var priceColumn: some View {
        if isLoading {
            ProgressView().tint(.white.opacity(0.8))
        } else {
            VStack(alignment: .trailing, spacing: 2) {
                Text(price ?? "—")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text(period)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}
