import SwiftUI

/// App color palette — dark theme, dev/education focused.
enum AppColors {
    // MARK: - Background
    static let background = Color(hex: "000000")
    static let surface = Color(hex: "1C1C1E")
    static let surfaceSecondary = Color(hex: "2C2C2E")
    static let surfaceTertiary = Color(hex: "3A3A3C")

    // MARK: - Primary Colors
    static let primary = Color(hex: "5E5CE6")        // Indigo — learning
    static let secondary = Color(hex: "30D158")       // Green — progress
    static let accent = Color(hex: "FF9F0A")          // Orange — streak/fire

    // MARK: - Difficulty Colors
    static let easy = Color(hex: "30D158")            // Green
    static let medium = Color(hex: "FF9F0A")          // Orange
    static let hard = Color(hex: "FF453A")            // Red

    // MARK: - Category Colors
    static let categoryStandup = Color(hex: "5E5CE6")
    static let categoryCodeReview = Color(hex: "BF5AF2")
    static let categorySlack = Color(hex: "5AC8FA")
    static let categoryEmail = Color(hex: "64D2FF")
    static let categoryMeetings = Color(hex: "30D158")
    static let categoryTechnical = Color(hex: "FF6B35")
    static let categoryPullRequests = Color(hex: "FF375F")
    static let categoryBugReports = Color(hex: "FF453A")
    static let categoryPairProgramming = Color(hex: "AC8E68")
    static let categoryInterviews = Color(hex: "FFD60A")
    static let categoryCasual = Color(hex: "FF9F0A")
    static let categoryDocumentation = Color(hex: "8E8E93")

    // MARK: - Semantic Colors
    static let error = Color(hex: "FF453A")
    static let success = Color(hex: "30D158")
    static let warning = Color(hex: "FF9F0A")

    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8E8E93")
    static let textTertiary = Color(hex: "636366")

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, Color(hex: "BF5AF2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let streakGradient = LinearGradient(
        colors: [accent, Color(hex: "FF6B35")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
