import Foundation

struct UserSettings: Codable, Equatable {
    var hasCompletedOnboarding: Bool
    var selectedGoal: ScrollGoal
    var defaultUnlockMinutes: Int
    var isStrictModeEnabled: Bool
    var emergencySkipsRemaining: Int
    var isPremium: Bool

    static let `default` = UserSettings(
        hasCompletedOnboarding: false,
        selectedGoal: .doomscrolling,
        defaultUnlockMinutes: 10,
        isStrictModeEnabled: false,
        emergencySkipsRemaining: 3,
        isPremium: false
    )
}

enum ScrollGoal: String, CaseIterable, Codable, Identifiable {
    case doomscrolling
    case lust
    case distraction
    case anxiety
    case lateNight
    case entertainment
    case comparison
    case procrastination

    var id: String { rawValue }

    var title: String {
        switch self {
        case .doomscrolling: return "Doomscrolling"
        case .lust: return "Lust"
        case .distraction: return "Distraction"
        case .anxiety: return "Anxiety scrolling"
        case .lateNight: return "Late-night phone use"
        case .entertainment: return "Entertainment addiction"
        case .comparison: return "Social comparison"
        case .procrastination: return "Procrastination"
        }
    }

    var subtitle: String {
        switch self {
        case .doomscrolling: return "Endless feeds, short videos, and wasted time."
        case .lust: return "Guard your eyes and protect your heart."
        case .distraction: return "Return your attention to what matters."
        case .anxiety: return "Stop using the feed to escape fear."
        case .lateNight: return "Protect your rest and your mornings."
        case .entertainment: return "Keep entertainment in its proper place."
        case .comparison: return "Stop measuring your life by someone else’s highlight reel."
        case .procrastination: return "Do the faithful thing before the easy thing."
        }
    }
}
