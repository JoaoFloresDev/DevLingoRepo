import SwiftUI

// MARK: - Mock Phrase

struct MockPhrase: Identifiable, Hashable {
    let id = UUID()
    let english: String
    let translation: String
    let context: String
    let category: MockCategory
    let difficulty: MockDifficulty
    let completed: Bool
}

enum MockDifficulty {
    case easy, medium, hard

    var color: Color {
        switch self {
        case .easy:   return MockTheme.easy
        case .medium: return MockTheme.medium
        case .hard:   return MockTheme.hard
        }
    }

    func label(locale: String) -> String {
        switch (self, locale) {
        case (.easy,   "pt-BR"): return "FÁCIL"
        case (.easy,   "es-ES"), (.easy,   "es-MX"): return "FÁCIL"
        case (.easy,   _):       return "EASY"
        case (.medium, "pt-BR"): return "MÉDIO"
        case (.medium, "es-ES"), (.medium, "es-MX"): return "MEDIO"
        case (.medium, _):       return "MEDIUM"
        case (.hard,   "pt-BR"): return "DIFÍCIL"
        case (.hard,   "es-ES"), (.hard,   "es-MX"): return "DIFÍCIL"
        case (.hard,   _):       return "HARD"
        }
    }
}

// MARK: - Mock Category

struct MockCategory: Hashable {
    let icon: String
    let color: Color
    let labels: [String: String]
    let isPremium: Bool

    func label(locale: String) -> String {
        labels[locale] ?? labels["en-US"] ?? ""
    }

    static let standup = MockCategory(
        icon: "person.3.fill",
        color: MockTheme.categoryStandup,
        labels: ["en-US": "Daily Standup", "pt-BR": "Daily", "es-ES": "Daily", "es-MX": "Daily"],
        isPremium: false
    )
    static let codeReview = MockCategory(
        icon: "chevron.left.forwardslash.chevron.right",
        color: MockTheme.categoryCodeReview,
        labels: ["en-US": "Code Review", "pt-BR": "Code Review", "es-ES": "Code Review", "es-MX": "Code Review"],
        isPremium: false
    )
    static let slack = MockCategory(
        icon: "bubble.left.and.bubble.right.fill",
        color: MockTheme.categorySlack,
        labels: ["en-US": "Slack", "pt-BR": "Slack", "es-ES": "Slack", "es-MX": "Slack"],
        isPremium: false
    )
    static let meetings = MockCategory(
        icon: "video.fill",
        color: MockTheme.categoryMeetings,
        labels: ["en-US": "Meetings", "pt-BR": "Reuniões", "es-ES": "Reuniones", "es-MX": "Reuniones"],
        isPremium: false
    )
    static let pullRequests = MockCategory(
        icon: "arrow.triangle.pull",
        color: MockTheme.categoryPullRequests,
        labels: ["en-US": "Pull Requests", "pt-BR": "Pull Requests", "es-ES": "Pull Requests", "es-MX": "Pull Requests"],
        isPremium: false
    )
    static let email = MockCategory(
        icon: "envelope.fill",
        color: MockTheme.categoryEmail,
        labels: ["en-US": "Email", "pt-BR": "Email", "es-ES": "Email", "es-MX": "Email"],
        isPremium: false
    )
    static let technical = MockCategory(
        icon: "gearshape.fill",
        color: MockTheme.categoryTechnical,
        labels: ["en-US": "Technical", "pt-BR": "Técnico", "es-ES": "Técnico", "es-MX": "Técnico"],
        isPremium: false
    )
    static let bugReports = MockCategory(
        icon: "ant.fill",
        color: MockTheme.categoryBugReports,
        labels: ["en-US": "Bug Reports", "pt-BR": "Bug Reports", "es-ES": "Bug Reports", "es-MX": "Bug Reports"],
        isPremium: false
    )
    static let casual = MockCategory(
        icon: "cup.and.saucer.fill",
        color: MockTheme.categoryCasual,
        labels: ["en-US": "Casual", "pt-BR": "Casual", "es-ES": "Casual", "es-MX": "Casual"],
        isPremium: false
    )
    static let pairProgramming = MockCategory(
        icon: "person.2.fill",
        color: MockTheme.categoryPairProgramming,
        labels: ["en-US": "Pair Programming", "pt-BR": "Pair Programming", "es-ES": "Pair Programming", "es-MX": "Pair Programming"],
        isPremium: true
    )
    static let interviews = MockCategory(
        icon: "questionmark.bubble.fill",
        color: MockTheme.categoryInterviews,
        labels: ["en-US": "Interviews", "pt-BR": "Entrevistas", "es-ES": "Entrevistas", "es-MX": "Entrevistas"],
        isPremium: true
    )
    static let documentation = MockCategory(
        icon: "doc.text.fill",
        color: MockTheme.categoryDocumentation,
        labels: ["en-US": "Documentation", "pt-BR": "Documentação", "es-ES": "Documentación", "es-MX": "Documentación"],
        isPremium: true
    )
    static let polite = MockCategory(
        icon: "hand.wave.fill",
        color: MockTheme.categoryPolite,
        labels: ["en-US": "Polite English", "pt-BR": "Inglês Cortês", "es-ES": "Inglés Cortés", "es-MX": "Inglés Cortés"],
        isPremium: true
    )

    static let all: [MockCategory] = [
        .standup, .codeReview, .slack, .meetings, .pullRequests, .email,
        .technical, .bugReports, .casual,
        .pairProgramming, .interviews, .documentation, .polite
    ]
}

// MARK: - Curated Phrases (per locale)

enum MockPhrasesFactory {
    static func todayPhrases(locale: String) -> [MockPhrase] {
        let isPT = locale == "pt-BR"
        let isES = locale.hasPrefix("es")
        return [
            MockPhrase(
                english: "Let's sync up after standup.",
                translation: isPT ? "Vamos alinhar depois da daily."
                            : isES ? "Sincronicémonos después del daily."
                            : "Let's sync up after standup.",
                context: isPT ? "Após daily, propondo conversa rápida"
                        : isES ? "Después del daily, proponiendo charla rápida"
                        : "Proposing a quick chat after daily",
                category: .standup,
                difficulty: .easy,
                completed: true
            ),
            MockPhrase(
                english: "Could you take another look at my PR?",
                translation: isPT ? "Você poderia dar mais uma olhada no meu PR?"
                            : isES ? "¿Podrías echar otro vistazo a mi PR?"
                            : "Could you take another look at my PR?",
                context: isPT ? "Pedindo nova revisão de código"
                        : isES ? "Pidiendo nueva revisión de código"
                        : "Asking for another code review pass",
                category: .codeReview,
                difficulty: .medium,
                completed: true
            ),
            MockPhrase(
                english: "I'll ping you on Slack with the details.",
                translation: isPT ? "Te chamo no Slack com os detalhes."
                            : isES ? "Te aviso por Slack con los detalles."
                            : "I'll ping you on Slack with the details.",
                context: isPT ? "Combinando follow-up assíncrono"
                        : isES ? "Acordando seguimiento asíncrono"
                        : "Setting up an async follow-up",
                category: .slack,
                difficulty: .easy,
                completed: false
            ),
            MockPhrase(
                english: "Let me get back to you on that.",
                translation: isPT ? "Deixa eu te dar um retorno sobre isso."
                            : isES ? "Déjame responderte sobre eso."
                            : "Let me get back to you on that.",
                context: isPT ? "Quando precisa pensar antes de responder"
                        : isES ? "Cuando necesitas pensar antes de responder"
                        : "When you need time to think first",
                category: .meetings,
                difficulty: .medium,
                completed: false
            ),
            MockPhrase(
                english: "I just pushed a fix — could you give it a try?",
                translation: isPT ? "Acabei de subir um fix — pode testar?"
                            : isES ? "Acabo de subir un fix — ¿puedes probarlo?"
                            : "I just pushed a fix — could you give it a try?",
                context: isPT ? "Avisando que correção está pronta"
                        : isES ? "Avisando que la corrección está lista"
                        : "Telling someone a fix is deployed",
                category: .pullRequests,
                difficulty: .medium,
                completed: false
            )
        ]
    }

    static func detailPhrase(locale: String) -> MockPhrase {
        let isPT = locale == "pt-BR"
        let isES = locale.hasPrefix("es")
        return MockPhrase(
            english: "Could you take another look at my PR?",
            translation: isPT ? "Você poderia dar mais uma olhada no meu PR?"
                        : isES ? "¿Podrías echar otro vistazo a mi PR?"
                        : "Could you take another look at my PR?",
            context: isPT ? "Quando precisa de uma nova revisão de código após mudanças"
                    : isES ? "Cuando necesitas otra revisión de código tras cambios"
                    : "When you need another code review after changes",
            category: .codeReview,
            difficulty: .medium,
            completed: false
        )
    }
}

// MARK: - Localized Labels

enum LocalizedLabels {
    // Home
    static let greeting: [String: String] = [
        "en-US": "Good morning",
        "pt-BR": "Bom dia",
        "es-ES": "Buenos días",
        "es-MX": "Buenos días"
    ]
    static let homeTitle: [String: String] = [
        "en-US": "Today's phrases",
        "pt-BR": "Frases de hoje",
        "es-ES": "Frases de hoy",
        "es-MX": "Frases de hoy"
    ]
    static let streakDays: [String: String] = [
        "en-US": "day streak",
        "pt-BR": "dias seguidos",
        "es-ES": "días seguidos",
        "es-MX": "días seguidos"
    ]
    static let todayProgress: [String: String] = [
        "en-US": "today",
        "pt-BR": "hoje",
        "es-ES": "hoy",
        "es-MX": "hoy"
    ]
    static let levelTitle: [String: String] = [
        "en-US": "Senior Dev",
        "pt-BR": "Dev Sênior",
        "es-ES": "Dev Sénior",
        "es-MX": "Dev Sénior"
    ]
    static let learned: [String: String] = [
        "en-US": "Mark as learned",
        "pt-BR": "Marcar como aprendi",
        "es-ES": "Marcar como aprendí",
        "es-MX": "Marcar como aprendí"
    ]
    static let learnedDone: [String: String] = [
        "en-US": "Learned",
        "pt-BR": "Aprendi",
        "es-ES": "Aprendí",
        "es-MX": "Aprendí"
    ]
    static let listen: [String: String] = [
        "en-US": "Listen",
        "pt-BR": "Ouvir",
        "es-ES": "Escuchar",
        "es-MX": "Escuchar"
    ]
    static let translation: [String: String] = [
        "en-US": "Show translation",
        "pt-BR": "Ver tradução",
        "es-ES": "Ver traducción",
        "es-MX": "Ver traducción"
    ]
    static let context: [String: String] = [
        "en-US": "Context",
        "pt-BR": "Contexto",
        "es-ES": "Contexto",
        "es-MX": "Contexto"
    ]

    // Categories
    static let categoriesTitle: [String: String] = [
        "en-US": "Categories",
        "pt-BR": "Categorias",
        "es-ES": "Categorías",
        "es-MX": "Categorías"
    ]
    static let categoriesSubtitle: [String: String] = [
        "en-US": "Real situations devs face every day",
        "pt-BR": "Situações reais do dia a dia dev",
        "es-ES": "Situaciones reales del día a día dev",
        "es-MX": "Situaciones reales del día a día dev"
    ]
    static let phrasesCountSuffix: [String: String] = [
        "en-US": "phrases",
        "pt-BR": "frases",
        "es-ES": "frases",
        "es-MX": "frases"
    ]
    static let proLabel: [String: String] = [
        "en-US": "PRO",
        "pt-BR": "PRO",
        "es-ES": "PRO",
        "es-MX": "PRO"
    ]

    // Progress
    static let progressTitle: [String: String] = [
        "en-US": "Your progress",
        "pt-BR": "Seu progresso",
        "es-ES": "Tu progreso",
        "es-MX": "Tu progreso"
    ]
    static let learnedTotal: [String: String] = [
        "en-US": "phrases learned",
        "pt-BR": "frases aprendidas",
        "es-ES": "frases aprendidas",
        "es-MX": "frases aprendidas"
    ]
    static let dayStreakLabel: [String: String] = [
        "en-US": "Day streak",
        "pt-BR": "Sequência",
        "es-ES": "Racha",
        "es-MX": "Racha"
    ]
    static let saved: [String: String] = [
        "en-US": "Saved",
        "pt-BR": "Salvas",
        "es-ES": "Guardadas",
        "es-MX": "Guardadas"
    ]

    // Widget mock
    static let widgetTitle: [String: String] = [
        "en-US": "Phrase of the day",
        "pt-BR": "Frase do dia",
        "es-ES": "Frase del día",
        "es-MX": "Frase del día"
    ]
}

// MARK: - App Store Listing Mockup Strings

enum LocalizedListing {
    static let appName: [String: String] = [
        "en-US": "Devlingo: English for Devs",
        "pt-BR": "Devlingo: Inglês para Devs",
        "es-ES": "Devlingo: Inglés para Devs",
        "es-MX": "Devlingo: Inglés para Devs"
    ]
    static let subtitle: [String: String] = [
        "en-US": "Real phrases for daily, slack, code review",
        "pt-BR": "Frases reais para daily, slack, code review",
        "es-ES": "Frases reales para daily, slack, code review",
        "es-MX": "Frases reales para daily, slack, code review"
    ]
}
