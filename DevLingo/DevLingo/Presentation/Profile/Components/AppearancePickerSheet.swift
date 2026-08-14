import SwiftUI

/// Sheet letting the user choose interface appearance.
struct AppearancePickerSheet: View {
    // MARK: - Properties

    @AppStorage(StorageKeys.preferredColorScheme) private var appearanceModeRaw: String = AppearanceMode.dark.rawValue
    @Environment(\.dismiss) private var dismiss

    // MARK: - View Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header

                VStack(spacing: 0) {
                    ForEach(Array(AppearanceMode.allCases.enumerated()), id: \.element.id) { index, mode in
                        appearanceRow(mode)

                        if index < AppearanceMode.allCases.count - 1 {
                            Divider()
                                .background(AppColors.surfaceSecondary)
                                .padding(.leading, AppSpacing.xl + AppSpacing.lg)
                        }
                    }
                }
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.lg)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text(String(localized: "profile.appearance"))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.textTertiary)
                    .frame(minWidth: 44, minHeight: 44)
            }
        }
    }

    private func appearanceRow(_ mode: AppearanceMode) -> some View {
        Button {
            appearanceModeRaw = mode.rawValue
            HapticManager.selection()
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: mode.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: AppSpacing.xl, alignment: .center)

                Text(mode.label)
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                if appearanceModeRaw == mode.rawValue {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
