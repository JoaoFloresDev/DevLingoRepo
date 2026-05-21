import SwiftUI
import UIKit

/// App color palette — adapts between light and dark mode.
enum AppColors {
    // MARK: - Background
    static let background = Color.dynamic(light: "FFFFFF", dark: "000000")
    static let surface = Color.dynamic(light: "F2F2F7", dark: "1C1C1E")
    static let surfaceSecondary = Color.dynamic(light: "E5E5EA", dark: "2C2C2E")
    static let surfaceTertiary = Color.dynamic(light: "D1D1D6", dark: "3A3A3C")

    // MARK: - Primary Colors (kept constant; readable on both modes)
    static let primary = Color(hex: "5E5CE6")        // Indigo — learning
    static let secondary = Color(hex: "30D158")       // Green — progress
    static let accent = Color(hex: "FF9F0A")          // Orange — streak/fire

    // MARK: - Difficulty Colors
    static let easy = Color(hex: "30D158")            // Green
    static let medium = Color(hex: "FF9F0A")          // Orange
    static let hard = Color(hex: "FF453A")            // Red

    // MARK: - Category Colors
    static let categoryWwdc2026 = Color(hex: "0A84FF")    // Apple system blue — WWDC keynote
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
    static let categoryPolite = Color(hex: "AF52DE")

    // MARK: - Semantic Colors
    static let error = Color(hex: "FF453A")
    static let success = Color(hex: "30D158")
    static let warning = Color(hex: "FF9F0A")

    // MARK: - Text Colors (dynamic)
    static let textPrimary = Color.dynamic(light: "000000", dark: "FFFFFF")
    static let textSecondary = Color.dynamic(light: "636366", dark: "8E8E93")
    static let textTertiary = Color.dynamic(light: "AEAEB2", dark: "636366")

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

    /// Returns a color that adapts to light/dark interface style.
    static func dynamic(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hexString: dark)
                : UIColor(hexString: light)
        })
    }
}

// MARK: - UIColor Hex Extension (for dynamic providers)
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
