import SwiftUI

enum BYSTheme {
    // Backgrounds
    static let background = Color(hex: "#100B18") // Deep Midnight/Plum-Black
    static let backgroundDeep = Color(hex: "#0D0F14")
    static let surface = Color(hex: "#1A1424") // Surface Dark
    
    // Accents
    static let ember = Color(hex: "#FF6A3D")
    static let gold = Color(hex: "#FFB86B") // Flame Gold
    static let peach = Color(hex: "#FFD6A3") // Soft Peach
    static let violet = Color(hex: "#7C4DFF")
    
    // Text
    static let text = Color(hex: "#FDFBF7") // Warm Ivory
    static let textMuted = Color(hex: "#FDFBF7").opacity(0.68)
    static let textFaint = Color(hex: "#FDFBF7").opacity(0.42)
    
    static let border = Color.white.opacity(0.12)
    static let green = Color(hex: "#86EFAC")
    static let red = Color(hex: "#FCA5A5")

    static let warmGradient = LinearGradient(
        colors: [
            Color(hex: "#FFD6A3"),
            Color(hex: "#FFB86B"),
            Color(hex: "#FF6A3D")
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
