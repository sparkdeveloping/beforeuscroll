import SwiftUI
import Combine

#if canImport(FamilyControls)
import FamilyControls
#endif

struct HomeView: View {
    @EnvironmentObject private var appState: BYSAppState
    @ObservedObject private var screenTimeService = ScreenTimeService.shared

    @State private var showPicker = false
    @State private var showSettings = false
    @State private var showPremium = false
    @State private var showVerseCheck = false
    @State private var showPrayerMode = false
    @State private var showThemePicker = false
    @State private var statsMode: StatsMode = .allTime
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private enum StatsMode: String, CaseIterable, Identifiable {
        case today = "Today"
        case allTime = "All Time"
        var id: String { rawValue }
    }

    private var flame: BYSFocusFlameSnapshot {
        appState.focusFlame
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BYSTheme.background.ignoresSafeArea()
                
                // Hero Gradient
                RadialGradient(
                    colors: [appState.currentFlameTheme.glow.opacity(0.12), .clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 400
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    Spacer()

                    // Center Hero: The Flame
                    VStack(spacing: 24) {
                        ZStack(alignment: .bottom) {
                            BYSFlameView(
                                progress: flame.fillPercentage,
                                isBurning: flame.isFlameActive,
                                theme: appState.currentFlameTheme,
                                showFace: !flame.isFlameActive
                            )
                            .subtleGlow(radius: 40, opacity: flame.isFlameActive ? 0.3 : 0.1)
                            
                            timeOverlay
                                .padding(.bottom, 20)
                        }
                        
                        VStack(spacing: 8) {
                            Text(appState.protectionStatus.title)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(BYSTheme.text)
                            
                            Text(appState.protectionStatus.subtitle)
                                .font(.headline)
                                .foregroundStyle(BYSTheme.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .lineSpacing(4)
                        }
                    }

                    Spacer()
                    
                    VStack(spacing: 12) {
                        statsPanel
                        nextVersePreview
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Action Area
                    VStack(spacing: 16) {
                        primaryActionButton
                        
                        rechargeRow
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .onReceive(timer) { _ in
                appState.refreshProtectionStatus()
            }
            .sheet(isPresented: $showVerseCheck) {
                PauseFlowView(trigger: .voluntary, goal: appState.settings.selectedGoal)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showPremium) {
                PaywallView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showThemePicker) {
                FlameThemePicker()
                    .environmentObject(appState)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showPrayerMode) {
                PrayerModeView()
                    .environmentObject(appState)
            }
            #if canImport(FamilyControls)
            .familyActivityPicker(isPresented: $showPicker, selection: $screenTimeService.selection)
            #endif
            .onChange(of: showPicker) { _, isPresented in
                if !isPresented {
                    Task {
                        await screenTimeService.handleSelectionChangedOrPickerDismissed()
                        appState.refreshProtectionStatus()
                    }
                }
            }
            .task {
                await screenTimeService.reconcileShieldState()
                appState.refreshProtectionStatus()
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            BYSBrandMark(size: .small, showsGlow: false)
                .cardEntrance()

            VStack(alignment: .leading, spacing: 2) {
                Text("BeforeUScroll")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                
                protectionPill
            }

            Spacer()

            HStack(spacing: 8) {
                BYSIconButton(systemImage: "crown.fill", badgeText: appState.settings.isPremium ? nil : "PRO") {
                    showPremium = true
                }
                .scaleEffect(0.8)

                BYSIconButton(systemImage: "paintpalette.fill") {
                    showThemePicker = true
                }
                .scaleEffect(0.8)

                BYSIconButton(systemImage: "gearshape.fill") {
                    showSettings = true
                }
                .scaleEffect(0.8)
            }
        }
    }

    private var protectionPill: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(screenTimeService.isProtectionEnabled ? BYSTheme.green : BYSTheme.textFaint)
                .frame(width: 7, height: 7)
            
            Text(screenTimeService.isProtectionEnabled ? "Protection Active" : "Protection Off")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(screenTimeService.isProtectionEnabled ? BYSTheme.green : BYSTheme.textFaint)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.06)))
    }

    private var timeOverlay: some View {
        VStack(spacing: 2) {
            if flame.isFlameActive {
                Text(formatRemainingTime(flame.flameRemainingSeconds))
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .monospacedDigit()
                Text("left")
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .opacity(0.6)
            } else {
                Text("\(flame.flameRemainingSeconds / 60) / \(flame.maxFlameSeconds / 60) min")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("ready")
                    .font(.system(size: 9, weight: .black))
                    .textCase(.uppercase)
                    .opacity(0.5)
            }
        }
        .foregroundStyle(BYSTheme.text)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }

    private var statsPanel: some View {
        BYSGlassCard(padding: 12, cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text(statsMode.rawValue)
                        .font(.caption.weight(.black))
                        .foregroundStyle(BYSTheme.gold)
                        .tracking(1.0)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            statsMode = (statsMode == .today) ? .allTime : .today
                        }
                    } label: {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(BYSTheme.textFaint)
                            .padding(6)
                            .background(Circle().fill(Color.white.opacity(0.05)))
                    }
                }
                
                HStack(spacing: 0) {
                    statItem(
                        value: "\(statsMode == .today ? appState.stats.todayScriptureCount : appState.stats.allTimeScriptureCount)",
                        label: "Scriptures",
                        systemImage: "book.closed.fill"
                    )
                    Divider().frame(height: 20).padding(.horizontal, 8)
                    statItem(
                        value: "\(statsMode == .today ? appState.stats.todayScriptureSeconds / 60 : appState.stats.allTimeScriptureSeconds / 60)m",
                        label: "In Word",
                        systemImage: "clock.fill"
                    )
                    Divider().frame(height: 20).padding(.horizontal, 8)
                    statItem(
                        value: "\(statsMode == .today ? appState.stats.todayPrayerCount : appState.stats.allTimePrayerCount)",
                        label: "Prayers",
                        systemImage: "hands.sparkles.fill"
                    )
                    Divider().frame(height: 20).padding(.horizontal, 8)
                    statItem(
                        value: "\(statsMode == .today ? appState.stats.todayPrayerSeconds / 60 : appState.stats.allTimePrayerSeconds / 60)m",
                        label: "In Prayer",
                        systemImage: "timer"
                    )
                }
            }
        }
    }

    private func statItem(value: String, label: String, systemImage: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 9))
                    .foregroundStyle(appState.currentFlameTheme.primary)
                Text(value)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(BYSTheme.textFaint)
        }
        .frame(maxWidth: .infinity)
    }

    private var nextVersePreview: some View {
        BYSGlassCard(padding: 16, cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Next Verse")
                        .font(.caption.weight(.black))
                        .foregroundStyle(BYSTheme.gold)
                        .tracking(1.0)
                    Spacer()
                    Image(systemName: "book.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(BYSTheme.textFaint)
                }
                
                let verse = VerseLibrary.currentVerseOfStudy(for: appState.settings.selectedGoal)
                Text(verse.text)
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(BYSTheme.text)
                    .lineLimit(2)
                    .lineSpacing(2)
                
                Text(verse.reference)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(appState.currentFlameTheme.secondary)
            }
        }
    }

    @ViewBuilder
    private var primaryActionButton: some View {
        switch appState.protectionStatus {
        case .needsAuthorization:
            BYSPrimaryButton(title: "Allow Access", systemImage: "lock.shield.fill") {
                Task {
                    _ = await screenTimeService.requestAuthorization()
                    appState.refreshProtectionStatus()
                }
            }
        case .needsSelection:
            BYSPrimaryButton(title: "Choose Apps", systemImage: "checklist") {
                showPicker = true
            }
        case .flameEmpty, .flameBurning, .flameFading, .flameFull:
            HStack(spacing: 12) {
                let scriptureAdd = appState.settings.isPremium ? 15 : 10
                BYSPrimaryButton(title: "Read +\(scriptureAdd)", systemImage: "book.closed.fill") {
                    appState.prepareForRecharge()
                    showVerseCheck = true
                }
                
                let prayerRate = appState.settings.isPremium ? 2 : 1
                BYSPrimaryButton(title: "Pray +\(prayerRate)/min", systemImage: "hands.sparkles.fill") {
                    appState.prepareForRecharge()
                    showPrayerMode = true
                }
            }
        case .notProtected:
            BYSPrimaryButton(title: "Turn Protection On", systemImage: "shield.fill") {
                appState.setProtectionEnabled(true)
            }
        }
    }

    private var rechargeRow: some View {
        HStack(spacing: 12) {
            if appState.protectionStatus != .needsAuthorization && appState.protectionStatus != .needsSelection {
                secondaryAction(title: "Edit Apps", systemImage: "slider.horizontal.3") {
                    showPicker = true
                }
                
                if flame.isFlameActive {
                    secondaryAction(title: "Extinguish", systemImage: "flame.slash.fill") {
                        appState.extinguishFlame()
                    }
                }
            } else {
                secondaryAction(title: "Settings", systemImage: "gearshape.fill") {
                    showSettings = true
                }
            }
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
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BYSTheme.border, lineWidth: 1))
            )
        }
        .buttonStyle(PressableScaleButtonStyle())
    }

    private func formatRemainingTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
