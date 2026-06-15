import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum BYSMotion {
    static let softSpring = Animation.spring(response: 0.42, dampingFraction: 0.86)
    static let quickSpring = Animation.spring(response: 0.28, dampingFraction: 0.78)
    static let successSpring = Animation.spring(response: 0.34, dampingFraction: 0.62)
    static let gentleEase = Animation.easeInOut(duration: 0.32)

    static func state(_ animation: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.16) : animation
    }
}

enum BYSHaptics {
    static func lightTap() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    static func impact() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}

struct PressableScaleButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var pressedScale: CGFloat = 0.975

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? pressedScale : 1)
            .animation(BYSMotion.state(BYSMotion.quickSpring, reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}

struct CardEntranceModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false
    var delay: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible || reduceMotion ? 1 : 0.975)
            .offset(y: isVisible || reduceMotion ? 0 : 14)
            .onAppear {
                let animation = BYSMotion.state(BYSMotion.softSpring.delay(delay), reduceMotion: reduceMotion)
                withAnimation(animation) {
                    isVisible = true
                }
            }
    }
}

struct FloatingCardModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFloating = false
    var distance: CGFloat = 4

    func body(content: Content) -> some View {
        content
            .offset(y: isFloating && !reduceMotion ? -distance : 0)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
    }
}

struct ParallaxTiltModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGSize = .zero
    var maxTilt: Double = 3.0

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(reduceMotion ? 0 : Double(dragOffset.height / 18).clamped(to: -maxTilt...maxTilt)), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(reduceMotion ? 0 : Double(-dragOffset.width / 18).clamped(to: -maxTilt...maxTilt)), axis: (x: 0, y: 1, z: 0))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !reduceMotion else { return }
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        withAnimation(BYSMotion.softSpring) {
                            dragOffset = .zero
                        }
                    }
            )
    }
}

struct SubtleGlowModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isGlowing = false
    var color: Color = BYSTheme.gold
    var radius: CGFloat = 22
    var opacity: Double = 0.24

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isGlowing && !reduceMotion ? opacity : opacity * 0.45), radius: isGlowing && !reduceMotion ? radius : radius * 0.45, x: 0, y: 10)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
    }
}

extension View {
    func pressableScale(_ scale: CGFloat = 0.975) -> some View {
        buttonStyle(PressableScaleButtonStyle(pressedScale: scale))
    }

    func cardEntrance(delay: Double = 0) -> some View {
        modifier(CardEntranceModifier(delay: delay))
    }

    func floatingCard(distance: CGFloat = 4) -> some View {
        modifier(FloatingCardModifier(distance: distance))
    }

    func parallaxTilt(maxTilt: Double = 3.0) -> some View {
        modifier(ParallaxTiltModifier(maxTilt: maxTilt))
    }

    func subtleGlow(color: Color = BYSTheme.gold, radius: CGFloat = 22, opacity: Double = 0.24) -> some View {
        modifier(SubtleGlowModifier(color: color, radius: radius, opacity: opacity))
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
