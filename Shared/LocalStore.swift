import Foundation

enum LocalStoreKey: String {
    case settings = "bys.settings"
    case sessions = "bys.sessions"
    case verseProgress = "bys.verseProgress"
    case verseRotation = "bys.verseRotation"
    case stats = "bys.stats"
}

enum LocalStore {
    static func save<T: Encodable>(_ value: T, for key: LocalStoreKey) {
        do {
            let data = try JSONEncoder().encode(value)
            BYSAppGroup.defaults.set(data, forKey: key.rawValue)
        } catch {
            print("Failed saving \(key.rawValue): \(error)")
        }
    }

    static func load<T: Decodable>(_ type: T.Type, for key: LocalStoreKey) -> T? {
        guard let data = BYSAppGroup.defaults.data(forKey: key.rawValue) else { return nil }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed loading \(key.rawValue): \(error)")
            return nil
        }
    }
}
