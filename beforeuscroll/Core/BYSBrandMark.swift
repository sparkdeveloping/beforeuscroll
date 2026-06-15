import SwiftUI

struct BYSBrandMark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    enum Size {
        case small
        case medium
        case large
        case hero
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 56
            case .large: return 110
            case .hero: return 200
            }
        }
    }

    var size: Size = .medium
    var showsGlow: Bool = true
    var showsBackground: Bool = false

    var body: some View {
        ZStack {
            if showsGlow {
                Circle()
                    .fill(BYSTheme.ember.opacity(showsBackground ? 0.4 : 0.3))
                    .frame(width: size.dimension * 1.4, height: size.dimension * 1.4)
                    .blur(radius: size.dimension * 0.35)
                    .opacity(reduceMotion ? 0.5 : 1.0)
            }
            
            if showsBackground {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size.dimension * 1.3, height: size.dimension * 1.3)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: size.dimension, height: size.dimension)
                .accessibilityLabel("BeforeUScroll Flame")
        }
    }
}

#Preview {
    ZStack {
        BYSTheme.background.ignoresSafeArea()
        VStack(spacing: 40) {
            BYSBrandMark(size: .small)
            BYSBrandMark(size: .medium, showsBackground: true)
            BYSBrandMark(size: .large)
            BYSBrandMark(size: .hero)
        }
    }
}
