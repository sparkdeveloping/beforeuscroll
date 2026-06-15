import SwiftUI
import Combine

struct PrayerModeView: View {
    @EnvironmentObject private var appState: BYSAppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var elapsedSeconds = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var hasStarted = false
    @State private var isFinished = false
    @State private var rechargeResult: BYSFocusFlameStore.RechargeResult?
    
    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !isFinished {
                    prayerSessionStep
                } else {
                    prayerResultStep
                }
            }
        }
        .onReceive(timer) { _ in
            if hasStarted && !isFinished {
                elapsedSeconds += 1
            }
        }
        .onAppear {
            startPrayer()
        }
        .interactiveDismissDisabled()
    }
    
    private var prayerSessionStep: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 8) {
                Text("Prayer Mode")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                
                Text("Protected apps are locked while you pray.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BYSTheme.textMuted)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Hero Flame
            BYSFlameView(
                progress: 0.1, // Small ember
                isBurning: true,
                theme: appState.currentFlameTheme,
                showFace: false
            )
            .scaleEffect(1.2)
            .subtleGlow(radius: 40, opacity: 0.2)
            
            VStack(spacing: 20) {
                Text(formattedTime)
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                    .monospacedDigit()
                
                Text("Ask God to help you use your attention wisely.")
                    .font(.headline)
                    .foregroundStyle(BYSTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Footer
            BYSPrimaryButton(title: "Finish Prayer", systemImage: "checkmark.circle.fill") {
                finishPrayer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private var prayerResultStep: some View {
        VStack(spacing: 32) {
            Spacer()

            BYSFlameView(
                progress: appState.focusFlame.fillPercentage,
                isBurning: false,
                theme: appState.currentFlameTheme
            )
            .scaleEffect(1.3)
            
            VStack(spacing: 12) {
                Text(rechargeResult?.addedSeconds ?? 0 > 0 ? "Flame refilled." : "Prayer ended.")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                
                if let result = rechargeResult {
                    if result.addedSeconds > 0 {
                        Text("Prayer added \(result.addedSeconds / 60) min.")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(BYSTheme.gold)
                    } else {
                        Text("No Flame added yet (minimum 1 min).")
                            .font(.headline)
                            .foregroundStyle(BYSTheme.textMuted)
                    }
                }
            }

            Spacer()

            VStack(spacing: 16) {
                BYSPrimaryButton(title: "Done", systemImage: "checkmark.circle.fill") {
                    dismiss()
                }
                
                secondaryAction(title: "Pray More", systemImage: "hands.sparkles.fill") {
                    resetPrayer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func secondaryAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(BYSTheme.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BYSTheme.border, lineWidth: 1))
            )
        }
        .buttonStyle(PressableScaleButtonStyle())
    }
    
    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startPrayer() {
        Task {
            await appState.screenTimeService.setProtectionEnabled(true)
            await appState.screenTimeService.reconcileShieldState()
            BYSFocusFlameStore.startPrayerSession()
            hasStarted = true
        }
    }
    
    private func finishPrayer() {
        rechargeResult = appState.endPrayerSession()
        isFinished = true
        
        if let result = rechargeResult, result.addedSeconds > 0 {
            BYSHaptics.success()
        }
    }
    
    private func resetPrayer() {
        elapsedSeconds = 0
        isFinished = false
        rechargeResult = nil
        startPrayer()
    }
}

#Preview {
    PrayerModeView()
        .environmentObject(BYSAppState())
}
