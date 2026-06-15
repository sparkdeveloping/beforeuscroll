import SwiftUI

enum BYSTheme {
    static let background = Color(hex: "#05070D")
    static let backgroundDeep = Color(hex: "#02030A")
    static let card = Color.white.opacity(0.075)
    static let cardStrong = Color.white.opacity(0.12)
    static let border = Color.white.opacity(0.12)

    static let text = Color.white
    static let textMuted = Color.white.opacity(0.68)
    static let textFaint = Color.white.opacity(0.42)

    static let gold = Color(hex: "#F7C873")
    static let goldDeep = Color(hex: "#A76D24")
    static let blue = Color(hex: "#7DD3FC")
    static let purple = Color(hex: "#C4B5FD")
    static let green = Color(hex: "#86EFAC")
    static let red = Color(hex: "#FCA5A5")

    static let gradient = LinearGradient(
        colors: [
            Color(hex: "#172554"),
            Color(hex: "#312E81"),
            Color(hex: "#713F12")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [
            Color(hex: "#F7C873"),
            Color(hex: "#F59E0B")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        clean = clean.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
