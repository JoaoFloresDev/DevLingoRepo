import SwiftUI

/// Pre-permission primer for the streak reminder (guideline 5.1.1(iv)):
/// explains WHY before the system prompt and offers exactly ONE neutral button
/// that always leads to the system dialog — no "not now" alternative.
struct StreakReminderPrimerSheet: View {
    // MARK: - Properties

    /// Where the flow started (home_card / settings) — used for analytics.
    let source: String
    /// Called with the permission outcome after the system prompt resolves.
    let onFinished: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isRequesting = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.15))
                        .frame(width: 96, height: 96)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppColors.accent)
                }

                Text(String(localized: "reminder.primer.title"))
                    .font(AppFonts.title2)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(String(localized: "reminder.primer.body"))
                    .font(AppFonts.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, AppSpacing.md)

                Spacer()

                Button {
                    requestPermission()
                } label: {
                    Group {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(String(localized: "reminder.primer.continue"))
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
                }
                .disabled(isRequesting)
                .accessibilityIdentifier("reminder.primer.continue")
                .accessibilityLabel(String(localized: "reminder.primer.continue"))
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xl)
        }
        .interactiveDismissDisabled(isRequesting)
    }

    // MARK: - Actions

    private func requestPermission() {
        guard !isRequesting else { return }
        isRequesting = true
        HapticManager.lightImpact()

        Task {
            let granted = await NotificationService.shared.requestPermission()
            AnalyticsService.permissionResult(kind: "notifications", granted: granted)

            if granted {
                StreakReminderService.shared.enable()
                AnalyticsService.feature("reminder_enabled", source: source)
                HapticManager.success()
            } else {
                HapticManager.error()
            }

            isRequesting = false
            dismiss()
            onFinished(granted)
        }
    }
}
