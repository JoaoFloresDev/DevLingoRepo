import SwiftUI

/// Typography system using SF Pro (system default).
enum AppFonts {
    // MARK: - Titles
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Body
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Phrase Display
    static let phraseEnglish = Font.system(size: 20, weight: .semibold, design: .default)
    static let phraseTranslation = Font.system(size: 16, weight: .regular, design: .default)
    static let phraseContext = Font.system(size: 14, weight: .medium, design: .default)

    // MARK: - Special
    static let streakNumber = Font.system(size: 48, weight: .bold, design: .rounded)
    static let statNumber = Font.system(size: 24, weight: .bold, design: .rounded)
    static let badge = Font.system(size: 11, weight: .bold, design: .rounded)
}
