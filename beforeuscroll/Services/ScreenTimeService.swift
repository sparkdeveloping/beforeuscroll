import Foundation
import SwiftUI
import Combine

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
import DeviceActivity
#endif

@MainActor
final class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()

    #if canImport(FamilyControls)
    @Published var selection: FamilyActivitySelection {
        didSet {
            BYSSelectionStore.save(selection)
            currentSelectionCount = BYSSelectionStore.selectionTotalCount(selection)
            debugLogState("selection changed")
        }
    }

    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()
    private let relockActivityName = DeviceActivityName("bys.relockAfterUnlock")
    #endif

    @Published var currentSelectionCount: Int
    @Published var isScreenTimeAuthorized: Bool = false
    @Published private(set) var isProtectionEnabled: Bool
    @Published private(set) var shieldCurrentlyApplied: Bool
    @Published private(set) var unlockEndDate: Date?
    @Published private(set) var remainingUnlockSeconds: Int

    var isTemporarilyUnlocked: Bool {
        remainingUnlockSeconds > 0
    }

    private init() {
        self.isProtectionEnabled = BYSUnlockStore.loadDesiredProtectionEnabled()
        self.shieldCurrentlyApplied = BYSUnlockStore.loadShieldCurrentlyApplied()
        self.unlockEndDate = BYSUnlockStore.loadUnlockEndDate()
        self.remainingUnlockSeconds = BYSUnlockStore.remainingSeconds()

        #if canImport(FamilyControls)
        let loadedSelection = BYSSelectionStore.load()
        self.selection = loadedSelection
        self.currentSelectionCount = BYSSelectionStore.selectionTotalCount(loadedSelection)
        self.isScreenTimeAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        #else
        self.currentSelectionCount = BYSSelectionStore.loadSelectedCount()
        self.isScreenTimeAuthorized = false
        #endif

        refreshPublishedProtectionState()
        debugLogState("init")
    }

    func refreshAuthorizationStatus() {
        #if canImport(FamilyControls)
        isScreenTimeAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        #endif
        refreshPublishedProtectionState()
        debugLogState("authorization refreshed")
    }

    func requestAuthorization() async -> Bool {
        #if canImport(FamilyControls)
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            refreshAuthorizationStatus()
            return isScreenTimeAuthorized
        } catch {
            refreshAuthorizationStatus()
            debugLog("authorization failed: \(error)")
            return false
        }
        #else
        return false
        #endif
    }

    func applyShield() async {
        #if canImport(FamilyControls)
        refreshAuthorizationStatus()
        refreshPublishedProtectionState()
        debugLogState("applyShield called")

        guard isProtectionEnabled else {
            debugLog("applyShield skipped: desired protection disabled")
            return
        }

        guard isScreenTimeAuthorized else {
            debugLog("applyShield skipped: Screen Time authorization not approved")
            return
        }

        guard currentSelectionCount > 0 else {
            BYSUnlockStore.saveShieldCurrentlyApplied(false)
            refreshPublishedProtectionState()
            debugLog("applyShield skipped: no apps selected")
            return
        }

        guard !isTemporarilyUnlocked else {
            await clearShield(userDisabled: false)
            debugLog("applyShield skipped: temporarily unlocked")
            return
        }

        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        BYSUnlockStore.saveDesiredProtectionEnabled(true)
        BYSUnlockStore.saveShieldCurrentlyApplied(true)
        stopRelockMonitor()
        refreshPublishedProtectionState()
        debugLogState("shield applied")
        #endif
    }

    func clearShield(userDisabled: Bool) async {
        #if canImport(FamilyControls)
        debugLog("clearShield called userDisabled=\(userDisabled)")
        store.clearAllSettings()
        if userDisabled {
            BYSUnlockStore.saveDesiredProtectionEnabled(false)
            BYSUnlockStore.clearUnlockEndDate()
            stopRelockMonitor()
        }
        BYSUnlockStore.saveShieldCurrentlyApplied(false)
        refreshPublishedProtectionState()
        debugLogState("shield cleared")
        #endif
    }

    func temporarilyUnlock(minutes: Int) async {
        let unlockMinutes = max(minutes, 1)
        let seconds = unlockMinutes * 60
        let endDate = Date().addingTimeInterval(TimeInterval(seconds))
        BYSUnlockStore.saveDesiredProtectionEnabled(true)
        BYSUnlockStore.saveUnlockDurationMinutes(unlockMinutes)
        BYSUnlockStore.saveUnlockEndDate(endDate)
        refreshPublishedProtectionState()

        await clearShield(userDisabled: false)
        startRelockMonitor(endingAt: endDate)

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
            await self?.reconcileShieldState()
        }
    }

    func lockAgainNow() async {
        BYSUnlockStore.clearUnlockEndDate()
        BYSUnlockStore.saveDesiredProtectionEnabled(true)
        stopRelockMonitor()
        refreshPublishedProtectionState()
        await applyShield()
    }

    func setProtectionEnabled(_ enabled: Bool) async {
        BYSUnlockStore.saveDesiredProtectionEnabled(enabled)
        refreshPublishedProtectionState()

        if enabled {
            await reconcileShieldState()
        } else {
            await clearShield(userDisabled: true)
        }
    }

    func handleSelectionChangedOrPickerDismissed() async {
        #if canImport(FamilyControls)
        BYSSelectionStore.save(selection)
        currentSelectionCount = BYSSelectionStore.selectionTotalCount(selection)
        refreshAuthorizationStatus()

        guard currentSelectionCount > 0 else {
            debugLog("picker dismissed: no selection")
            await reconcileShieldState()
            return
        }

        BYSUnlockStore.saveDesiredProtectionEnabled(true)
        BYSUnlockStore.clearUnlockEndDate()
        stopRelockMonitor()
        refreshPublishedProtectionState()
        await applyShield()
        #endif
    }

    func reconcileShieldState() async {
        refreshAuthorizationStatus()
        refreshPublishedProtectionState()
        debugLogState("reconcile called")

        if isTemporarilyUnlocked {
            debugLog("reconcile: temporarily unlocked, clearing current shield")
            await clearShield(userDisabled: false)
            if let unlockEndDate {
                startRelockMonitor(endingAt: unlockEndDate)
            }
            return
        }

        if unlockEndDate != nil {
            BYSUnlockStore.clearUnlockEndDate()
            stopRelockMonitor()
            refreshPublishedProtectionState()
        }

        guard isProtectionEnabled else {
            debugLog("reconcile skipped: desired protection disabled")
            await clearShield(userDisabled: false)
            return
        }

        guard currentSelectionCount > 0 else {
            debugLog("reconcile skipped: no apps selected")
            await clearShield(userDisabled: false)
            return
        }

        guard isScreenTimeAuthorized else {
            debugLog("reconcile skipped: Screen Time authorization not approved")
            return
        }

        await applyShield()
    }

    private func refreshPublishedProtectionState() {
        isProtectionEnabled = BYSUnlockStore.loadDesiredProtectionEnabled()
        shieldCurrentlyApplied = BYSUnlockStore.loadShieldCurrentlyApplied()
        unlockEndDate = BYSUnlockStore.loadUnlockEndDate()
        remainingUnlockSeconds = BYSUnlockStore.remainingSeconds()
    }

    #if canImport(FamilyControls)
    private func startRelockMonitor(endingAt endDate: Date) {
        guard endDate > Date() else {
            debugLog("relock monitor skipped: unlock end date is not in the future")
            return
        }

        let calendar = Calendar.current
        let start = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second], from: Date())
        let end = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second], from: endDate)
        let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: false)

        do {
            try activityCenter.startMonitoring(relockActivityName, during: schedule)
            debugLogState("started relock monitor endingAt=\(endDate)")
        } catch {
            debugLog("failed to start relock monitor: \(error)")
        }
    }

    private func stopRelockMonitor() {
        activityCenter.stopMonitoring([relockActivityName])
        debugLog("stopped relock monitor")
    }
    #endif

    private func debugLogState(_ event: String) {
        debugLog("\(event) | authorized=\(isScreenTimeAuthorized) selectionCount=\(currentSelectionCount) desiredProtectionEnabled=\(isProtectionEnabled) shieldCurrentlyApplied=\(shieldCurrentlyApplied) unlockEndDate=\(String(describing: unlockEndDate))")
    }

    private func debugLog(_ message: String) {
        #if DEBUG
        print("[BeforeUScroll][ScreenTime] \(message)")
        #endif
    }
}
