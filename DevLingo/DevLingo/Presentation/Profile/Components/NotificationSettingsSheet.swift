import SwiftUI

/// Sheet for configuring notification preferences.
struct NotificationSettingsSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled: Bool
    @State private var phrasesPerDay: Int
    @State private var permissionDenied = false

    private let storage = StorageService.shared
    private let notificationService = NotificationService.shared

    // MARK: - Init

    init() {
        let storage = StorageService.shared
        _notificationsEnabled = State(initialValue: storage.getBool(forKey: StorageKeys.notificationsEnabled))
        _phrasesPerDay = State(initialValue: max(1, storage.getInt(forKey: StorageKeys.phraseNotificationsCount)))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: AppSpacing.lg) {
                    // Enable notifications toggle
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(AppColors.primary)
                            .font(.system(size: 18))

                        Text(String(localized: "profile.notifications"))
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        Toggle("", isOn: $notificationsEnabled)
                            .tint(AppColors.primary)
                            .labelsHidden()
                            .onChange(of: notificationsEnabled) { _, newValue in
                                handleToggle(newValue)
                            }
                    }
                    .padding(AppSpacing.lg)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))

                    if notificationsEnabled {
                        // Phrases per day
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text(String(localized: "profile.phrase_notifications"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(AppColors.textPrimary)

                            Text(String(localized: "profile.notifications_per_day"))
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.textTertiary)

                            HStack(spacing: AppSpacing.md) {
                                ForEach(1...4, id: \.self) { count in
                                    Button {
                                        phrasesPerDay = count
                                        storage.setInt(count, forKey: StorageKeys.phraseNotificationsCount)
                                        HapticManager.selection()
                                    } label: {
                                        Text("\(count)")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(phrasesPerDay == count ? .white : AppColors.primary)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                phrasesPerDay == count
                                                    ? AppColors.primary
                                                    : AppColors.primary.opacity(0.15)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
                                    }
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if permissionDenied {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppColors.warning)

                            Text(String(localized: "profile.notifications_denied"))
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.warning.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
                    }

                    Spacer()
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
            }
            .navigationTitle(String(localized: "profile.notifications"))
            .navigationBarTitleDisplayMode(.inline)
            .animation(.spring(response: 0.3), value: notificationsEnabled)
        }
    }

    // MARK: - Actions

    private func handleToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let granted = await notificationService.requestPermission()
                if granted {
                    storage.setBool(true, forKey: StorageKeys.notificationsEnabled)
                    HapticManager.success()
                } else {
                    notificationsEnabled = false
                    permissionDenied = true
                    storage.setBool(false, forKey: StorageKeys.notificationsEnabled)
                    HapticManager.error()
                }
            }
        } else {
            storage.setBool(false, forKey: StorageKeys.notificationsEnabled)
            notificationService.cancelAll()
            HapticManager.selection()
        }
    }
}
