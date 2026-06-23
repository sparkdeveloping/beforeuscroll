import Foundation
import UserNotifications

enum BYSNotificationPermissionState: String, Codable {
    case unknown
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
}

@MainActor
final class BYSNotificationService: ObservableObject {
    @Published private(set) var permissionState: BYSNotificationPermissionState = .unknown

    init() {
        // Initialize by refreshing state without blocking UI
        Task { [weak self] in
            await self?.refreshPermissionState()
        }
    }

    func refreshPermissionState() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            permissionState = .notDetermined
        case .denied:
            permissionState = .denied
        case .authorized:
            permissionState = .authorized
        case .provisional:
            permissionState = .provisional
        case .ephemeral:
            permissionState = .ephemeral
        @unknown default:
            permissionState = .unknown
        }
    }

    func requestPermissionFromOnboarding() async {
        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("[BeforeUScroll][Notifications] permission request failed:", error)
        }

        await refreshPermissionState()
    }

    var canScheduleNotifications: Bool {
        permissionState == .authorized || permissionState == .provisional || permissionState == .ephemeral
    }

    func scheduleLowFlameNotificationIfAllowed() async {
        await refreshPermissionState()
        guard canScheduleNotifications else {
            print("[BeforeUScroll][Notifications] skip low Flame notification; permission=\(permissionState.rawValue)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "BeforeUScroll"
        content.body = "Your Flame is getting low."
        content.sound = .default

        // Example trigger: 1 hour later. Replace with app-specific logic.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "bys.lowFlame", content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("[BeforeUScroll][Notifications] failed to schedule low Flame:", error)
        }
    }

    func scheduleProtectionReturnedNotificationIfAllowed() async {
        await refreshPermissionState()
        guard canScheduleNotifications else {
            print("[BeforeUScroll][Notifications] skip protection returned notification; permission=\(permissionState.rawValue)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "BeforeUScroll"
        content.body = "Protection returned. Your Flame is restored."
        content.sound = .default

        // Example trigger: 5 minutes later. Replace with app-specific logic.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
        let request = UNNotificationRequest(identifier: "bys.protectionReturned", content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("[BeforeUScroll][Notifications] failed to schedule protection returned:", error)
        }
    }

    func cancelFlameNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "bys.lowFlame",
            "bys.protectionReturned"
        ])
    }
}
