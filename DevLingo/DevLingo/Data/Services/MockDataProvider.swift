import Foundation

/// Provides curated mock data for App Store screenshots.
enum MockDataProvider {
    // MARK: - Mock Phrases

    static let todayPhrases: [Phrase] = [
        Phrase(
            id: "mock_001",
            english: "I'll pick up the ticket after standup.",
            context: "Telling your team you'll start working on a task after the daily meeting",
            translations: mockTranslations("Vou pegar o ticket depois da daily."),
            difficulty: .easy,
            category: .standup
        ),
        Phrase(
            id: "mock_002",
            english: "Could you add some unit tests for this change?",
            context: "Requesting test coverage during a code review",
            translations: mockTranslations("Você poderia adicionar alguns testes unitários para essa mudança?"),
            difficulty: .medium,
            category: .codeReview
        ),
        Phrase(
            id: "mock_003",
            english: "Let me share my screen so we can debug this together.",
            context: "Offering to collaborate visually during a pair programming session",
            translations: mockTranslations("Deixa eu compartilhar minha tela para debugarmos juntos."),
            difficulty: .easy,
            category: .pairProgramming
        ),
        Phrase(
            id: "mock_004",
            english: "The build is failing on CI — looks like a flaky test.",
            context: "Reporting a continuous integration issue to the team",
            translations: mockTranslations("O build está falhando no CI — parece ser um teste instável."),
            difficulty: .medium,
            category: .bugReports
        ),
        Phrase(
            id: "mock_005",
            english: "I'm blocked on the API integration — waiting for the endpoint.",
            context: "Communicating a blocker during standup",
            translations: mockTranslations("Estou bloqueado na integração da API — esperando o endpoint."),
            difficulty: .easy,
            category: .standup
        ),
        Phrase(
            id: "mock_006",
            english: "Let's circle back on the architecture decision after the spike.",
            context: "Suggesting to revisit a technical discussion once research is complete",
            translations: mockTranslations("Vamos voltar à decisão de arquitetura depois do spike."),
            difficulty: .hard,
            category: .technical
        ),
        Phrase(
            id: "mock_007",
            english: "LGTM! Just one minor nit on the naming convention.",
            context: "Approving a pull request with a small suggestion",
            translations: mockTranslations("LGTM! Só uma observação menor sobre a convenção de nomes."),
            difficulty: .medium,
            category: .pullRequests
        ),
        Phrase(
            id: "mock_008",
            english: "I'll follow up with an email summarizing the action items.",
            context: "Wrapping up a meeting and committing to send a summary",
            translations: mockTranslations("Vou enviar um email resumindo os itens de ação."),
            difficulty: .easy,
            category: .meetings
        ),
        Phrase(
            id: "mock_009",
            english: "Can you walk me through your thought process on this approach?",
            context: "Asking a candidate to explain their reasoning during a technical interview",
            translations: mockTranslations("Você pode me explicar seu raciocínio nessa abordagem?"),
            difficulty: .hard,
            category: .interviews
        ),
        Phrase(
            id: "mock_010",
            english: "Happy Friday! Any plans for the weekend?",
            context: "Making casual small talk with teammates at the end of the week",
            translations: mockTranslations("Feliz sexta! Algum plano pro fim de semana?"),
            difficulty: .easy,
            category: .casual
        )
    ]

    // MARK: - Mock Progress

    static let mockProgress = UserProgress(
        totalPhrasesLearned: 127,
        currentStreak: 14,
        longestStreak: 21,
        lastActiveDate: Date(),
        phrasesByCategory: [
            "standup": 22,
            "codeReview": 18,
            "slack": 15,
            "email": 12,
            "meetings": 14,
            "technical": 10,
            "pullRequests": 11,
            "bugReports": 8,
            "pairProgramming": 6,
            "interviews": 5,
            "casual": 4,
            "documentation": 2
        ],
        phrasesByDifficulty: [
            "easy": 55,
            "medium": 48,
            "hard": 24
        ]
    )

    // MARK: - Helpers

    private static func mockTranslations(_ ptBR: String) -> [String: String] {
        ["pt-BR": ptBR]
    }
}
