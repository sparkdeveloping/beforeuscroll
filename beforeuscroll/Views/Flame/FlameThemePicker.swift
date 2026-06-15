import SwiftUI

struct FlameThemePicker: View {
    @EnvironmentObject private var appState: BYSAppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Flame Themes")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                    .padding(.top, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(BYSFlameTheme.allCases, id: \.id) { theme in
                            themeCard(theme)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                BYSPrimaryButton(title: "Done", systemImage: "checkmark") {
                    dismiss()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
    }
    
    private func themeCard(_ theme: BYSFlameTheme) -> some View {
        let isSelected = appState.focusFlame.selectedFlameTheme == theme.id
        let isPremium = theme.id != "Ember"
        let canUse = appState.settings.isPremium || !isPremium
        
        return Button {
            if canUse {
                appState.setFlameTheme(theme)
                BYSHaptics.success()
            } else {
                showPaywall = true
            }
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(theme.glow.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    BYSFlameView(progress: 0.6, isBurning: true, theme: theme)
                        .scaleEffect(0.4)
                }
                
                VStack(spacing: 4) {
                    Text(theme.id)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(BYSTheme.text)
                    
                    if isPremium && !appState.settings.isPremium {
                        Label("PRO", systemImage: "crown.fill")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(BYSTheme.gold)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isSelected ? theme.glow.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(isSelected ? theme.primary : Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FlameThemePicker()
        .environmentObject(BYSAppState())
}
