import SwiftUI

struct BYSParallaxPager<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let step: Int
    @ViewBuilder let content: (Int) -> Content
    
    @State private var previousStep: Int = 0
    @State private var direction: CGFloat = 1 // 1 for forward, -1 for backward
    
    init(step: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.step = step
        self.content = content
    }
    
    var body: some View {
        ZStack {
            content(step)
                .id(step)
                .transition(parallaxTransition)
        }
        .onChange(of: step) { old, new in
            direction = new > old ? 1 : -1
        }
        .animation(BYSMotion.state(BYSMotion.parallaxSpring, reduceMotion: reduceMotion), value: step)
    }
    
    private var parallaxTransition: AnyTransition {
        if reduceMotion {
            return .opacity.combined(with: .scale(scale: 0.98))
        }
        
        return .asymmetric(
            insertion: .opacity
                .combined(with: .move(edge: direction > 0 ? .trailing : .leading))
                .combined(with: .scale(scale: 0.96)),
            removal: .opacity
                .combined(with: .move(edge: direction > 0 ? .leading : .trailing))
                .combined(with: .scale(scale: 1.04))
        )
    }
}
