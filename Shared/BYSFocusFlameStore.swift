import Foundation

enum BYSFocusFlameStore {
    static let freeMaxSeconds = 30 * 60
    static let premiumMaxSeconds = 3 * 60 * 60 // 3 hours
    static let freeScriptureRechargeSeconds = 10 * 60
    static let premiumScriptureRechargeSeconds = 15 * 60
    
    // Prayer recharge rates
    static let freePrayerSecondsPerMinute = 1 * 60
    static let premiumPrayerSecondsPerMinute = 2 * 60
    static let freeMaxPrayerRechargePerSession = 10 * 60
    static let premiumMaxPrayerRechargePerSession = 30 * 60

    private static let stateKey = "bys.focusFlame.state.v2"
    private static let calendar = Calendar.current

    static func snapshot(isPremium: Bool, date: Date = Date()) -> BYSFocusFlameSnapshot {
        let state = normalizedState(isPremium: isPremium, date: date)
        let maxSeconds = maxFlameSeconds(isPremium: isPremium)
        
        let remaining: Int
        if let expiration = state.expirationDate, expiration > date {
            remaining = min(maxSeconds, Int(expiration.timeIntervalSince(date)))
        } else {
            remaining = 0
        }
        
        return BYSFocusFlameSnapshot(
            flameRemainingSeconds: remaining,
            maxFlameSeconds: maxSeconds,
            lastRechargeDate: state.lastRechargeDate,
            lastDailyResetDate: state.lastDailyResetDate,
            prayerSessionStartDate: state.prayerSessionStartDate,
            selectedFlameTheme: state.selectedFlameTheme ?? "Ember"
        )
    }

    struct RechargeResult {
        let snapshot: BYSFocusFlameSnapshot
        let addedSeconds: Int
        let missedSeconds: Int
        let isFull: Bool
    }

    @discardableResult
    static func addScriptureRecharge(isPremium: Bool, durationSeconds: Int, date: Date = Date()) -> RechargeResult {
        let seconds = isPremium ? premiumScriptureRechargeSeconds : freeScriptureRechargeSeconds
        
        // Update stats
        BYSStatsStore.updateStats(scriptureCount: 1, scriptureSeconds: durationSeconds)
        
        return addFlameSeconds(isPremium: isPremium, seconds: seconds, date: date)
    }

    @discardableResult
    static func addFlameSeconds(isPremium: Bool, seconds: Int, date: Date = Date()) -> RechargeResult {
        var state = normalizedState(isPremium: isPremium, date: date)
        let cap = maxFlameSeconds(isPremium: isPremium)
        
        let currentRemaining: Int
        if let expiration = state.expirationDate, expiration > date {
            currentRemaining = Int(expiration.timeIntervalSince(date))
        } else {
            currentRemaining = 0
        }
        
        let newRemaining = min(cap, currentRemaining + seconds)
        let added = newRemaining - currentRemaining
        let missed = seconds - added
        
        state.expirationDate = date.addingTimeInterval(TimeInterval(newRemaining))
        state.lastRechargeDate = date
        save(state)
        
        // Update stats
        BYSStatsStore.updateStats(flameSeconds: added)
        
        // Sync legacy unlock state for Screen Time reconciliation
        syncLegacyUnlockState(seconds: newRemaining, expirationDate: state.expirationDate)
        
        return RechargeResult(
            snapshot: snapshot(isPremium: isPremium, date: date),
            addedSeconds: added,
            missedSeconds: missed,
            isFull: newRemaining >= cap
        )
    }

    static func extinguishFlame(isPremium: Bool, date: Date = Date()) {
        var state = load()
        state.expirationDate = nil
        save(state)
        BYSUnlockStore.saveUnlockEndDate(nil)
    }

    static func startPrayerSession(date: Date = Date()) {
        var state = load()
        state.prayerSessionStartDate = date
        save(state)
    }

    @discardableResult
    static func endPrayerSession(isPremium: Bool, date: Date = Date()) -> RechargeResult? {
        var state = load()
        guard let start = state.prayerSessionStartDate else { return nil }
        
        let duration = Int(date.timeIntervalSince(start))
        state.prayerSessionStartDate = nil
        save(state)
        
        if duration < 30 {
            BYSStatsStore.updateStats(prayerSeconds: duration)
            return RechargeResult(snapshot: snapshot(isPremium: isPremium, date: date), addedSeconds: 0, missedSeconds: 0, isFull: false)
        }
        
        BYSStatsStore.updateStats(prayerCount: 1, prayerSeconds: duration)
        
        let fullMinutes = duration / 60
        let rate = isPremium ? premiumPrayerSecondsPerMinute : freePrayerSecondsPerMinute
        let maxRecharge = isPremium ? premiumMaxPrayerRechargePerSession : freeMaxPrayerRechargePerSession
        let rechargeAmount = min(maxRecharge, fullMinutes * rate)
        
        return addFlameSeconds(isPremium: isPremium, seconds: rechargeAmount, date: date)
    }

    static func setFlameTheme(_ themeID: String) {
        var state = load()
        state.selectedFlameTheme = themeID
        save(state)
    }

    static func maxFlameSeconds(isPremium: Bool) -> Int {
        isPremium ? premiumMaxSeconds : freeMaxSeconds
    }

    private static func normalizedState(isPremium: Bool, date: Date) -> BYSFocusFlameState {
        var state = load()
        let resetDate = dailyResetDate(for: date)
        let cap = maxFlameSeconds(isPremium: isPremium)

        if state.lastDailyResetDate < resetDate {
            state.expirationDate = nil
            state.lastDailyResetDate = resetDate
        }

        // Clamp expiration to cap if needed
        if let expiration = state.expirationDate, expiration > date {
            let remaining = Int(expiration.timeIntervalSince(date))
            if remaining > cap {
                state.expirationDate = date.addingTimeInterval(TimeInterval(cap))
            }
        }

        save(state)
        return state
    }

    private static func dailyResetDate(for date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        if let hour = components.hour, hour < 3 {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: date)!
            var yesterdayComponents = calendar.dateComponents([.year, .month, .day], from: yesterday)
            yesterdayComponents.hour = 3
            return calendar.date(from: yesterdayComponents)!
        } else {
            var todayComponents = calendar.dateComponents([.year, .month, .day], from: date)
            todayComponents.hour = 3
            return calendar.date(from: todayComponents)!
        }
    }

    private static func syncLegacyUnlockState(seconds: Int, expirationDate: Date?) {
        guard let expirationDate, seconds > 0 else {
            BYSUnlockStore.saveUnlockEndDate(nil)
            return
        }
        BYSUnlockStore.saveUnlockDurationMinutes(max(1, Int(ceil(Double(seconds) / 60.0))))
        BYSUnlockStore.saveUnlockEndDate(expirationDate)
        BYSUnlockStore.saveDesiredProtectionEnabled(true)
    }

    private static func load() -> BYSFocusFlameState {
        guard let data = BYSAppGroup.defaults.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(BYSFocusFlameState.self, from: data) else {
            return BYSFocusFlameState(lastDailyResetDate: dailyResetDate(for: Date()))
        }
        return state
    }

    private static func save(_ state: BYSFocusFlameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        BYSAppGroup.defaults.set(data, forKey: stateKey)
    }
}

struct BYSFocusFlameState: Codable, Equatable {
    var expirationDate: Date?
    var lastRechargeDate: Date?
    var lastDailyResetDate: Date
    var prayerSessionStartDate: Date?
    var selectedFlameTheme: String?
}

struct BYSFocusFlameSnapshot: Equatable {
    var flameRemainingSeconds: Int
    var maxFlameSeconds: Int
    var lastRechargeDate: Date?
    var lastDailyResetDate: Date
    var prayerSessionStartDate: Date?
    var selectedFlameTheme: String

    var isFlameActive: Bool { flameRemainingSeconds > 0 }
    var isFlameEmpty: Bool { flameRemainingSeconds <= 0 }
    var isLow: Bool { isFlameActive && (Double(flameRemainingSeconds) <= Double(maxFlameSeconds) * 0.2 || flameRemainingSeconds <= 120) }

    var fillPercentage: Double {
        guard maxFlameSeconds > 0 else { return 0 }
        return Double(flameRemainingSeconds) / Double(maxFlameSeconds)
    }
}
