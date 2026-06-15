//
//  DeviceActivityMonitorExtension.swift
//  deviceactivitymonitor
//
//  Created by Denzel Nyatsanza on 5/20/26.
//

import DeviceActivity
import ManagedSettings
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()

    nonisolated override init() {
        super.init()
    }

    nonisolated override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        debugLog("interval did start: \(activity.rawValue)")
    }

    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        debugLog("interval did end: \(activity.rawValue)")
        reconcileSavedShield(reason: "monitor interval ended")
    }

    nonisolated override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        reconcileSavedShield(reason: "event threshold reached")
    }

    nonisolated override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }

    nonisolated override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }

    nonisolated override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }

    private nonisolated func reconcileSavedShield(reason: String) {
        let desiredProtectionEnabled = BYSUnlockStore.loadDesiredProtectionEnabled()
        let unlockEndDate = BYSUnlockStore.loadUnlockEndDate()
        let shieldCurrentlyApplied = BYSUnlockStore.loadShieldCurrentlyApplied()

        #if canImport(FamilyControls)
        let selection = BYSSelectionStore.load()
        let selectionCount = BYSSelectionStore.selectionTotalCount(selection)
        #else
        let selectionCount = BYSSelectionStore.loadSelectedCount()
        #endif

        debugLog("\(reason) | selectionCount=\(selectionCount) desiredProtectionEnabled=\(desiredProtectionEnabled) unlockEndDate=\(String(describing: unlockEndDate)) shieldCurrentlyApplied=\(shieldCurrentlyApplied)")

        guard desiredProtectionEnabled else {
            store.clearAllSettings()
            BYSUnlockStore.saveShieldCurrentlyApplied(false)
            debugLog("relock skipped: desired protection disabled")
            return
        }

        guard selectionCount > 0 else {
            store.clearAllSettings()
            BYSUnlockStore.saveShieldCurrentlyApplied(false)
            debugLog("relock skipped: no selected apps")
            return
        }

        if let unlockEndDate, unlockEndDate > Date() {
            store.clearAllSettings()
            BYSUnlockStore.saveShieldCurrentlyApplied(false)
            debugLog("relock skipped: unlock still active")
            return
        }

        BYSUnlockStore.clearUnlockEndDate()

        #if canImport(FamilyControls)
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        BYSUnlockStore.saveShieldCurrentlyApplied(true)
        debugLog("relock applied")
        #endif
    }

    private nonisolated func debugLog(_ message: String) {
        #if DEBUG
        print("[BeforeUScroll][DeviceActivityMonitor] \(message)")
        #endif
    }
}
