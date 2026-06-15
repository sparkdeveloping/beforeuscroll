import Foundation

enum BYSAppGroup {
    static let id = "group.com.sbj.beforeuscroll"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }
}
