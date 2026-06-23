import Foundation

struct BYSStatsState: Codable, Equatable {
    var todayScriptureCount: Int = 0
    var todayScriptureSeconds: Int = 0
    var todayPrayerCount: Int = 0
    var todayPrayerSeconds: Int = 0
    var todayFlameSecondsAdded: Int = 0
    
    var allTimeScriptureCount: Int = 0
    var allTimeScriptureSeconds: Int = 0
    var allTimePrayerCount: Int = 0
    var allTimePrayerSeconds: Int = 0
    var allTimeFlameSecondsAdded: Int = 0
    
    var lastDailyResetDate: Date
}

enum BYSStatsStore {
    private static let stateKey = "bys.stats.state"
    private static let calendar = Calendar.current
    
    static func load() -> BYSStatsState {
        LocalStore.load(BYSStatsState.self, for: .stats) ?? BYSStatsState(lastDailyResetDate: dailyResetDate(for: Date()))
    }
    
    static func save(_ state: BYSStatsState) {
        LocalStore.save(state, for: .stats)
    }
    
    static func updateStats(scriptureCount: Int = 0, scriptureSeconds: Int = 0, prayerCount: Int = 0, prayerSeconds: Int = 0, flameSeconds: Int = 0) {
        var state = normalizedState()
        
        state.todayScriptureCount += scriptureCount
        state.todayScriptureSeconds += scriptureSeconds
        state.todayPrayerCount += prayerCount
        state.todayPrayerSeconds += prayerSeconds
        state.todayFlameSecondsAdded += flameSeconds
        
        state.allTimeScriptureCount += scriptureCount
        state.allTimeScriptureSeconds += scriptureSeconds
        state.allTimePrayerCount += prayerCount
        state.allTimePrayerSeconds += prayerSeconds
        state.allTimeFlameSecondsAdded += flameSeconds
        
        save(state)
    }
    
    private static func normalizedState() -> BYSStatsState {
        var state = LocalStore.load(BYSStatsState.self, for: .stats) ?? BYSStatsState(lastDailyResetDate: dailyResetDate(for: Date()))
        let resetDate = dailyResetDate(for: Date())
        
        if state.lastDailyResetDate < resetDate {
            state.todayScriptureCount = 0
            state.todayScriptureSeconds = 0
            state.todayPrayerCount = 0
            state.todayPrayerSeconds = 0
            state.todayFlameSecondsAdded = 0
            state.lastDailyResetDate = resetDate
            save(state)
        }
        
        return state
    }
    
    private static func dailyResetDate(for date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        if let hour = components.hour, hour < 3 {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: date) ?? date
            var yesterdayComponents = calendar.dateComponents([.year, .month, .day], from: yesterday)
            yesterdayComponents.hour = 3
            return calendar.date(from: yesterdayComponents) ?? date
        } else {
            var todayComponents = calendar.dateComponents([.year, .month, .day], from: date)
            todayComponents.hour = 3
            return calendar.date(from: todayComponents) ?? date
        }
    }
}
