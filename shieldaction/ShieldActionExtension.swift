//
//  ShieldActionExtension.swift
//  shieldaction
//
//  Created by Denzel Nyatsanza on 5/20/26.
//

import ManagedSettings
@preconcurrency import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    nonisolated override init() {
        super.init()
    }

    nonisolated override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }

    nonisolated override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }

    nonisolated override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }

    private nonisolated func handle(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            handlePrimaryButton(completionHandler: completionHandler)

        case .secondaryButtonPressed:
            BYSShieldActionStore.saveDebugEvent("secondary")
            BYSShieldActionStore.saveResponseAttempted("close")
            Self.debugLog("secondary tapped; closing shielded app")
            completionHandler(.close)

        default:
            BYSShieldActionStore.saveDebugEvent("unknown")
            BYSShieldActionStore.saveResponseAttempted("close")
            completionHandler(.close)
        }
    }

    private nonisolated func handlePrimaryButton(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        Self.debugLog("BYS SHIELD ACTION EXTENSION RUNNING — primary tapped")
        BYSShieldActionStore.requestPauseFromShield()
        BYSShieldActionStore.saveDebugEvent("primary")

        Self.scheduleNotificationIfAuthorized {
            BYSShieldActionStore.saveResponseAttempted("close")
            Self.debugLog("primary tapped; pause prepared, closing shielded app intentionally")
            completionHandler(.close)
        }
    }

    private nonisolated static func scheduleNotificationIfAuthorized(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let statusDescription = Self.describeAuthorizationStatus(settings.authorizationStatus)
            BYSShieldActionStore.saveNotificationPermissionStatus(statusDescription)

            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional || settings.authorizationStatus == .ephemeral else {
                BYSShieldActionStore.saveLastNotificationScheduled(false)
                Self.debugLog("notification fallback skipped; status=\(statusDescription)")
                completion()
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Your pause is ready"
            content.body = "Open BeforeUScroll to complete it."
            content.sound = .default
            content.userInfo = ["url": "beforeuscroll://pause"]

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "bys.shield.pause", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                let scheduled = error == nil
                BYSShieldActionStore.saveLastNotificationScheduled(scheduled)
                if let error {
                    Self.debugLog("notification fallback failed: \(error.localizedDescription)")
                } else {
                    Self.debugLog("notification fallback scheduled")
                }
                completion()
            }
        }
    }

    private nonisolated static func describeAuthorizationStatus(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "notDetermined"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        case .provisional:
            return "provisional"
        case .ephemeral:
            return "ephemeral"
        @unknown default:
            return "unknown"
        }
    }

    private nonisolated static func debugLog(_ message: String) {
        #if DEBUG
        print("[BeforeUScroll][ShieldActionExtension] \(message)")
        #endif
    }
}
