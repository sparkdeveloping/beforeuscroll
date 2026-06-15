import SwiftUI

struct BYSFlameView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var progress: Double // 0 to 1
    var isBurning: Bool = false
    var theme: BYSFlameTheme = .ember
    var showFace: Bool = true
    
    var body: some View {
        ZStack {
            // Background glow
            BYSFlameGlow(progress: progress, isBurning: isBurning, theme: theme)
            
            // The Flame Vessel / Silhouette
            BYSFlameSilhouette(progress: progress, isBurning: isBurning, theme: theme, showFace: showFace)
            
            // Particles
            if !reduceMotion && (progress > 0 || isBurning) {
                BYSFlameParticleSystem(theme: theme, intensity: isBurning ? 0.7 + (progress * 0.5) : 0.4)
            }
        }
        .frame(width: 240, height: 300)
    }
}

struct BYSFlameTheme: Equatable, CaseIterable {
    var id: String
    var primary: Color
    var secondary: Color
    var glow: Color
    var particles: Color
    
    static var allCases: [BYSFlameTheme] = [.ember, .violet, .sapphire, .rose, .emerald, .ice, .gold]
    
    static let ember = BYSFlameTheme(
        id: "Ember",
        primary: Color(hex: "#FF6A3D"),
        secondary: Color(hex: "#FFB86B"),
        glow: Color(hex: "#FF6A3D").opacity(0.5),
        particles: Color(hex: "#FFD6A3")
    )
    
    static let violet = BYSFlameTheme(
        id: "Violet",
        primary: Color(hex: "#7C4DFF"),
        secondary: Color(hex: "#C4B5FD"),
        glow: Color(hex: "#7C4DFF").opacity(0.5),
        particles: Color(hex: "#D1C4E9")
    )
    
    static let sapphire = BYSFlameTheme(
        id: "Sapphire",
        primary: Color(hex: "#3B82F6"),
        secondary: Color(hex: "#93C5FD"),
        glow: Color(hex: "#3B82F6").opacity(0.5),
        particles: Color(hex: "#BFDBFE")
    )
    
    static let rose = BYSFlameTheme(
        id: "Rose",
        primary: Color(hex: "#F43F5E"),
        secondary: Color(hex: "#FDA4AF"),
        glow: Color(hex: "#F43F5E").opacity(0.5),
        particles: Color(hex: "#FECDD3")
    )
    
    static let emerald = BYSFlameTheme(
        id: "Emerald",
        primary: Color(hex: "#10B981"),
        secondary: Color(hex: "#6EE7B7"),
        glow: Color(hex: "#10B981").opacity(0.5),
        particles: Color(hex: "#A7F3D0")
    )
    
    static let ice = BYSFlameTheme(
        id: "Ice",
        primary: Color(hex: "#06B6D4"),
        secondary: Color(hex: "#67E8F9"),
        glow: Color(hex: "#06B6D4").opacity(0.5),
        particles: Color(hex: "#A5F3FC")
    )
    
    static let gold = BYSFlameTheme(
        id: "Gold",
        primary: Color(hex: "#F59E0B"),
        secondary: Color(hex: "#FCD34D"),
        glow: Color(hex: "#F59E0B").opacity(0.5),
        particles: Color(hex: "#FDE68A")
    )
}

struct BYSFlameSilhouette: View {
    var progress: Double
    var isBurning: Bool
    var theme: BYSFlameTheme
    var showFace: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Container / Silhouette Outline (Always visible)
            FlameShape()
                .fill(Color.white.opacity(0.04))
                .overlay(
                    FlameShape()
                        .stroke(Color.white.opacity(0.12), lineWidth: 2)
                )
            
            // Filling Light / Internal Flame
            GeometryReader { proxy in
                let size = proxy.size
                
                ZStack(alignment: .bottom) {
                    if progress > 0 {
                        // The Core Liquid/Flame
                        FlameShape()
                            .fill(
                                LinearGradient(
                                    colors: [theme.primary, theme.secondary],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .scaleEffect(y: progress, anchor: .bottom)
                            .opacity(isBurning ? 0.6 + (progress * 0.4) : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                        
                        // Subtle wave top (softened)
                        if progress < 0.98 {
                            Capsule()
                                .fill(theme.secondary)
                                .frame(height: 4)
                                .blur(radius: 4)
                                .offset(y: -size.height * progress + 2)
                                .mask(FlameShape())
                        }
                    }
                }
            }
            
            // Face only in non-burning or high-burning states to avoid timer clash
            if showFace && progress > 0.05 && !isBurning {
                BYSFlameFace(progress: progress)
                    .padding(.bottom, 60)
                    .transition(.opacity)
            }
        }
    }
}

struct BYSFlameFace: View {
    var progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 24) {
                eye
                eye
            }
            
            mouth
        }
        .opacity(0.5)
        .blendMode(.plusLighter)
    }
    
    @ViewBuilder
    private var eye: some View {
        if progress >= 0.75 {
            Path { path in
                path.addArc(center: CGPoint(x: 4, y: 4), radius: 4, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            }
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 8, height: 4)
        } else if progress >= 0.35 {
            Capsule()
                .fill(Color.white)
                .frame(width: 8, height: 2)
        } else if progress >= 0.1 {
            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
        } else {
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 6, height: 1.5)
        }
    }
    
    @ViewBuilder
    private var mouth: some View {
        if progress >= 0.75 {
            Path { path in
                path.addArc(center: CGPoint(x: 8, y: 0), radius: 8, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            }
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 16, height: 8)
        } else if progress >= 0.35 {
            Capsule()
                .fill(Color.white)
                .frame(width: 12, height: 2)
        } else if progress >= 0.1 {
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 6, height: 6)
        } else {
            EmptyView()
        }
    }
}

struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.05))
        
        path.addCurve(
            to: CGPoint(x: width * 0.9, y: height * 0.65),
            control1: CGPoint(x: width * 0.7, y: height * 0.1),
            control2: CGPoint(x: width * 1.05, y: height * 0.4)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.98),
            control1: CGPoint(x: width * 0.8, y: height * 0.85),
            control2: CGPoint(x: width * 0.7, y: height * 0.98)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.1, y: height * 0.65),
            control1: CGPoint(x: width * 0.3, y: height * 0.98),
            control2: CGPoint(x: width * 0.2, y: height * 0.85)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.05),
            control1: CGPoint(x: width * -0.05, y: height * 0.4),
            control2: CGPoint(x: width * 0.3, y: height * 0.1)
        )
        
        return path
    }
}

struct BYSFlameGlow: View {
    var progress: Double
    var isBurning: Bool
    var theme: BYSFlameTheme
    
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            if progress > 0 || isBurning {
                let intensity = isBurning ? 0.5 + (progress * 0.5) : 0.2 + (progress * 0.3)
                
                Circle()
                    .fill(theme.glow)
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .scaleEffect(animateGlow ? 1.3 : 1.0)
                    .opacity(intensity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }
}

struct BYSFlameParticleSystem: View {
    var theme: BYSFlameTheme
    var intensity: Double = 1.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let particles = generateParticles(for: time, size: size)
                
                for particle in particles {
                    context.opacity = particle.opacity * intensity
                    let rect = CGRect(x: particle.x, y: particle.y, width: particle.size, height: particle.size)
                    context.fill(Path(ellipseIn: rect), with: .color(theme.particles))
                }
            }
        }
    }
    
    private func generateParticles(for time: TimeInterval, size: CGSize) -> [Particle] {
        var result: [Particle] = []
        for i in 0..<20 {
            let t = (time * 0.4 + Double(i) * 0.1).truncatingRemainder(dividingBy: 1.0)
            let x = size.width * 0.5 + sin(time * 1.5 + Double(i)) * size.width * 0.35
            let y = size.height * 0.85 - t * size.height * 0.7
            let opacity = max(0, 1.0 - t)
            result.append(Particle(x: x, y: y, size: 1.5 + Double(i % 4), opacity: opacity))
        }
        return result
    }
    
    struct Particle {
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
    }
}

#Preview {
    ZStack {
        BYSTheme.background.ignoresSafeArea()
        VStack(spacing: 40) {
            BYSFlameView(progress: 1.0, isBurning: false)
            BYSFlameView(progress: 0.5, isBurning: true)
            BYSFlameView(progress: 0.1, isBurning: true)
        }
    }
}
