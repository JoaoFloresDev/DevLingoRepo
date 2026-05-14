import Foundation

// MARK: - Headline Copy
//
// 60 headlines (3 treatments × 5 slots × 4 locales — es-ES content
// is duplicated to es-MX). Every headline is anchored to at least one
// keyword from DevLingo's live keywords.txt.

struct Headline {
    let text: String
    let highlight: String?
}

typealias LocalizedHeadlines = [String: Headline]

struct TreatmentCopy {
    let id: String
    let label: String
    let home: LocalizedHeadlines
    let feature1: LocalizedHeadlines
    let feature2: LocalizedHeadlines
    let settings: LocalizedHeadlines
    let onboarding: LocalizedHeadlines
}

enum Headlines {

    // MARK: - Treatment A — Direct / Action (verb + outcome, keyword-led)

    static let treatmentA = TreatmentCopy(
        id: "A",
        label: "Direct / Action",
        home: [
            "en-US": Headline(text: "Real English phrases devs use daily",        highlight: "phrases"),
            "pt-BR": Headline(text: "Frases reais do dia a dia dev",              highlight: "Frases"),
            "es-ES": Headline(text: "Frases reales del día a día dev",            highlight: "Frases"),
            "es-MX": Headline(text: "Frases reales del día a día dev",            highlight: "Frases")
        ],
        feature1: [
            "en-US": Headline(text: "Master daily, code review, slack",           highlight: "daily"),
            "pt-BR": Headline(text: "Domine daily, code review, slack",           highlight: "daily"),
            "es-ES": Headline(text: "Domina daily, code review, slack",           highlight: "daily"),
            "es-MX": Headline(text: "Domina daily, code review, slack",           highlight: "daily")
        ],
        feature2: [
            "en-US": Headline(text: "Learn the phrase, sound natural",            highlight: "phrase"),
            "pt-BR": Headline(text: "Aprenda a frase e soe natural",              highlight: "frase"),
            "es-ES": Headline(text: "Aprende la frase y suena natural",           highlight: "frase"),
            "es-MX": Headline(text: "Aprende la frase y suena natural",           highlight: "frase")
        ],
        settings: [
            "en-US": Headline(text: "Track your English progress",                highlight: "English"),
            "pt-BR": Headline(text: "Acompanhe seu inglês de perto",              highlight: "inglês"),
            "es-ES": Headline(text: "Sigue tu progreso en inglés",                highlight: "inglés"),
            "es-MX": Headline(text: "Sigue tu progreso en inglés",                highlight: "inglés")
        ],
        onboarding: [
            "en-US": Headline(text: "Phrase of the day on your home screen",      highlight: "Phrase"),
            "pt-BR": Headline(text: "Frase do dia direto na tela inicial",        highlight: "Frase"),
            "es-ES": Headline(text: "Frase del día en tu pantalla de inicio",     highlight: "Frase"),
            "es-MX": Headline(text: "Frase del día en tu pantalla de inicio",     highlight: "Frase")
        ]
    )

    // MARK: - Treatment B — Emotional / Aspirational (feeling + identity)

    static let treatmentB = TreatmentCopy(
        id: "B",
        label: "Emotional / Aspirational",
        home: [
            "en-US": Headline(text: "Stop freezing in standup",                   highlight: "standup"),
            "pt-BR": Headline(text: "Pare de travar na daily",                    highlight: "daily"),
            "es-ES": Headline(text: "Deja de bloquearte en el daily",             highlight: "daily"),
            "es-MX": Headline(text: "Deja de bloquearte en el daily",             highlight: "daily")
        ],
        feature1: [
            "en-US": Headline(text: "Confident in every meeting",                 highlight: "Confident"),
            "pt-BR": Headline(text: "Segurança em qualquer reunião",              highlight: "Segurança"),
            "es-ES": Headline(text: "Seguro en cada reunión",                     highlight: "Seguro"),
            "es-MX": Headline(text: "Seguro en cada reunión",                     highlight: "Seguro")
        ],
        feature2: [
            "en-US": Headline(text: "Say it right, the first time",               highlight: "right"),
            "pt-BR": Headline(text: "Diga certo, na primeira vez",                highlight: "certo"),
            "es-ES": Headline(text: "Dilo bien, a la primera",                    highlight: "bien"),
            "es-MX": Headline(text: "Dilo bien, a la primera",                    highlight: "bien")
        ],
        settings: [
            "en-US": Headline(text: "From silent to fluent, day by day",          highlight: "fluent"),
            "pt-BR": Headline(text: "De calado a fluente, dia após dia",          highlight: "fluente"),
            "es-ES": Headline(text: "De callado a fluido, día tras día",          highlight: "fluido"),
            "es-MX": Headline(text: "De callado a fluido, día tras día",          highlight: "fluido")
        ],
        onboarding: [
            "en-US": Headline(text: "Learn English without lifting a finger",     highlight: "English"),
            "pt-BR": Headline(text: "Aprenda inglês sem nem perceber",            highlight: "inglês"),
            "es-ES": Headline(text: "Aprende inglés sin darte cuenta",            highlight: "inglés"),
            "es-MX": Headline(text: "Aprende inglés sin darte cuenta",            highlight: "inglés")
        ]
    )

    // MARK: - Treatment C — Feature / Tech (specific differentiator)

    static let treatmentC = TreatmentCopy(
        id: "C",
        label: "Feature / Technical",
        home: [
            "en-US": Headline(text: "3,900 phrases for devs, 13 contexts",        highlight: "phrases"),
            "pt-BR": Headline(text: "3.900 frases para devs, 13 contextos",       highlight: "frases"),
            "es-ES": Headline(text: "3.900 frases para devs, 13 contextos",       highlight: "frases"),
            "es-MX": Headline(text: "3.900 frases para devs, 13 contextos",       highlight: "frases")
        ],
        feature1: [
            "en-US": Headline(text: "13 categories from PR to interviews",        highlight: "categories"),
            "pt-BR": Headline(text: "13 categorias, de PR a entrevistas",         highlight: "categorias"),
            "es-ES": Headline(text: "13 categorías, de PR a entrevistas",         highlight: "categorías"),
            "es-MX": Headline(text: "13 categorías, de PR a entrevistas",         highlight: "categorías")
        ],
        feature2: [
            "en-US": Headline(text: "Native audio + context, every phrase",       highlight: "audio"),
            "pt-BR": Headline(text: "Áudio nativo + contexto, cada frase",        highlight: "Áudio"),
            "es-ES": Headline(text: "Audio nativo + contexto, cada frase",        highlight: "Audio"),
            "es-MX": Headline(text: "Audio nativo + contexto, cada frase",        highlight: "Audio")
        ],
        settings: [
            "en-US": Headline(text: "Streaks, levels, achievements",              highlight: "Streaks"),
            "pt-BR": Headline(text: "Streaks, níveis, conquistas",                highlight: "Streaks"),
            "es-ES": Headline(text: "Rachas, niveles, logros",                    highlight: "Rachas"),
            "es-MX": Headline(text: "Rachas, niveles, logros",                    highlight: "Rachas")
        ],
        onboarding: [
            "en-US": Headline(text: "iOS widget — phrase right on your screen",   highlight: "widget"),
            "pt-BR": Headline(text: "Widget iOS — frase direto na tela",          highlight: "Widget"),
            "es-ES": Headline(text: "Widget iOS — frase en tu pantalla",          highlight: "Widget"),
            "es-MX": Headline(text: "Widget iOS — frase en tu pantalla",          highlight: "Widget")
        ]
    )

    static let all: [TreatmentCopy] = [treatmentA, treatmentB, treatmentC]
}
