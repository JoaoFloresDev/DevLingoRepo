import SwiftUI
import AppKit
import GambitScreenshotKit

// MARK: - Render-from-PNG Pipeline (A/B test using real device captures)
//
// Variant of the abtest pipeline that uses real screenshots already taken
// from the running app instead of recreating each screen in SwiftUI. The
// PNGs live outside this repo at PNG_BASE_DIR (1242×2688 each, matching
// the iPhone 6.5" canvas which is what DevLingo's live default page uses).
//
// Slot 5 in the original abtest pipeline was the iOS Widget; the captures
// the user provided show the History tab instead, so this file overrides
// the slot-4 (history) headlines with copy that matches the actual
// content. Slots 1, 2, 3, 5 reuse the headlines from Headlines.swift.
//
// Locale mapping:
//   en-US → eng/, pt-BR → pt/, es-ES → esp/
//   es-MX inherits the es-ES PNGs (as the existing pipeline does for content).

private let pngBaseDir = URL(fileURLWithPath: "/Users/joaoflores/Desktop/publicidade/devlingo")

private let localeFolderMap: [String: String] = [
    "en-US": "eng",
    "pt-BR": "pt",
    "es-ES": "esp",
    "es-MX": "esp"
]

// (locale, slot 0-4) → real filename inside that locale's folder.
private let pngFilenameMap: [String: [String]] = [
    "en-US": ["0x0ss (6).png", "0x0ss (1).png", "0x0ss.png",     "0x0ss (2).png", "0x0ss (3).png"],
    "pt-BR": ["0x0ss (5).png", "0x0ss (1).png", "0x0ss.png",     "0x0ss (2).png", "0x0ss (3).png"],
    "es-ES": ["0x0ss.png",     "0x0ss (2).png", "0x0ss (3).png", "0x0ss (1).png", "0x0ss (4).png"],
    "es-MX": ["0x0ss.png",     "0x0ss (2).png", "0x0ss (3).png", "0x0ss (1).png", "0x0ss (4).png"]
]

// Slot 4 (History) headlines — the captures show the History/Calendar tab,
// not the iOS Widget the original Headlines.swift was written for. Same
// 3-treatment angle, anchored to ASO keywords each locale already ranks for.
private let historyHeadlines: [String: LocalizedHeadlines] = [
    "A": [  // Direct / Action
        "en-US": Headline(text: "See every day you practiced",       highlight: "day"),
        "pt-BR": Headline(text: "Veja cada dia que praticou",         highlight: "dia"),
        "es-ES": Headline(text: "Ve cada día que practicaste",        highlight: "día"),
        "es-MX": Headline(text: "Ve cada día que practicaste",        highlight: "día")
    ],
    "B": [  // Emotional / Aspirational
        "en-US": Headline(text: "Watch your streak grow daily",       highlight: "streak"),
        "pt-BR": Headline(text: "Veja sua sequência crescer dia a dia", highlight: "sequência"),
        "es-ES": Headline(text: "Mira tu racha crecer cada día",      highlight: "racha"),
        "es-MX": Headline(text: "Mira tu racha crecer cada día",      highlight: "racha")
    ],
    "C": [  // Feature / Technical
        "en-US": Headline(text: "Daily history, every phrase learned", highlight: "history"),
        "pt-BR": Headline(text: "Histórico diário, cada frase aprendida", highlight: "Histórico"),
        "es-ES": Headline(text: "Historial diario, cada frase aprendida", highlight: "Historial"),
        "es-MX": Headline(text: "Historial diario, cada frase aprendida", highlight: "Historial")
    ]
]

@MainActor
func runFromPNGPipeline() throws {
    let outputBase = URL(fileURLWithPath: NSString(string: "../fastlane/screenshots").expandingTildeInPath)
    try FileManager.default.createDirectory(at: outputBase, withIntermediateDirectories: true)

    let device: DeviceKind = .iPhone6_5
    let canvas = device.canvasSize
    let locales = ["en-US", "pt-BR", "es-ES", "es-MX"]
    let treatments = Headlines.all

    var totalRendered = 0

    for treatment in treatments {
        let baseDir = outputBase.appendingPathComponent("treatment_\(treatment.id)")

        for locale in locales {
            let uploadDir = baseDir.appendingPathComponent(locale)
            try FileManager.default.createDirectory(at: uploadDir, withIntermediateDirectories: true)
            let validationDir = baseDir.appendingPathComponent("_validation")
            try FileManager.default.createDirectory(at: validationDir, withIntermediateDirectories: true)

            try renderFromPNGSet(
                treatment: treatment,
                locale: locale,
                device: device,
                canvas: canvas,
                outputDir: uploadDir,
                validationDir: validationDir
            )
            totalRendered += 6  // 5 upload + 1 validation
            print("✅ treatment_\(treatment.id) / \(locale) — 5 marketing PNGs + 1 validation done")
        }
    }

    print("\n\(totalRendered) PNGs rendered at: \(outputBase.path)")
}

@MainActor
private func renderFromPNGSet(
    treatment: TreatmentCopy,
    locale: String,
    device: DeviceKind,
    canvas: CGSize,
    outputDir: URL,
    validationDir: URL
) throws {
    let totalSlots = 5
    guard
        let folderName = localeFolderMap[locale],
        let filenames = pngFilenameMap[locale]
    else {
        throw PipelineError(description: "No PNG mapping for locale \(locale)")
    }

    // Slot copy: home, feature1, feature2, history (override), settings.
    let slotHeadlines: [LocalizedHeadlines] = [
        treatment.home,
        treatment.feature1,
        treatment.feature2,
        historyHeadlines[treatment.id] ?? [:],
        treatment.settings
    ]

    let slotNames = ["01_home_iphone.png",
                     "02_categories_iphone.png",
                     "03_phrase_detail_iphone.png",
                     "04_history_iphone.png",
                     "05_profile_iphone.png"]

    var marketingURLs: [URL] = []

    for slotIndex in 0..<totalSlots {
        let pngURL = pngBaseDir
            .appendingPathComponent(folderName)
            .appendingPathComponent(filenames[slotIndex])

        guard let nsImage = NSImage(contentsOf: pngURL) else {
            throw PipelineError(description: "Failed to load PNG: \(pngURL.path)")
        }

        let outURL = outputDir.appendingPathComponent(slotNames[slotIndex])
        let headline = slotHeadlines[slotIndex][locale] ?? Headline(text: "", highlight: nil)

        let view = MarketingScreen(
            device: device,
            headline: headline.text,
            highlightWord: headline.highlight,
            slotIndex: slotIndex,
            totalSlots: totalSlots
        ) {
            // No explicit frame here — DeviceFrame stamps the screen slot at
            // (screenPointSize × nativeScale). Locking the Image to plain
            // screenPointSize would leave it shrunk inside that bigger slot.
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }

        try render(view: view, canvas: canvas, scale: 1.0, to: outURL)
        marketingURLs.append(outURL)
    }

    // Validation App Store listing mockup (uses first 3 marketing PNGs as thumbs)
    let urlMockup = validationDir.appendingPathComponent("06_appstore_listing_\(locale).png")
    let mockup = AppStoreListingMockup(
        appName: LocalizedListing.appName[locale] ?? "Devlingo",
        subtitle: LocalizedListing.subtitle[locale] ?? "",
        searchQuery: locale.hasPrefix("pt") ? "inglês para devs" :
                     (locale.hasPrefix("es") ? "inglés para devs" : "english for devs"),
        screenshotURLs: Array(marketingURLs.prefix(3))
    ) {
        DefaultAppIcon(size: 110)
    }
    try render(view: mockup, canvas: device.screenPointSize, scale: 3.0, to: urlMockup)
}
