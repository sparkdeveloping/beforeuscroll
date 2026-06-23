import Foundation

enum BYSAppGroup {
    static let identifier = "group.com.denzeltinashe.beforeuscroll"

    static var defaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: identifier) else {
            assertionFailure("Unable to open App Group defaults: \(identifier)")
            return .standard
        }
        return defaults
    }

    static func logAvailability() {
        let available = UserDefaults(suiteName: identifier) != nil
        print("[BeforeUScroll][AppGroup] \(identifier) available=\(available)")
    }
}
