import SwiftUI
import GambitScreenshotKit

// MARK: - Widget on iOS Home Screen (Slot 5)
//
// Recreates iOS home screen with the real DevLingoWidget: black bg,
// English phrase centered, white text ~19pt semibold. Surrounded by
// a realistic home-screen icon grid.

struct OnboardingScreen: View {
    let locale: String

    var body: some View {
        ZStack {
            // Dark iOS wallpaper
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.07, blue: 0.10),
                    Color(red: 0.10, green: 0.12, blue: 0.18),
                    Color(red: 0.05, green: 0.06, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle purple glow behind widget
            Circle()
                .fill(MockTheme.primary.opacity(0.18))
                .frame(width: 380, height: 380)
                .blur(radius: 90)
                .offset(y: 0)

            VStack(spacing: 0) {
                iOSStatusBar(foreground: .white)

                // Lock-screen-style clock
                VStack(spacing: -2) {
                    Text(dateLabel())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                    Text("9:41")
                        .font(.system(size: 76, weight: .thin, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.top, 14)
                .padding(.bottom, 18)

                // First app row (top)
                appIconRow([
                    AppIconInfo("safari", bg: gradient("0A84FF", "0066D6")),
                    AppIconInfo("envelope.fill", bg: gradient("4A8DFF", "0066D6")),
                    AppIconInfo("phone.fill", bg: gradient("30D158", "1A8F2E")),
                    AppIconInfo("message.fill", bg: gradient("66E16F", "30D158"))
                ])
                .padding(.bottom, 14)

                // DevLingo medium widget
                widget
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                // Second app row (below widget)
                appIconRow([
                    AppIconInfo("camera.fill", bg: gradient("3A3A3C", "1C1C1E")),
                    AppIconInfo("photo.fill.on.rectangle.fill", bg: gradient("FF9F0A", "FF6B00")),
                    AppIconInfo("calendar", bg: gradient("FFFFFF", "EEEEEE"), iconColor: .black),
                    AppIconInfo("note.text", bg: gradient("FFD60A", "FFB100"))
                ])
                .padding(.bottom, 14)

                // Third app row
                appIconRow([
                    AppIconInfo("doc.text.fill", bg: gradient("0A84FF", "0066D6")),
                    AppIconInfo("map.fill", bg: gradient("32D74B", "1FA82E")),
                    AppIconInfo("clock.fill", bg: gradient("000000", "1C1C1E")),
                    AppIconInfo("gear", bg: gradient("8E8E93", "5A5A60"))
                ])

                Spacer(minLength: 0)

                // Dock
                HStack(spacing: 22) {
                    dockIcon(AppIconInfo("safari", bg: gradient("0A84FF", "0066D6")))
                    dockIcon(AppIconInfo("message.fill", bg: gradient("66E16F", "30D158")))
                    dockIcon(AppIconInfo("envelope.fill", bg: gradient("4A8DFF", "0066D6")))
                    dockIcon(AppIconInfo("music.note", bg: gradient("FF5E5E", "FF2E2E")))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - DevLingo widget (medium, faithful to real widget)

    private var widget: some View {
        let phrase = MockPhrasesFactory.todayPhrases(locale: locale)[2]
        return VStack(spacing: 0) {
            Spacer()
            Text(phrase.english)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 158)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 12)
    }

    // MARK: - Helpers

    struct AppIconInfo {
        let symbol: String
        let bg: LinearGradient
        let iconColor: Color

        init(_ symbol: String, bg: LinearGradient, iconColor: Color = .white) {
            self.symbol = symbol
            self.bg = bg
            self.iconColor = iconColor
        }
    }

    private func gradient(_ topHex: String, _ bottomHex: String) -> LinearGradient {
        LinearGradient(
            colors: [Color(hex: topHex), Color(hex: bottomHex)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func appIconRow(_ icons: [AppIconInfo]) -> some View {
        HStack(spacing: 22) {
            ForEach(0..<icons.count, id: \.self) { i in
                appIcon(icons[i])
            }
        }
    }

    private func appIcon(_ info: AppIconInfo) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(info.bg)
                .frame(width: 58, height: 58)
            Image(systemName: info.symbol)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(info.iconColor)
        }
    }

    private func dockIcon(_ info: AppIconInfo) -> some View {
        appIcon(info)
    }

    private func dateLabel() -> String {
        switch locale {
        case "pt-BR": return "segunda-feira, 4 de maio"
        case "es-ES", "es-MX": return "lunes, 4 de mayo"
        default: return "Monday, May 4"
        }
    }
}
