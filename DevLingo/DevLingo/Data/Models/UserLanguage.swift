import Foundation

/// Supported user languages (all learning English).
enum UserLanguage: String, Codable, CaseIterable, Identifiable {
    case ptBR = "pt-BR"
    case es = "es"
    case fr = "fr"
    case de = "de"
    case it = "it"
    case ja = "ja"
    case ko = "ko"
    case zhHans = "zh-Hans"
    case hi = "hi"
    case tr = "tr"

    var id: String { rawValue }

    /// BCP 47 language code for translations.
    var code: String { rawValue }

    /// Display name in the language itself.
    var nativeName: String {
        switch self {
        case .ptBR: return "Português (Brasil)"
        case .es: return "Español"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .it: return "Italiano"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .zhHans: return "简体中文"
        case .hi: return "हिन्दी"
        case .tr: return "Türkçe"
        }
    }

    /// Flag emoji.
    var flag: String {
        switch self {
        case .ptBR: return "🇧🇷"
        case .es: return "🇪🇸"
        case .fr: return "🇫🇷"
        case .de: return "🇩🇪"
        case .it: return "🇮🇹"
        case .ja: return "🇯🇵"
        case .ko: return "🇰🇷"
        case .zhHans: return "🇨🇳"
        case .hi: return "🇮🇳"
        case .tr: return "🇹🇷"
        }
    }

    /// English name for display.
    var englishName: String {
        switch self {
        case .ptBR: return "Portuguese (Brazil)"
        case .es: return "Spanish"
        case .fr: return "French"
        case .de: return "German"
        case .it: return "Italian"
        case .ja: return "Japanese"
        case .ko: return "Korean"
        case .zhHans: return "Chinese (Simplified)"
        case .hi: return "Hindi"
        case .tr: return "Turkish"
        }
    }
}
