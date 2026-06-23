import Foundation
import SwiftUI
import Combine
import UserNotifications

struct ActivePauseTrigger: Identifiable {
    let id = UUID()
    let trigger: PauseTrigger
}

enum ProtectionStatus: Equatable {
    case needsAuthorization
    case needsSelection
    case flameEmpty
    case flameBurning(seconds: Int)
    case flameFading(seconds: Int)
    case flameFull(seconds: Int)
    case notProtected

    var title: String {
        switch self {
        case .needsAuthorization:
            return "Screen Time Access"
        case .needsSelection:
            return "Choose Apps"
        case .flameEmpty:
            return "Your Flame is out."
        case .flameBurning:
            return "Your Flame is burning."
        case .flameFading:
            return "Your Flame is fading."
        case .flameFull:
            return "Your Flame is full."
        case .notProtected:
            return "Protection Off"
        }
    }

    var subtitle: String {
        switch self {
        case .needsAuthorization:
            return "BeforeUScroll needs permission to protect your attention."
        case .needsSelection:
            return "Select at least one app or category to protect."
        case .flameEmpty:
            return "Recharge before the scroll gets you."
        case .flameBurning:
            return "Keep it alive with Scripture or prayer."
        case .flameFading:
            return "Protection returns soon."
        case .flameFull:
            return "Your intentional time is fully charged."
        case .notProtected:
            return "Turn protection on to shield selected apps."
        }
    }
}

@MainActor
final class BYSAppState: ObservableObject {
    @Published var settings: UserSettings
    @Published var sessions: [PauseSession]

    @Published var isPaywallPresented = false
    @Published var activePauseTrigger: ActivePauseTrigger?
    @Published var protectionStatus: ProtectionStatus = .needsAuthorization
    @Published var focusFlame: BYSFocusFlameSnapshot
    @Published var stats: BYSStatsState
    
    var currentFlameTheme: BYSFlameTheme {
        BYSFlameTheme.allCases.first(where: { $0.id == focusFlame.selectedFlameTheme }) ?? .ember
    }

    let screenTimeService = ScreenTimeService.shared
    let storeKitService = StoreKitService.shared

    init() {
        let loadedSettings = LocalStore.loadSettings() ?? .default
        self.settings = loadedSettings
        self.sessions = LocalStore.load([PauseSession].self, for: .sessions) ?? []
        self.focusFlame = BYSFocusFlameStore.snapshot(isPremium: loadedSettings.isPremium)
        self.stats = BYSStatsStore.load()
        refreshProtectionStatus()
    }

    var protectedSelectionCount: Int {
        screenTimeService.currentSelectionCount
    }

    var todaySessions: [PauseSession] {
        sessions.filter { Calendar.current.isDateInToday($0.startedAt) }
    }

    var completedTodayCount: Int {
        todaySessions.filter { $0.completedAt != nil }.count
    }

    func configure() async {
        print("BYS bundle:", Bundle.main.bundleIdentifier ?? "nil")
        print("BYS app version:", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "nil", "build:", Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "nil")
        print("BYS products requested:", BYSProductIDs.ordered)
        BYSAppGroup.logAvailability()

        await storeKitService.configure()
        updatePremiumEntitlementFromStoreKit()
        print("BYS premium entitlement:", settings.isPremium)
        
        // Sync Web Guard state to service
        screenTimeService.isWebGuardEnabled = settings.isWebGuardEnabled
        screenTimeService.isAdultFilterEnabled = settings.isAdultFilterEnabled
        
        await handleAppBecameActive()
    }

    func syncPremiumStatus() async {
        await storeKitService.updatePurchasedProducts()
        updatePremiumEntitlementFromStoreKit()
    }

    func completeOnboarding(goal: ScrollGoal) {
        finishOnboarding(selectedGoal: goal)
    }

    func finishOnboarding(selectedGoal: ScrollGoal) {
        settings.hasCompletedOnboarding = true
        settings.selectedGoal = selectedGoal
        saveSettingsSafely()
        BYSVerseRotationStore.ensureQueueExists(for: selectedGoal)
        recalculateHomeMode()
    }

    func saveSettingsSafely() {
        LocalStore.saveSettings(settings)
    }

    private func updatePremiumEntitlementFromStoreKit() {
        settings.isPremium = storeKitService.isPremium
    }

    private func saveSessionsSafely() {
        LocalStore.save(sessions, for: .sessions)
    }

    private func recalculateHomeMode() {
        refreshFocusFlame()
        refreshProtectionStatus()
    }

    func markNotificationPermissionAsked() {
        settings.notificationPermissionAsked = true
        saveSettingsSafely()
    }

    func applyRestoredPremiumStatus(_ isPremium: Bool) {
        settings.isPremium = isPremium
    }

    func setSelectedGoal(_ goal: ScrollGoal) {
        settings.selectedGoal = goal
        saveSettingsSafely()
    }

    func prepareForRecharge() {
        if screenTimeService.isTemporarilyUnlocked {
            Task {
                await screenTimeService.lockAgainNow()
                cancelFocusFlameNotifications()
                refreshFocusFlame()
                refreshProtectionStatus()
            }
        }
    }
    
    func startPause(trigger: PauseTrigger = .voluntary) {
        #if DEBUG
        if trigger == .shield {
            print("[BeforeUScroll][AppState] opening PauseFlow from shield request")
        }
        #endif
        activePauseTrigger = ActivePauseTrigger(trigger: trigger)
    }

    func savePauseSession(_ session: PauseSession) {
        sessions.insert(session, at: 0)
        saveSessionsSafely()

        if session.passedQuiz {
            VerseProgressStore.markCompleted(verseID: session.verseID, for: settings.selectedGoal)
        }
    }

    func rechargeFocusFlameFromScripture(durationSeconds: Int) -> BYSFocusFlameStore.RechargeResult {
        let result = BYSFocusFlameStore.addScriptureRecharge(isPremium: settings.isPremium, durationSeconds: durationSeconds)
        focusFlame = result.snapshot
        
        // Ensure shields are updated and notifications scheduled
        Task {
            await screenTimeService.reconcileShieldState()
            if result.snapshot.flameRemainingSeconds > 0 {
                scheduleFocusFlameNotifications(seconds: result.snapshot.flameRemainingSeconds)
            }
        }
        
        return result
    }

    func endPrayerSession() -> BYSFocusFlameStore.RechargeResult? {
        let result = BYSFocusFlameStore.endPrayerSession(isPremium: settings.isPremium)
        if let result {
            focusFlame = result.snapshot
            
            // Ensure shields are updated and notifications scheduled
            Task {
                await screenTimeService.reconcileShieldState()
                if result.snapshot.flameRemainingSeconds > 0 {
                    scheduleFocusFlameNotifications(seconds: result.snapshot.flameRemainingSeconds)
                }
            }
        }
        refreshProtectionStatus()
        return result
    }

    func setFlameTheme(_ theme: BYSFlameTheme) {
        BYSFocusFlameStore.setFlameTheme(theme.id)
        refreshFocusFlame()
    }
    
    func refreshFocusFlame() {
        focusFlame = BYSFocusFlameStore.snapshot(isPremium: settings.isPremium)
        stats = BYSStatsStore.load()
    }

    func applyShield() {
        Task {
            await screenTimeService.setProtectionEnabled(true)
            refreshProtectionStatus()
        }
    }

    func extinguishFlame() {
        Task {
            BYSFocusFlameStore.extinguishFlame(isPremium: settings.isPremium)
            await screenTimeService.lockAgainNow()
            cancelFocusFlameNotifications()
            refreshFocusFlame()
            refreshProtectionStatus()
        }
    }

    func setProtectionEnabled(_ enabled: Bool) {
        Task {
            await screenTimeService.setProtectionEnabled(enabled)
            refreshProtectionStatus()
        }
    }

    func setWebGuardEnabled(_ enabled: Bool) {
        settings.isWebGuardEnabled = enabled
        saveSettingsSafely()
        screenTimeService.isWebGuardEnabled = enabled
        Task {
            await screenTimeService.reconcileShieldState()
        }
    }
    
    func setAdultFilterEnabled(_ enabled: Bool) {
        settings.isAdultFilterEnabled = enabled
        saveSettingsSafely()
        screenTimeService.isAdultFilterEnabled = enabled
        Task {
            await screenTimeService.reconcileShieldState()
        }
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "beforeuscroll" else { return }

        if url.host == "pause" || url.absoluteString.contains("pause") {
            _ = BYSShieldActionStore.consumePendingPauseRequest()
            BYSHaptics.success()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bys.shield.pause"])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["bys.shield.pause"])
            #if DEBUG
            print("BYS presenting pause flow from shield URL")
            #endif
            startPause(trigger: .shield)
        }
    }

    func handleAppBecameActive() async {
        BYSShieldActionStore.saveAppBecameActive()
        #if DEBUG
        print("BYS app became active")
        let shieldDebug = BYSShieldActionStore.debugSnapshot()
        print("[BeforeUScroll][AppState] shield debug action=\(shieldDebug.lastActionType) response=\(shieldDebug.lastResponseAttempted) pending=\(shieldDebug.pendingPauseRequest) notificationPermission=\(shieldDebug.notificationPermissionStatus) notificationScheduled=\(shieldDebug.lastNotificationScheduled) appActive=\(String(describing: shieldDebug.lastAppActiveDate)) consumed=\(String(describing: shieldDebug.lastPendingPauseConsumedDate)) date=\(String(describing: shieldDebug.lastActionDate))")
        #endif

        if BYSShieldActionStore.consumePendingPauseRequest() {
            BYSHaptics.success()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bys.shield.pause"])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["bys.shield.pause"])
            #if DEBUG
            print("BYS consumed pending shield pause")
            print("BYS presenting pause flow from shield")
            #endif
            startPause(trigger: .shield)
        }

        await screenTimeService.reconcileShieldState()
        await syncPremiumStatus()
        refreshFocusFlame()
        refreshProtectionStatus()
    }

    private func scheduleFocusFlameNotifications(seconds: Int) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

            var requests: [UNNotificationRequest] = []

            if seconds > 60 {
                let warningContent = UNMutableNotificationContent()
                warningContent.title = "Your Flame is fading"
                warningContent.body = "Protection returns in 1 minute."
                warningContent.sound = .default
                let warningTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds - 60), repeats: false)
                requests.append(UNNotificationRequest(identifier: "bys.focusFlame.warning", content: warningContent, trigger: warningTrigger))
            }

            let endedContent = UNMutableNotificationContent()
            endedContent.title = "Protection is back on"
            endedContent.body = "Recharge before the scroll gets you."
            endedContent.sound = .default
            let endedTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(1, seconds)), repeats: false)
            requests.append(UNNotificationRequest(identifier: "bys.focusFlame.ended", content: endedContent, trigger: endedTrigger))

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bys.focusFlame.warning", "bys.focusFlame.ended"])
            for request in requests {
                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    private func cancelFocusFlameNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bys.focusFlame.warning", "bys.focusFlame.ended"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["bys.focusFlame.warning", "bys.focusFlame.ended"])
    }

    func refreshProtectionStatus() {
        screenTimeService.refreshAuthorizationStatus()
        refreshFocusFlame()

        if !screenTimeService.isScreenTimeAuthorized {
            protectionStatus = .needsAuthorization
        } else if protectedSelectionCount == 0 {
            protectionStatus = .needsSelection
        } else if focusFlame.isFlameEmpty {
            if screenTimeService.isProtectionEnabled {
                protectionStatus = .flameEmpty
            } else {
                protectionStatus = .notProtected
            }
        } else if focusFlame.flameRemainingSeconds >= focusFlame.maxFlameSeconds {
            protectionStatus = .flameFull(seconds: focusFlame.flameRemainingSeconds)
        } else if focusFlame.isLow {
            protectionStatus = .flameFading(seconds: focusFlame.flameRemainingSeconds)
        } else {
            protectionStatus = .flameBurning(seconds: focusFlame.flameRemainingSeconds)
        }
    }
}
