import Foundation

struct UserSettings: Codable, Equatable {
    var hasCompletedOnboarding: Bool
    var selectedGoal: ScrollGoal
    var defaultUnlockMinutes: Int
    var isPremium: Bool
    var isWebGuardEnabled: Bool
    var isAdultFilterEnabled: Bool

    static let `default` = UserSettings(
        hasCompletedOnboarding: false,
        selectedGoal: .doomscrolling,
        defaultUnlockMinutes: 10,
        isPremium: false,
        isWebGuardEnabled: false,
        isAdultFilterEnabled: false
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
        case .doomscrolling: return "Stop doomscrolling"
        case .lust: return "Guard my eyes"
        case .distraction: return "Focus better"
        case .anxiety: return "Use my time wisely"
        case .lateNight: return "Sleep without scrolling"
        case .entertainment: return "Build Scripture discipline"
        case .comparison: return "Stop comparing"
        case .procrastination: return "Break procrastination"
        }
    }

    var subtitle: String {
        switch self {
        case .doomscrolling: return "Break the loop before the feed takes over."
        case .lust: return "Choose purity before the screen."
        case .distraction: return "Return your attention to what matters."
        case .anxiety: return "Redeem the small moments."
        case .lateNight: return "Protect your rest and your mornings."
        case .entertainment: return "Let Scripture interrupt your habits."
        case .comparison: return "Stop measuring your life by someone else’s highlight reel."
        case .procrastination: return "Do the faithful thing before the easy thing."
        }
    }
}
