import Foundation

enum BYSProductIDs {
    static let weekly = "com.bus.premium.weekly"
    static let monthly = "com.bus.premium.monthly"
    static let yearly = "com.bus.premium.yearly"

    static let ordered = [
        weekly,
        monthly,
        yearly
    ]

    static let all: Set<String> = [
        weekly,
        monthly,
        yearly
    ]
}
