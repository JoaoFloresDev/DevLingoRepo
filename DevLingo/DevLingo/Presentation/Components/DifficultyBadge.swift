import SwiftUI

/// Small badge showing phrase difficulty level.
struct DifficultyBadge: View {
    let difficulty: PhraseDifficulty

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: difficulty.icon)
                .font(.system(size: 9))
            Text(difficulty.label)
                .font(AppFonts.badge)
        }
        .foregroundStyle(difficulty.color)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xxs)
        .background(difficulty.color.opacity(0.15))
        .clipShape(Capsule())
    }
}
