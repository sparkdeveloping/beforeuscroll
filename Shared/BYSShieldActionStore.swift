import Foundation

struct BYSShieldDebugSnapshot: Equatable {
    let lastActionDate: Date?
    let lastActionType: String
    let pendingPauseRequest: Bool
    let lastResponseAttempted: String
    let notificationPermissionStatus: String
    let lastNotificationScheduled: Bool
    let lastAppActiveDate: Date?
    let lastPendingPauseConsumedDate: Date?
    let appGroupID: String
}

enum BYSShieldActionStore {
    private static let pendingPauseKey = "bys.pendingPauseFromShield"
    private static let lastShieldActionDateKey = "bys.lastShieldActionDate"
    private static let lastShieldActionTypeKey = "bys.lastShieldActionType"
    private static let lastShieldResponseAttemptedKey = "bys.lastShieldResponseAttempted"
    private static let notificationPermissionStatusKey = "bys.shieldNotificationPermissionStatus"
    private static let lastNotificationScheduledKey = "bys.lastShieldNotificationScheduled"
    private static let lastAppActiveDateKey = "bys.lastAppActiveDate"
    private static let lastPendingPauseConsumedDateKey = "bys.lastPendingPauseConsumedDate"

    static func requestPauseFromShield() {
        debugLog("shield primary pressed; saving pause request")
        BYSAppGroup.defaults.set(true, forKey: pendingPauseKey)
        BYSAppGroup.defaults.set(Date(), forKey: lastShieldActionDateKey)
        BYSAppGroup.defaults.set("primary", forKey: lastShieldActionTypeKey)
        debugLog("pause request saved")
    }

    static func saveDebugEvent(_ event: String) {
        BYSAppGroup.defaults.set(Date(), forKey: lastShieldActionDateKey)
        BYSAppGroup.defaults.set(event, forKey: lastShieldActionTypeKey)
        debugLog("debug event saved: \(event)")
    }

    static func saveResponseAttempted(_ response: String) {
        BYSAppGroup.defaults.set(response, forKey: lastShieldResponseAttemptedKey)
        debugLog("response attempted: \(response)")
    }

    static func saveNotificationPermissionStatus(_ status: String) {
        BYSAppGroup.defaults.set(status, forKey: notificationPermissionStatusKey)
        debugLog("notification permission status: \(status)")
    }

    static func saveLastNotificationScheduled(_ scheduled: Bool) {
        BYSAppGroup.defaults.set(scheduled, forKey: lastNotificationScheduledKey)
        debugLog("last notification scheduled: \(scheduled)")
    }

    static func saveAppBecameActive() {
        BYSAppGroup.defaults.set(Date(), forKey: lastAppActiveDateKey)
        debugLog("app active timestamp saved")
    }

    static func consumePendingPauseRequest() -> Bool {
        let pending = hasPendingPauseRequest()
        if pending {
            BYSAppGroup.defaults.set(false, forKey: pendingPauseKey)
            BYSAppGroup.defaults.set(Date(), forKey: lastPendingPauseConsumedDateKey)
            debugLog("app consumed pending pause request")
        }
        return pending
    }

    static func hasPendingPauseRequest() -> Bool {
        BYSAppGroup.defaults.bool(forKey: pendingPauseKey)
    }

    static func lastShieldActionDate() -> Date? {
        BYSAppGroup.defaults.object(forKey: lastShieldActionDateKey) as? Date
    }

    static func debugSnapshot() -> BYSShieldDebugSnapshot {
        BYSShieldDebugSnapshot(
            lastActionDate: lastShieldActionDate(),
            lastActionType: BYSAppGroup.defaults.string(forKey: lastShieldActionTypeKey) ?? "None",
            pendingPauseRequest: hasPendingPauseRequest(),
            lastResponseAttempted: BYSAppGroup.defaults.string(forKey: lastShieldResponseAttemptedKey) ?? "None",
            notificationPermissionStatus: BYSAppGroup.defaults.string(forKey: notificationPermissionStatusKey) ?? "Unknown",
            lastNotificationScheduled: BYSAppGroup.defaults.bool(forKey: lastNotificationScheduledKey),
            lastAppActiveDate: BYSAppGroup.defaults.object(forKey: lastAppActiveDateKey) as? Date,
            lastPendingPauseConsumedDate: BYSAppGroup.defaults.object(forKey: lastPendingPauseConsumedDateKey) as? Date,
            appGroupID: BYSAppGroup.id
        )
    }

    private static func debugLog(_ message: String) {
        #if DEBUG
        print("[BeforeUScroll][ShieldActionStore] \(message)")
        #endif
    }
}
