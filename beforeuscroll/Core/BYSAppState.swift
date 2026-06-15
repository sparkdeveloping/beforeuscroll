import Foundation
import SwiftUI
import Combine

struct ActivePauseTrigger: Identifiable {
    let id = UUID()
    let trigger: PauseTrigger
}

enum ProtectionStatus: Equatable {
    case needsSetup
    case protected
    case temporarilyUnlocked(secondsRemaining: Int)
    case notProtected

    var title: String {
        switch self {
        case .needsSetup:
            return "Needs Setup"
        case .protected:
            return "Protected"
        case .temporarilyUnlocked:
            return "Temporarily Unlocked"
        case .notProtected:
            return "Protection Off"
        }
    }

    var subtitle: String {
        switch self {
        case .needsSetup:
            return "Choose one distracting app to protect."
        case .protected:
            return "Selected apps pause with Scripture."
        case .temporarilyUnlocked(let seconds):
            let minutes = max(1, Int(ceil(Double(seconds) / 60.0)))
            return "Protection returns in about \(minutes) min."
        case .notProtected:
            return "Turn protection on to shield selected apps."
        }
    }
}

@MainActor
final class BYSAppState: ObservableObject {
    @Published var settings: UserSettings {
        didSet { LocalStore.save(settings, for: .settings) }
    }

    @Published var sessions: [PauseSession] {
        didSet { LocalStore.save(sessions, for: .sessions) }
    }

    @Published var isPaywallPresented = false
    @Published var activePauseTrigger: ActivePauseTrigger?
    @Published var protectionStatus: ProtectionStatus = .needsSetup

    let screenTimeService = ScreenTimeService.shared
    let storeKitService = StoreKitService.shared

    init() {
        self.settings = LocalStore.load(UserSettings.self, for: .settings) ?? .default
        self.sessions = LocalStore.load([PauseSession].self, for: .sessions) ?? []
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

    var passedTodayCount: Int {
        todaySessions.filter { $0.passedQuiz }.count
    }

    var avoidedUnlocksToday: Int {
        todaySessions.filter { $0.decision == .stayedLocked }.count
    }

    var estimatedMinutesReclaimed: Int {
        avoidedUnlocksToday * 10
    }

    func configure() async {
        await storeKitService.configure()
        settings.isPremium = storeKitService.isPremium
        await handleAppBecameActive()
    }

    func syncPremiumStatus() async {
        await storeKitService.updatePurchasedProducts()
        settings.isPremium = storeKitService.isPremium
    }

    func completeOnboarding(goal: ScrollGoal) {
        settings.selectedGoal = goal
        settings.hasCompletedOnboarding = true
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
    }

    func unlockFor(minutes: Int) {
        Task {
            await screenTimeService.temporarilyUnlock(minutes: minutes)
            refreshProtectionStatus()
        }
    }

    func applyShield() {
        Task {
            await screenTimeService.setProtectionEnabled(true)
            refreshProtectionStatus()
        }
    }

    func lockAgainNow() {
        Task {
            await screenTimeService.lockAgainNow()
            refreshProtectionStatus()
        }
    }

    func setProtectionEnabled(_ enabled: Bool) {
        Task {
            await screenTimeService.setProtectionEnabled(enabled)
            refreshProtectionStatus()
        }
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "beforeuscroll" else { return }

        if url.host == "pause" || url.absoluteString.contains("pause") {
            startPause(trigger: .shield)
        }
    }

    func handleAppBecameActive() async {
        if BYSShieldActionStore.consumePendingPauseRequest() {
            startPause(trigger: .shield)
        }

        await screenTimeService.reconcileShieldState()
        await syncPremiumStatus()
        refreshProtectionStatus()
    }

    func refreshProtectionStatus() {
        screenTimeService.refreshAuthorizationStatus()

        if screenTimeService.isTemporarilyUnlocked {
            protectionStatus = .temporarilyUnlocked(secondsRemaining: screenTimeService.remainingUnlockSeconds)
        } else if !screenTimeService.isScreenTimeAuthorized || protectedSelectionCount == 0 {
            protectionStatus = .needsSetup
        } else if screenTimeService.isProtectionEnabled {
            protectionStatus = .protected
        } else {
            protectionStatus = .notProtected
        }
    }
}
