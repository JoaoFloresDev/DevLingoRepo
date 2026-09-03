import SwiftUI

/// Sheet for configuring notification preferences.
struct NotificationSettingsSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled: Bool
    @State private var phrasesPerDay: Int
    @State private var permissionDenied = false

    @State private var streakReminderEnabled: Bool
    @State private var streakReminderTime: Date
    @State private var isStreakRequestInFlight = false
    @State private var showStreakPrimer = false
    @State private var suppressStreakToggle = false

    private let storage = StorageService.shared
    private let notificationService = NotificationService.shared
    private let streakReminder = StreakReminderService.shared

    // MARK: - Init

    init() {
        let storage = StorageService.shared
        _notificationsEnabled = State(initialValue: storage.getBool(forKey: StorageKeys.notificationsEnabled))
        _phrasesPerDay = State(initialValue: max(1, storage.getInt(forKey: StorageKeys.phraseNotificationsCount)))
        _streakReminderEnabled = State(initialValue: StreakReminderService.shared.isEnabled)
        _streakReminderTime = State(initialValue: StreakReminderService.shared.reminderTimeAsDate)
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

                    streakReminderSection

                    if permissionDenied {
                        VStack(spacing: AppSpacing.md) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(AppColors.warning)

                                Text(String(localized: "profile.notifications_denied"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text(String(localized: "reminder.denied.settings"))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(AppColors.primary)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .contentShape(Rectangle())
                            }
                            .accessibilityIdentifier("reminder.open.settings")
                            .accessibilityLabel(String(localized: "reminder.denied.settings"))
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
            .animation(.spring(response: 0.3), value: streakReminderEnabled)
            .sheet(isPresented: $showStreakPrimer) {
                StreakReminderPrimerSheet(source: "settings") { granted in
                    setStreakToggle(granted)
                    if !granted {
                        permissionDenied = true
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Streak Reminder Section

    private var streakReminderSection: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(AppColors.accent)
                    .font(.system(size: 18))

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "profile.streak_reminder"))
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(String(localized: "profile.streak_reminder.subtitle"))
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Spacer()

                if isStreakRequestInFlight {
                    ProgressView()
                } else {
                    Toggle("", isOn: $streakReminderEnabled)
                        .tint(AppColors.primary)
                        .labelsHidden()
                        .onChange(of: streakReminderEnabled) { oldValue, newValue in
                            guard oldValue != newValue else { return }
                            if suppressStreakToggle {
                                suppressStreakToggle = false
                                return
                            }
                            handleStreakToggle(newValue)
                        }
                        .accessibilityIdentifier("reminder.toggle")
                        .accessibilityLabel(String(localized: "profile.streak_reminder"))
                }
            }

            if streakReminderEnabled {
                HStack {
                    Text(String(localized: "profile.streak_reminder.time"))
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    DatePicker(
                        String(localized: "profile.streak_reminder.time"),
                        selection: $streakReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .onChange(of: streakReminderTime) { _, newValue in
                        streakReminder.setTime(from: newValue)
                        HapticManager.selection()
                    }
                    .accessibilityIdentifier("reminder.time")
                    .accessibilityLabel(String(localized: "profile.streak_reminder.time"))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
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
            notificationService.cancelPhraseNotifications()
            HapticManager.selection()
        }
    }

    private func handleStreakToggle(_ enabled: Bool) {
        guard enabled else {
            streakReminder.disable()
            AnalyticsService.feature("reminder_disabled", source: "settings")
            HapticManager.selection()
            return
        }

        isStreakRequestInFlight = true
        Task {
            let status = await notificationService.authorizationStatus()
            isStreakRequestInFlight = false

            switch status {
            case .denied:
                setStreakToggle(false)
                permissionDenied = true
                HapticManager.error()
            case .authorized, .provisional, .ephemeral:
                streakReminder.enable()
                AnalyticsService.feature("reminder_enabled", source: "settings")
                HapticManager.success()
            default:
                // Primer first (5.1.1(iv)); the sheet enables on grant.
                setStreakToggle(false)
                showStreakPrimer = true
            }
        }
    }

    /// Programmatic toggle writes must not re-enter `handleStreakToggle`.
    private func setStreakToggle(_ value: Bool) {
        guard streakReminderEnabled != value else { return }
        suppressStreakToggle = true
        streakReminderEnabled = value
    }
}
