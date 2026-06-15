import Foundation

enum BYSFocusFlameStore {
    static let freeMaxSeconds = 30 * 60
    static let premiumMaxSeconds = 90 * 60
    static let freeScriptureRechargeSeconds = 10 * 60
    static let premiumScriptureRechargeSeconds = 15 * 60
    static let freePrayerRechargeSeconds = 5 * 60
    static let premiumPrayerRechargeSeconds = 10 * 60
    static let graceUnlockSeconds = 30 * 60
    static let freeGraceUnlocksPerDay = 1
    static let premiumGraceUnlocksPerDay = 3

    private static let stateKey = "bys.focusFlame.state"
    private static let calendar = Calendar.current

    static func snapshot(isPremium: Bool, date: Date = Date()) -> BYSFocusFlameSnapshot {
        let state = normalizedState(isPremium: isPremium, date: date)
        let maxSeconds = maxFlameSeconds(isPremium: isPremium)
        let activeRemaining = activeRemainingSeconds(in: state, date: date)
        let stored = max(0, min(state.storedFlameSeconds, maxSeconds))
        let graceLimit = isPremium ? premiumGraceUnlocksPerDay : freeGraceUnlocksPerDay
        let graceRemaining = max(0, graceLimit - state.dailyGraceUnlocksUsed)

        return BYSFocusFlameSnapshot(
            storedFlameSeconds: stored,
            maxFlameSeconds: maxSeconds,
            activeFlameStartDate: state.activeFlameStartDate,
            activeFlameEndDate: state.activeFlameEndDate,
            activeFlameOriginalSeconds: state.activeFlameOriginalSeconds,
            activeRemainingSeconds: activeRemaining,
            dailyGraceUnlocksRemaining: graceRemaining,
            dailyGraceUnlocksUsed: state.dailyGraceUnlocksUsed,
            lastRechargeDate: state.lastRechargeDate,
            lastDailyResetDate: state.lastDailyResetDate
        )
    }

    @discardableResult
    static func addScriptureRecharge(isPremium: Bool, date: Date = Date()) -> BYSFocusFlameSnapshot {
        addStoredSeconds(isPremium: isPremium, seconds: scriptureRechargeSeconds(isPremium: isPremium), date: date)
    }

    @discardableResult
    static func addPrayerRecharge(isPremium: Bool, date: Date = Date()) -> BYSFocusFlameSnapshot {
        addStoredSeconds(isPremium: isPremium, seconds: prayerRechargeSeconds(isPremium: isPremium), date: date)
    }

    @discardableResult
    static func addStoredSeconds(isPremium: Bool, seconds: Int, date: Date = Date()) -> BYSFocusFlameSnapshot {
        var state = normalizedState(isPremium: isPremium, date: date)
        let cap = maxFlameSeconds(isPremium: isPremium)
        state.storedFlameSeconds = min(cap, max(0, state.storedFlameSeconds) + max(0, seconds))
        state.lastRechargeDate = date
        save(state)
        return snapshot(isPremium: isPremium, date: date)
    }

    @discardableResult
    static func startStoredFlame(isPremium: Bool, date: Date = Date()) -> Int {
        var state = normalizedState(isPremium: isPremium, date: date)
        let seconds = max(0, state.storedFlameSeconds)
        guard seconds > 0 else { return 0 }

        state.storedFlameSeconds = 0
        state.activeFlameStartDate = date
        state.activeFlameEndDate = date.addingTimeInterval(TimeInterval(seconds))
        state.activeFlameOriginalSeconds = seconds
        save(state)
        syncLegacyUnlockState(seconds: seconds, endDate: state.activeFlameEndDate)
        return seconds
    }

    @discardableResult
    static func startGraceUnlock(isPremium: Bool, date: Date = Date()) -> Int {
        var state = normalizedState(isPremium: isPremium, date: date)
        let limit = isPremium ? premiumGraceUnlocksPerDay : freeGraceUnlocksPerDay
        guard state.dailyGraceUnlocksUsed < limit else { return 0 }

        state.dailyGraceUnlocksUsed += 1
        state.activeFlameStartDate = date
        state.activeFlameEndDate = date.addingTimeInterval(TimeInterval(graceUnlockSeconds))
        state.activeFlameOriginalSeconds = graceUnlockSeconds
        save(state)
        syncLegacyUnlockState(seconds: graceUnlockSeconds, endDate: state.activeFlameEndDate)
        return graceUnlockSeconds
    }

    static func clearActiveFlame() {
        var state = load()
        state.activeFlameStartDate = nil
        state.activeFlameEndDate = nil
        state.activeFlameOriginalSeconds = 0
        save(state)
    }

    static func clearExpiredActiveFlame(date: Date = Date()) {
        var state = load()
        if let endDate = state.activeFlameEndDate, endDate <= date {
            state.activeFlameStartDate = nil
            state.activeFlameEndDate = nil
            state.activeFlameOriginalSeconds = 0
            save(state)
        }
    }

    static func scriptureRechargeSeconds(isPremium: Bool) -> Int {
        isPremium ? premiumScriptureRechargeSeconds : freeScriptureRechargeSeconds
    }

    static func prayerRechargeSeconds(isPremium: Bool) -> Int {
        isPremium ? premiumPrayerRechargeSeconds : freePrayerRechargeSeconds
    }

    static func maxFlameSeconds(isPremium: Bool) -> Int {
        isPremium ? premiumMaxSeconds : freeMaxSeconds
    }

    private static func normalizedState(isPremium: Bool, date: Date) -> BYSFocusFlameState {
        var state = load()
        let today = calendar.startOfDay(for: date)
        let cap = maxFlameSeconds(isPremium: isPremium)

        if !calendar.isDate(state.lastDailyResetDate, inSameDayAs: today) {
            state.storedFlameSeconds = 0
            state.dailyGraceUnlocksUsed = 0
            state.lastDailyResetDate = today
        }

        if let endDate = state.activeFlameEndDate, endDate <= date {
            state.activeFlameStartDate = nil
            state.activeFlameEndDate = nil
            state.activeFlameOriginalSeconds = 0
        }

        state.maxFlameSeconds = cap
        state.storedFlameSeconds = min(max(0, state.storedFlameSeconds), cap)
        save(state)
        return state
    }

    private static func activeRemainingSeconds(in state: BYSFocusFlameState, date: Date) -> Int {
        guard let endDate = state.activeFlameEndDate, endDate > date else { return 0 }
        return max(0, Int(endDate.timeIntervalSince(date)))
    }

    private static func syncLegacyUnlockState(seconds: Int, endDate: Date?) {
        guard let endDate else { return }
        BYSUnlockStore.saveUnlockDurationMinutes(max(1, Int(ceil(Double(seconds) / 60.0))))
        BYSUnlockStore.saveUnlockEndDate(endDate)
        BYSUnlockStore.saveDesiredProtectionEnabled(true)
    }

    private static func load() -> BYSFocusFlameState {
        guard let data = BYSAppGroup.defaults.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(BYSFocusFlameState.self, from: data) else {
            return BYSFocusFlameState(lastDailyResetDate: calendar.startOfDay(for: Date()))
        }

        return state
    }

    private static func save(_ state: BYSFocusFlameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        BYSAppGroup.defaults.set(data, forKey: stateKey)
    }
}

struct BYSFocusFlameState: Codable, Equatable {
    var storedFlameSeconds: Int = 0
    var maxFlameSeconds: Int = BYSFocusFlameStore.freeMaxSeconds
    var activeFlameStartDate: Date?
    var activeFlameEndDate: Date?
    var activeFlameOriginalSeconds: Int = 0
    var lastRechargeDate: Date?
    var dailyGraceUnlocksUsed: Int = 0
    var lastDailyResetDate: Date
    var pendingRechargeSource: String?
}

struct BYSFocusFlameSnapshot: Equatable {
    var storedFlameSeconds: Int
    var maxFlameSeconds: Int
    var activeFlameStartDate: Date?
    var activeFlameEndDate: Date?
    var activeFlameOriginalSeconds: Int
    var activeRemainingSeconds: Int
    var dailyGraceUnlocksRemaining: Int
    var dailyGraceUnlocksUsed: Int
    var lastRechargeDate: Date?
    var lastDailyResetDate: Date

    var isFlameActive: Bool { activeRemainingSeconds > 0 }
    var isFlameEmpty: Bool { storedFlameSeconds <= 0 && !isFlameActive }
    var storedAvailableSeconds: Int { max(0, storedFlameSeconds) }

    var storedProgress: Double {
        guard maxFlameSeconds > 0 else { return 0 }
        return Double(storedFlameSeconds) / Double(maxFlameSeconds)
    }

    var activeProgress: Double {
        guard activeFlameOriginalSeconds > 0 else { return 0 }
        return Double(activeRemainingSeconds) / Double(activeFlameOriginalSeconds)
    }
}
