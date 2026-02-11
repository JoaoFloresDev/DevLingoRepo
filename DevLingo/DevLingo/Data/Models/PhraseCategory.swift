import SwiftUI

/// Categories for developer English phrases.
enum PhraseCategory: String, Codable, CaseIterable, Identifiable {
    case standup
    case codeReview
    case slack
    case email
    case meetings
    case technical
    case pullRequests
    case bugReports
    case pairProgramming
    case interviews
    case casual
    case documentation

    var id: String { rawValue }

    // MARK: - Display

    var label: String {
        switch self {
        case .standup: return String(localized: "category.standup")
        case .codeReview: return String(localized: "category.code_review")
        case .slack: return String(localized: "category.slack")
        case .email: return String(localized: "category.email")
        case .meetings: return String(localized: "category.meetings")
        case .technical: return String(localized: "category.technical")
        case .pullRequests: return String(localized: "category.pull_requests")
        case .bugReports: return String(localized: "category.bug_reports")
        case .pairProgramming: return String(localized: "category.pair_programming")
        case .interviews: return String(localized: "category.interviews")
        case .casual: return String(localized: "category.casual")
        case .documentation: return String(localized: "category.documentation")
        }
    }

    var icon: String {
        switch self {
        case .standup: return "person.3.fill"
        case .codeReview: return "eye.fill"
        case .slack: return "bubble.left.and.bubble.right.fill"
        case .email: return "envelope.fill"
        case .meetings: return "video.fill"
        case .technical: return "wrench.and.screwdriver.fill"
        case .pullRequests: return "arrow.triangle.merge"
        case .bugReports: return "ladybug.fill"
        case .pairProgramming: return "person.2.fill"
        case .interviews: return "briefcase.fill"
        case .casual: return "cup.and.saucer.fill"
        case .documentation: return "doc.text.fill"
        }
    }

    var color: Color {
        switch self {
        case .standup: return AppColors.categoryStandup
        case .codeReview: return AppColors.categoryCodeReview
        case .slack: return AppColors.categorySlack
        case .email: return AppColors.categoryEmail
        case .meetings: return AppColors.categoryMeetings
        case .technical: return AppColors.categoryTechnical
        case .pullRequests: return AppColors.categoryPullRequests
        case .bugReports: return AppColors.categoryBugReports
        case .pairProgramming: return AppColors.categoryPairProgramming
        case .interviews: return AppColors.categoryInterviews
        case .casual: return AppColors.categoryCasual
        case .documentation: return AppColors.categoryDocumentation
        }
    }

    /// JSON file name for this category.
    var fileName: String {
        "phrases_\(rawValue)"
    }
}
