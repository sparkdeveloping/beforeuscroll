import Foundation

struct UserSettings: Codable, Equatable {
    var hasCompletedOnboarding: Bool
    var selectedGoal: ScrollGoal
    var defaultUnlockMinutes: Int
    var isPremium: Bool
    var isWebGuardEnabled: Bool
    var isAdultFilterEnabled: Bool
    var notificationPermissionAsked: Bool

    static let `default` = UserSettings(
        hasCompletedOnboarding: false,
        selectedGoal: .doomscrolling,
        defaultUnlockMinutes: 10,
        isPremium: false,
        isWebGuardEnabled: false,
        isAdultFilterEnabled: false,
        notificationPermissionAsked: false
    )
}

extension PersistedSettings {
    init(settings: UserSettings) {
        self.init(
            hasCompletedOnboarding: settings.hasCompletedOnboarding,
            selectedGoalRawValue: settings.selectedGoal.rawValue,
            isProtectionEnabled: false,
            selectedThemeRawValue: nil,
            notificationPermissionAsked: settings.notificationPermissionAsked,
            isWebGuardEnabled: settings.isWebGuardEnabled,
            isAdultFilterEnabled: settings.isAdultFilterEnabled,
            defaultUnlockMinutes: settings.defaultUnlockMinutes
        )
    }
}

extension UserSettings {
    init(persisted: PersistedSettings) {
        self.init(
            hasCompletedOnboarding: persisted.hasCompletedOnboarding,
            selectedGoal: ScrollGoal(rawValue: persisted.selectedGoalRawValue) ?? .doomscrolling,
            defaultUnlockMinutes: persisted.defaultUnlockMinutes,
            isPremium: false,
            isWebGuardEnabled: persisted.isWebGuardEnabled,
            isAdultFilterEnabled: persisted.isAdultFilterEnabled,
            notificationPermissionAsked: persisted.notificationPermissionAsked
        )
    }
}

extension LocalStore {
    static func saveSettings(_ settings: UserSettings) {
        save(PersistedSettings(settings: settings), for: .settings)
    }

    static func loadSettings() -> UserSettings? {
        guard let data = BYSAppGroup.defaults.data(forKey: LocalStoreKey.settings.rawValue) else { return nil }

        if let persisted = try? BYSPersistence.decode(PersistedSettings.self, from: data, label: LocalStoreKey.settings.rawValue) {
            return UserSettings(persisted: persisted)
        }

        return try? BYSPersistence.decode(UserSettings.self, from: data, label: "\(LocalStoreKey.settings.rawValue).legacy")
    }
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
