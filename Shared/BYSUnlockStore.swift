import Foundation

enum BYSUnlockStore {
    private static let unlockEndDateKey = "bys.unlockEndDate"
    private static let unlockDurationMinutesKey = "bys.unlockDurationMinutes"
    private static let desiredProtectionEnabledKey = "bys.desiredProtectionEnabled"
    private static let shieldCurrentlyAppliedKey = "bys.shieldCurrentlyApplied"
    private static let legacyShieldAppliedKey = "bys.isShieldApplied"

    static func saveUnlockEndDate(_ date: Date?) {
        if let date {
            BYSAppGroup.defaults.set(date, forKey: unlockEndDateKey)
        } else {
            BYSAppGroup.defaults.removeObject(forKey: unlockEndDateKey)
        }
    }

    static func loadUnlockEndDate() -> Date? {
        BYSAppGroup.defaults.object(forKey: unlockEndDateKey) as? Date
    }

    static func clearUnlockEndDate() {
        BYSAppGroup.defaults.removeObject(forKey: unlockEndDateKey)
        BYSAppGroup.defaults.removeObject(forKey: unlockDurationMinutesKey)
    }

    static func saveUnlockDurationMinutes(_ minutes: Int) {
        BYSAppGroup.defaults.set(minutes, forKey: unlockDurationMinutesKey)
    }

    static func loadUnlockDurationMinutes() -> Int {
        BYSAppGroup.defaults.integer(forKey: unlockDurationMinutesKey)
    }

    static func saveDesiredProtectionEnabled(_ value: Bool) {
        BYSAppGroup.defaults.set(value, forKey: desiredProtectionEnabledKey)
    }

    static func loadDesiredProtectionEnabled() -> Bool {
        guard BYSAppGroup.defaults.object(forKey: desiredProtectionEnabledKey) != nil else {
            return false
        }

        return BYSAppGroup.defaults.bool(forKey: desiredProtectionEnabledKey)
    }

    static func saveShieldCurrentlyApplied(_ value: Bool) {
        BYSAppGroup.defaults.set(value, forKey: shieldCurrentlyAppliedKey)
        BYSAppGroup.defaults.set(value, forKey: legacyShieldAppliedKey)
    }

    static func loadShieldCurrentlyApplied() -> Bool {
        BYSAppGroup.defaults.bool(forKey: shieldCurrentlyAppliedKey)
    }

    static func saveShieldApplied(_ value: Bool) {
        saveShieldCurrentlyApplied(value)
    }

    static func loadShieldApplied() -> Bool {
        loadShieldCurrentlyApplied()
    }

    static func isShieldApplied() -> Bool {
        loadShieldCurrentlyApplied()
    }

    static var isCurrentlyUnlocked: Bool {
        isTemporarilyUnlocked
    }

    static var isTemporarilyUnlocked: Bool {
        guard let endDate = loadUnlockEndDate() else { return false }
        return endDate > Date()
    }

    static func remainingSeconds() -> Int {
        guard let endDate = loadUnlockEndDate() else { return 0 }
        return max(0, Int(endDate.timeIntervalSince(Date())))
    }
}
