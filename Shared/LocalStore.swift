import Foundation

enum LocalStoreKey: String {
    case settings = "bys.settings"
    case sessions = "bys.sessions"
    case verseProgress = "bys.verseProgress"
    case verseRotation = "bys.verseRotation"
    case stats = "bys.stats"
}

enum BYSPersistence {
    static func encode<T: Encodable>(_ value: T, label: String) throws -> Data {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(value)
            print("BYS encode success:", label, "bytes:", data.count)
            return data
        } catch {
            print("BYS encode failed:", label, error)
            throw error
        }
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data, label: String) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch {
            print("BYS decode failed:", label, error)
            throw error
        }
    }
}

struct PersistedSettings: Codable, Equatable {
    var hasCompletedOnboarding: Bool
    var selectedGoalRawValue: String
    var isProtectionEnabled: Bool
    var selectedThemeRawValue: String?
    var notificationPermissionAsked: Bool
    var isWebGuardEnabled: Bool
    var isAdultFilterEnabled: Bool
    var defaultUnlockMinutes: Int
}

struct PersistedStats: Codable, Equatable {
    var scripturesRead: Int
    var secondsInWord: Int
    var prayersCompleted: Int
    var secondsInPrayer: Int
}

struct PersistedFlameState: Codable, Equatable {
    var remainingSeconds: Int
    var maxSeconds: Int
    var lastUpdatedAt: Date
}

struct PersistedVerseRotationState: Codable, Equatable {
    var queueByGoal: [String: [String]]
    var usedByGoal: [String: [String]]
    var lastVerseIDByGoal: [String: String]
    var lastFirstQuestionIDByGoal: [String: String]
}

enum LocalStore {
    static func save<T: Encodable>(_ value: T, for key: LocalStoreKey) {
        do {
            let data = try BYSPersistence.encode(value, label: key.rawValue)
            BYSAppGroup.defaults.set(data, forKey: key.rawValue)
        } catch {
            print("Failed saving \(key.rawValue): \(error)")
        }
    }

    static func load<T: Decodable>(_ type: T.Type, for key: LocalStoreKey) -> T? {
        guard let data = BYSAppGroup.defaults.data(forKey: key.rawValue) else { return nil }

        do {
            return try BYSPersistence.decode(type, from: data, label: key.rawValue)
        } catch {
            print("Failed loading \(key.rawValue): \(error)")
            return nil
        }
    }

}
