import SwiftUI

struct BYSCard<Content: View>: View {
    var padding: CGFloat = 18
    var cornerRadius: CGFloat = 24
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BYSTheme.border, lineWidth: 1)
            )
    }
}

struct BYSGlassCard<Content: View>: View {
    var padding: CGFloat = 18
    var cornerRadius: CGFloat = 26
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.72))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
    }
}

struct BYSPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundStyle(Color.black)
            .background(BYSTheme.warmGradient)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: BYSTheme.ember.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(PressableScaleButtonStyle())
    }
}

struct BYSSecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundStyle(BYSTheme.text)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(BYSTheme.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressableScaleButtonStyle())
    }
}

struct BYSIconButton: View {
    let systemImage: String
    var badgeText: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BYSTheme.text)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.09))
                            .overlay(Circle().stroke(BYSTheme.border, lineWidth: 1))
                    )

                if let badgeText {
                    Text(badgeText)
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(BYSTheme.gold))
                        .offset(x: 4, y: -2)
                }
            }
        }
        .buttonStyle(PressableScaleButtonStyle(pressedScale: 0.92))
    }
}

struct BYSHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(BYSTheme.gold)
                .tracking(2.0)

            Text(title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(BYSTheme.text)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.headline)
                .foregroundStyle(BYSTheme.textMuted)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BYSAnimatedPager<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let selection: Int
    @ViewBuilder var content: (Int) -> Content

    var body: some View {
        ZStack {
            content(selection)
                .id(selection)
                .transition(pageTransition)
        }
        .animation(BYSMotion.state(BYSMotion.softSpring, reduceMotion: reduceMotion), value: selection)
    }

    private var pageTransition: AnyTransition {
        if reduceMotion {
            return .opacity.combined(with: .scale(scale: 0.985))
        }

        return .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)).combined(with: .scale(scale: 0.985)),
            removal: .opacity.combined(with: .move(edge: .leading)).combined(with: .scale(scale: 0.985))
        )
    }
}

extension View {
    func subtleGlow(radius: CGFloat, opacity: Double) -> some View {
        self.shadow(color: Color.white.opacity(opacity), radius: radius)
    }
}
