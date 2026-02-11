import SwiftUI

/// Phrase difficulty levels.
enum PhraseDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard

    // MARK: - Display

    var label: String {
        switch self {
        case .easy: return String(localized: "difficulty.easy")
        case .medium: return String(localized: "difficulty.medium")
        case .hard: return String(localized: "difficulty.hard")
        }
    }

    var color: Color {
        switch self {
        case .easy: return AppColors.easy
        case .medium: return AppColors.medium
        case .hard: return AppColors.hard
        }
    }

    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }

    var sortOrder: Int {
        switch self {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }
}
