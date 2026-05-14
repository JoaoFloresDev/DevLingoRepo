import SwiftUI
import GambitScreenshotKit

// MARK: - Profile (faithful recreation of ProfileView)

struct SettingsScreen: View {
    let locale: String

    var body: some View {
        ZStack {
            MockTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                iOSStatusBar(foreground: .white)
                VStack(spacing: 14) {
                    headerTitle
                    proBanner
                    levelCard
                    statsCard
                    settingsCard
                    widgetCard
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(profileTitle())
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(MockTheme.textPrimary)
            Text(profileSubtitle())
                .font(.system(size: 17))
                .foregroundStyle(MockTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - PRO banner

    private var proBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.system(size: 30))
                .foregroundStyle(MockTheme.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(proTitleLabel())
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(MockTheme.textPrimary)
                Text(proSubtitleLabel())
                    .font(.system(size: 13))
                    .foregroundStyle(MockTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(MockTheme.accent)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [MockTheme.accent.opacity(0.15), MockTheme.accent.opacity(0.05)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(MockTheme.accent.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Level card (with circular progress)

    private var levelCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(levelWord()) 12")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(MockTheme.textPrimary)
                    Text(LocalizedLabels.levelTitle[locale] ?? "")
                        .font(.system(size: 17))
                        .foregroundStyle(MockTheme.primary)
                }
                Spacer()

                ZStack {
                    Circle()
                        .stroke(MockTheme.surfaceSecondary, lineWidth: 8)
                        .frame(width: 70, height: 70)

                    Circle()
                        .trim(from: 0, to: 0.72)
                        .stroke(MockTheme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 70, height: 70)

                    Text("72%")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(MockTheme.textPrimary)
                }
            }

            // Progress bar
            ZStack(alignment: .leading) {
                Capsule().fill(MockTheme.surfaceSecondary).frame(height: 6)
                Capsule().fill(MockTheme.primary).frame(width: 200, height: 6)
            }

            Text(phrasesToNextLabel())
                .font(.system(size: 13))
                .foregroundStyle(MockTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider().background(MockTheme.surfaceSecondary)

            HStack(spacing: 24) {
                streakRow(icon: "flame.fill", color: MockTheme.accent, value: "47", label: currentStreakLabel())
                streakRow(icon: "trophy.fill", color: MockTheme.secondary, value: "62", label: longestStreakLabel())
            }
        }
        .padding(18)
        .background(MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func streakRow(icon: String, color: Color, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(MockTheme.textPrimary)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(MockTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats card (learned + saved)

    private var statsCard: some View {
        VStack(spacing: 0) {
            statRow(icon: "checkmark.circle.fill", color: MockTheme.secondary, title: learnedTotalLabel(), value: "847")
            Divider().background(MockTheme.surfaceSecondary).padding(.horizontal, 16)
            statRow(icon: "bookmark.fill", color: MockTheme.primary, title: savedLabel(), value: "62")
        }
        .background(MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func statRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 19))
                .foregroundStyle(color)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(MockTheme.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(MockTheme.textSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(MockTheme.textTertiary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    // MARK: - Settings card (language, notifications, rate)

    private var settingsCard: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "globe", title: languageLabel(), detail: currentLanguageName())
            Divider().background(MockTheme.surfaceSecondary).padding(.horizontal, 16)
            settingsRow(icon: "bell.fill", title: notificationsLabel())
            Divider().background(MockTheme.surfaceSecondary).padding(.horizontal, 16)
            settingsRow(icon: "star.fill", title: rateLabel())
        }
        .background(MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func settingsRow(icon: String, title: String, detail: String? = nil) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 19))
                .foregroundStyle(MockTheme.primary)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(MockTheme.textPrimary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(size: 15))
                    .foregroundStyle(MockTheme.textTertiary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(MockTheme.textTertiary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // MARK: - Widget card

    private var widgetCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 26))
                .foregroundStyle(MockTheme.primary)
            VStack(alignment: .leading, spacing: 4) {
                Text(widgetTitleLabel())
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(MockTheme.textPrimary)
                Text(widgetDescLabel())
                    .font(.system(size: 13))
                    .foregroundStyle(MockTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MockTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Localized strings

    private func profileTitle() -> String {
        switch locale {
        case "pt-BR": return "Perfil"
        case "es-ES", "es-MX": return "Perfil"
        default: return "Profile"
        }
    }
    private func profileSubtitle() -> String {
        switch locale {
        case "pt-BR": return "Seu progresso e configurações"
        case "es-ES", "es-MX": return "Tu progreso y ajustes"
        default: return "Your progress and settings"
        }
    }
    private func proTitleLabel() -> String {
        switch locale {
        case "pt-BR": return "Desbloqueie tudo"
        case "es-ES", "es-MX": return "Desbloquea todo"
        default: return "Unlock everything"
        }
    }
    private func proSubtitleLabel() -> String {
        switch locale {
        case "pt-BR": return "Acesse todas as categorias e frases exclusivas"
        case "es-ES", "es-MX": return "Accede a todas las categorías y frases exclusivas"
        default: return "Access all categories and exclusive phrases"
        }
    }
    private func levelWord() -> String {
        switch locale {
        case "pt-BR": return "Nível"
        case "es-ES", "es-MX": return "Nivel"
        default: return "Level"
        }
    }
    private func phrasesToNextLabel() -> String {
        switch locale {
        case "pt-BR": return "84 frases para o próximo nível"
        case "es-ES", "es-MX": return "84 frases para el siguiente nivel"
        default: return "84 phrases to next level"
        }
    }
    private func currentStreakLabel() -> String {
        switch locale {
        case "pt-BR": return "Sequência atual"
        case "es-ES", "es-MX": return "Racha actual"
        default: return "Current streak"
        }
    }
    private func longestStreakLabel() -> String {
        switch locale {
        case "pt-BR": return "Maior sequência"
        case "es-ES", "es-MX": return "Mejor racha"
        default: return "Best streak"
        }
    }
    private func learnedTotalLabel() -> String {
        switch locale {
        case "pt-BR": return "Frases aprendidas"
        case "es-ES", "es-MX": return "Frases aprendidas"
        default: return "Phrases learned"
        }
    }
    private func savedLabel() -> String {
        switch locale {
        case "pt-BR": return "Salvas"
        case "es-ES", "es-MX": return "Guardadas"
        default: return "Saved"
        }
    }
    private func languageLabel() -> String {
        switch locale {
        case "pt-BR": return "Idioma"
        case "es-ES", "es-MX": return "Idioma"
        default: return "Language"
        }
    }
    private func notificationsLabel() -> String {
        switch locale {
        case "pt-BR": return "Notificações"
        case "es-ES", "es-MX": return "Notificaciones"
        default: return "Notifications"
        }
    }
    private func rateLabel() -> String {
        switch locale {
        case "pt-BR": return "Avaliar o app"
        case "es-ES", "es-MX": return "Calificar el app"
        default: return "Rate the app"
        }
    }
    private func currentLanguageName() -> String {
        switch locale {
        case "pt-BR": return "Português"
        case "es-ES", "es-MX": return "Español"
        default: return "English"
        }
    }
    private func widgetTitleLabel() -> String {
        switch locale {
        case "pt-BR": return "Widget na tela inicial"
        case "es-ES", "es-MX": return "Widget en pantalla de inicio"
        default: return "Widget on home screen"
        }
    }
    private func widgetDescLabel() -> String {
        switch locale {
        case "pt-BR": return "Veja a frase do dia direto no seu celular"
        case "es-ES", "es-MX": return "Mira la frase del día directo en tu móvil"
        default: return "See the phrase of the day on your phone"
        }
    }
}
