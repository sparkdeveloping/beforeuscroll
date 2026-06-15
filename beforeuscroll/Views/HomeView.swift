import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
#endif

#if canImport(UIKit)
import UIKit
#endif

struct HomeView: View {
    @EnvironmentObject private var appState: BYSAppState
    @ObservedObject private var screenTimeService = ScreenTimeService.shared

    @State private var showPicker = false
    @State private var showSettings = false
    @State private var showPremium = false
    @State private var showVerseCheck = false
    @State private var isRequestingAccess = false
    @State private var setupError: String?
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentVerse: Verse {
        VerseLibrary.verse(for: appState.settings.selectedGoal)
    }

    private var homeMode: HomeMode {
        if screenTimeService.isTemporarilyUnlocked {
            return .unlocked
        }

        if !screenTimeService.isScreenTimeAuthorized || screenTimeService.currentSelectionCount == 0 {
            return .setup
        }

        return .active
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                Group {
                    switch homeMode {
                    case .setup:
                        setupHomeView
                    case .active:
                        activeHomeView
                    case .unlocked:
                        unlockedHomeView
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.985)))
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .animation(.spring(response: 0.42, dampingFraction: 0.88), value: homeMode)
            .onReceive(timer) { _ in
                appState.refreshProtectionStatus()
            }
            .sheet(isPresented: $showVerseCheck) {
                PauseFlowView(trigger: .voluntary, presetVerse: currentVerse)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
                    .environmentObject(appState)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showPremium) {
                PaywallView()
                    .environmentObject(appState)
            }
            #if canImport(FamilyControls)
            .familyActivityPicker(isPresented: $showPicker, selection: $screenTimeService.selection)
            #endif
            .onChange(of: showPicker) { isPresented in
                guard !isPresented else { return }
                Task {
                    let previousCount = screenTimeService.currentSelectionCount
                    await screenTimeService.handleSelectionChangedOrPickerDismissed()
                    appState.refreshProtectionStatus()
                    if previousCount == 0 && screenTimeService.currentSelectionCount > 0 && screenTimeService.shieldCurrentlyApplied {
                        successHaptic()
                    }
                }
            }
            .task {
                await screenTimeService.reconcileShieldState()
                appState.refreshProtectionStatus()
            }
        }
    }

    private var background: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()

            LinearGradient(
                colors: [
                    BYSTheme.backgroundDeep,
                    BYSTheme.background,
                    Color(hex: "#101018")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [BYSTheme.gold.opacity(0.16), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }

    private var setupHomeView: some View {
        VStack(spacing: 0) {
            compactTopBar(showStatus: false)
                .padding(.horizontal, 20)
                .padding(.top, 18)

            Spacer(minLength: 24)

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(BYSTheme.warmGradient)
                        .frame(width: 74, height: 74)
                        .shadow(color: BYSTheme.gold.opacity(0.26), radius: 18, x: 0, y: 10)

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(Color.black)
                }
                .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text("Protect your first app")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(BYSTheme.text)
                        .multilineTextAlignment(.center)

                    Text("Choose one distracting app. Before opening it, you’ll pause with Scripture.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(BYSTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 10) {
                    trustPoint("checkmark.circle.fill", "You choose the apps")
                    trustPoint("eye.slash.fill", "BeforeUScroll cannot read your screen")
                    trustPoint("slider.horizontal.3", "You can change this anytime")
                }

                if let setupError {
                    Text(setupError)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(BYSTheme.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 24)

            BYSPrimaryButton(title: isRequestingAccess ? "Requesting Access..." : "Set Up Protection", systemImage: "lock.shield.fill") {
                handleSetupProtectionTapped()
            }
            .disabled(isRequestingAccess)
            .opacity(isRequestingAccess ? 0.7 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
    }

    private var activeHomeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                compactTopBar(showStatus: true)
                currentVerseCard
                protectionCard
                statsRow
                recentChecks
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
    }

    private var unlockedHomeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                compactTopBar(showStatus: false)

                BYSGlassCard(padding: 22, cornerRadius: 24) {
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.10), lineWidth: 10)
                                .frame(width: 124, height: 124)

                            Circle()
                                .trim(from: 0, to: countdownProgress)
                                .stroke(BYSTheme.gold, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 124, height: 124)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.35), value: screenTimeService.remainingUnlockSeconds)

                            VStack(spacing: 2) {
                                Text(unlockCountdownText)
                                    .font(.system(size: 27, weight: .black, design: .rounded))
                                    .foregroundStyle(BYSTheme.text)

                                Text("left")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(BYSTheme.textFaint)
                            }
                        }

                        VStack(spacing: 7) {
                            Text("Unlocked for \(unlockMinuteText)")
                                .font(.system(size: 29, weight: .black, design: .rounded))
                                .foregroundStyle(BYSTheme.text)

                            Text("Protection returns automatically.")
                                .font(.headline)
                                .foregroundStyle(BYSTheme.textMuted)
                        }
                        .multilineTextAlignment(.center)

                        BYSSecondaryButton(title: "Lock Again Now", systemImage: "lock.fill") {
                            appState.lockAgainNow()
                            successHaptic()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                compactVersePreview
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
    }

    private func compactTopBar(showStatus: Bool) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("BeforeUScroll")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)

                if showStatus {
                    statusPill
                }
            }

            Spacer()

            BYSIconButton(systemImage: "crown.fill", badgeText: appState.settings.isPremium ? nil : "PRO") {
                showPremium = true
            }
            .frame(width: 44, height: 44)

            BYSIconButton(systemImage: "gearshape.fill") {
                showSettings = true
            }
            .frame(width: 44, height: 44)
        }
    }

    private var statusPill: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(screenTimeService.isProtectionEnabled ? BYSTheme.green : BYSTheme.textFaint)
                .frame(width: 7, height: 7)

            Text(screenTimeService.isProtectionEnabled ? "Protected" : "Protection Off")
                .font(.caption.weight(.black))
                .foregroundStyle(screenTimeService.isProtectionEnabled ? BYSTheme.green : BYSTheme.textFaint)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.08)))
        .accessibilityLabel(screenTimeService.isProtectionEnabled ? "Protected" : "Protection Off")
    }

    private var currentVerseCard: some View {
        BYSCard(padding: 0, cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Current Verse", systemImage: "book.closed.fill")
                            .font(.caption.weight(.black))
                            .foregroundStyle(BYSTheme.gold)

                        Spacer()

                        Text(currentVerse.reference)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(BYSTheme.textMuted)
                    }

                    Text(currentVerse.text)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(BYSTheme.text)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .background(BYSTheme.heroGradient)

                BYSPrimaryButton(title: "Start Verse Check", systemImage: "arrow.right.circle.fill") {
                    showVerseCheck = true
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    private var protectionCard: some View {
        BYSCard(padding: 16, cornerRadius: 22) {
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: screenTimeService.isProtectionEnabled ? "checkmark.shield.fill" : "shield.slash.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(screenTimeService.isProtectionEnabled ? BYSTheme.green : BYSTheme.textFaint)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white.opacity(0.08)))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Protected apps")
                            .font(.headline.bold())
                            .foregroundStyle(BYSTheme.text)

                        Text("\(screenTimeService.currentSelectionCount) selections")
                            .font(.subheadline)
                            .foregroundStyle(BYSTheme.textMuted)
                    }

                    Spacer()

                    Toggle("Protection", isOn: Binding(
                        get: { screenTimeService.isProtectionEnabled },
                        set: { newValue in
                            appState.setProtectionEnabled(newValue)
                            if newValue {
                                successHaptic()
                            }
                        }
                    ))
                    .labelsHidden()
                    .tint(BYSTheme.gold)
                }

                Button {
                    handleEditAppsTapped()
                } label: {
                    Label("Edit Apps", systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(BYSTheme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statTile(value: "\(appState.completedTodayCount)", label: "Checks today")
            statTile(value: "\(appState.avoidedUnlocksToday)", label: "Stayed locked")
            statTile(value: "\(screenTimeService.currentSelectionCount)", label: "Protected apps")
        }
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(BYSTheme.text)

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BYSTheme.textFaint)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 78)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BYSTheme.border, lineWidth: 1))
        )
    }

    private var recentChecks: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent checks")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(BYSTheme.textMuted)

            if appState.sessions.isEmpty {
                Text("Completed verse checks will appear here.")
                    .font(.footnote)
                    .foregroundStyle(BYSTheme.textFaint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(appState.sessions.prefix(3)) { session in
                    HStack {
                        Label(session.decision == .stayedLocked ? "Stayed locked" : "Unlocked", systemImage: session.decision == .stayedLocked ? "checkmark.shield.fill" : "lock.open.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(BYSTheme.textMuted)

                        Spacer()

                        Text(session.startedAt, style: .time)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(BYSTheme.textFaint)
                    }
                    .padding(.vertical, 9)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white.opacity(0.045)))
                }
            }
        }
        .padding(.top, 2)
    }

    private var compactVersePreview: some View {
        BYSCard(padding: 16, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Verse")
                    .font(.caption.weight(.black))
                    .foregroundStyle(BYSTheme.gold)

                Text(currentVerse.text)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BYSTheme.textMuted)
                    .lineLimit(4)

                Text(currentVerse.reference)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BYSTheme.textFaint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func trustPoint(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(BYSTheme.gold)
                .frame(width: 22)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BYSTheme.textMuted)

            Spacer()
        }
        .frame(maxWidth: 330)
    }

    private var unlockCountdownText: String {
        let seconds = screenTimeService.remainingUnlockSeconds
        let minutesPart = seconds / 60
        let secondsPart = seconds % 60
        return String(format: "%d:%02d", minutesPart, secondsPart)
    }

    private var unlockMinuteText: String {
        let minutes = max(1, Int(ceil(Double(screenTimeService.remainingUnlockSeconds) / 60.0)))
        return "\(minutes) min"
    }

    private var countdownProgress: CGFloat {
        guard let endDate = screenTimeService.unlockEndDate else { return 0 }
        let total = max(1, endDate.timeIntervalSince(Date().addingTimeInterval(-TimeInterval(screenTimeService.remainingUnlockSeconds))))
        return CGFloat(max(0, min(1, Double(screenTimeService.remainingUnlockSeconds) / total)))
    }

    private func handleSetupProtectionTapped() {
        guard !isRequestingAccess else { return }
        setupError = nil

        Task {
            if !screenTimeService.isScreenTimeAuthorized {
                isRequestingAccess = true
                let granted = await screenTimeService.requestAuthorization()
                isRequestingAccess = false

                guard granted else {
                    setupError = "Screen Time access is required to protect apps."
                    return
                }
            }

            showPicker = true
        }
    }

    private func handleEditAppsTapped() {
        if screenTimeService.isScreenTimeAuthorized {
            showPicker = true
        } else {
            handleSetupProtectionTapped()
        }
    }

    private func successHaptic() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}

private enum HomeMode: Equatable {
    case setup
    case active
    case unlocked
}

private struct SettingsSheet: View {
    @EnvironmentObject private var appState: BYSAppState
    @State private var versionTapCount = 0
    @State private var showDeveloperControls = false
    @State private var isRestoring = false

    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    BYSHeader(
                        eyebrow: "Settings",
                        title: "BeforeUScroll",
                        subtitle: "Manage Premium, purchases, privacy, and support."
                    )

                    BYSCard {
                        VStack(spacing: 0) {
                            Link(destination: AppLinks.privacy) {
                                settingsRow("Privacy Policy", icon: "hand.raised.fill", trailing: "Open")
                            }

                            Divider().background(BYSTheme.border)

                            Link(destination: AppLinks.terms) {
                                settingsRow("Terms of Service", icon: "doc.text.fill", trailing: "Open")
                            }

                            Divider().background(BYSTheme.border)

                            Link(destination: AppLinks.support) {
                                settingsRow("Support", icon: "questionmark.circle.fill", trailing: "Open")
                            }

                            Divider().background(BYSTheme.border)

                            Button {
                                Task {
                                    isRestoring = true
                                    let restored = await appState.storeKitService.restorePurchases()
                                    appState.settings.isPremium = restored
                                    isRestoring = false
                                }
                            } label: {
                                settingsRow(isRestoring ? "Restoring..." : "Restore Purchases", icon: "arrow.clockwise", trailing: "")
                            }
                            .buttonStyle(.plain)
                            .disabled(isRestoring)
                        }
                    }

                    BYSCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(appState.settings.isPremium ? "Premium Active" : "Premium")
                                .font(.title3.bold())
                                .foregroundStyle(BYSTheme.text)

                            Text(appState.settings.isPremium ? "Thank you for supporting the app." : "Unlock unlimited protected apps and longer unlocks.")
                                .font(.subheadline)
                                .foregroundStyle(BYSTheme.textMuted)

                            if !appState.settings.isPremium {
                                BYSPrimaryButton(title: "View Premium", systemImage: "crown.fill") {
                                    appState.isPaywallPresented = true
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text("Version 1.0")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BYSTheme.textFaint)
                        .onTapGesture {
                            versionTapCount += 1
                            if versionTapCount >= 7 {
                                showDeveloperControls.toggle()
                            }
                        }

                    if showDeveloperControls {
                        developerControls
                    }
                }
                .padding(20)
            }
        }
        .sheet(isPresented: $appState.isPaywallPresented) {
            PaywallView()
                .environmentObject(appState)
        }
    }

    private func settingsRow(_ title: String, icon: String, trailing: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(BYSTheme.gold)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(BYSTheme.text)

            Spacer()

            if !trailing.isEmpty {
                Text(trailing)
                    .font(.caption.bold())
                    .foregroundStyle(BYSTheme.textFaint)
            }
        }
        .padding(.vertical, 14)
    }

    private var developerControls: some View {
        BYSCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Developer Controls")
                    .font(.headline.bold())
                    .foregroundStyle(BYSTheme.red)

                BYSSecondaryButton(title: "Test Verse Check", systemImage: "link") {
                    appState.startPause(trigger: .shield)
                }

                BYSSecondaryButton(title: "Clear Shield", systemImage: "shield.slash.fill") {
                    Task {
                        await appState.screenTimeService.clearShield(userDisabled: true)
                        appState.refreshProtectionStatus()
                    }
                }

                BYSSecondaryButton(title: "Reset Onboarding", systemImage: "arrow.counterclockwise") {
                    appState.settings.hasCompletedOnboarding = false
                }

                BYSSecondaryButton(title: "Clear Check History", systemImage: "trash") {
                    appState.sessions.removeAll()
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(BYSAppState())
}
