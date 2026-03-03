import SwiftUI

/// Sheet for selecting the user's native language.
struct LanguagePickerSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: UserLanguage

    private let storage = StorageService.shared

    // MARK: - Init

    init() {
        let code = StorageService.shared.getString(forKey: StorageKeys.selectedLanguage) ?? "pt-BR"
        _selectedLanguage = State(initialValue: UserLanguage(rawValue: code) ?? .ptBR)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(UserLanguage.allCases) { language in
                            Button {
                                selectedLanguage = language
                                storage.setString(language.rawValue, forKey: StorageKeys.selectedLanguage)
                                HapticManager.selection()
                                dismiss()
                            } label: {
                                HStack(spacing: AppSpacing.md) {
                                    Text(language.flag)
                                        .font(.system(size: 28))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(language.nativeName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(AppColors.textPrimary)

                                        Text(language.englishName)
                                            .font(.system(size: 13))
                                            .foregroundStyle(AppColors.textTertiary)
                                    }

                                    Spacer()

                                    if selectedLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(AppColors.primary)
                                            .font(.system(size: 22))
                                    }
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.md)
                                .background(
                                    selectedLanguage == language
                                        ? AppColors.primary.opacity(0.1)
                                        : AppColors.surface
                                )
                                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationTitle(String(localized: "profile.language"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
