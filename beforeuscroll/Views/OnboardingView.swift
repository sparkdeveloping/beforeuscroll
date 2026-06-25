import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @EnvironmentObject private var appState: BYSAppState
    
    @State private var page = 0
    @State private var selectedGoal: ScrollGoal?
    @State private var animateGlow = false
    
    private let pagesCount = 5 // Welcome, HowItWorks, Focus, Notifications, Ready

    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()
            ParallaxEmberBackground()
            
            VStack(spacing: 0) {
                topProgress
                    .padding(.top, 18)
                
                BYSParallaxPager(step: page) { selectedPage in
                    switch selectedPage {
                    case 0:
                        welcomePage
                    case 1:
                        howItWorksPage
                    case 2:
                        goalPickerPage
                    case 3:
                        notificationPermissionPage
                    default:
                        readyPage
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }
    
    private var topProgress: some View {
        HStack(spacing: 8) {
            ForEach(0..<pagesCount, id: \.self) { index in
                Capsule()
                    .fill(index <= page ? BYSTheme.gold : Color.white.opacity(0.12))
                    .frame(height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: page)
            }
        }
        .padding(.horizontal, 22)
    }
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            BYSBrandMark(size: .hero, showsGlow: true)
                .cardEntrance()
            
            VStack(spacing: 12) {
                Text("Scripture before the scroll.")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                    .multilineTextAlignment(.center)
                
                Text("A new way to guard your attention.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BYSTheme.textMuted)
            }
            .cardEntrance(delay: 0.2)
            
            Spacer()
            
            BYSPrimaryButton(title: "Get Started", systemImage: "arrow.right") {
                goToNextPage()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .cardEntrance(delay: 0.4)
        }
    }
    
    private var howItWorksPage: some View {
        VStack(spacing: 32) {
            BYSHeader(
                eyebrow: "How it works",
                title: "Recharge your Flame",
                subtitle: "Your Flame keeps protected apps open. When it burns out, they lock again."
            )
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                onboardingStep(number: "1", title: "Refill with Scripture", subtitle: "Answer questions to add intentional time.", delay: 0.1)
                onboardingStep(number: "2", title: "Keep it burning", subtitle: "Open your protected apps while the flame lasts.", delay: 0.2)
                onboardingStep(number: "3", title: "Protection Returns", subtitle: "Apps lock automatically when the flame is out.", delay: 0.3)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            BYSPrimaryButton(title: "Continue", systemImage: "arrow.right") {
                goToNextPage()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private var goalPickerPage: some View {
        VStack(spacing: 24) {
            BYSHeader(
                eyebrow: "Your focus",
                title: "Choose your focus",
                subtitle: "This determines which Scriptures will refill your Flame first."
            )
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(ScrollGoal.allCases.enumerated()), id: \.element.id) { index, goal in
                        goalButton(goal)
                            .cardEntrance(delay: Double(index) * 0.05)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            if selectedGoal != nil {
                BYSPrimaryButton(title: "Continue", systemImage: "arrow.right") {
                    goToNextPage()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("Select an option to continue")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BYSTheme.textFaint)
                    .padding(.bottom, 50)
            }
        }
    }
    
    private var notificationPermissionPage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            BYSBrandMark(size: .large, showsGlow: true)
                .cardEntrance()
            
            VStack(spacing: 16) {
                Text("Know when your Flame is low.")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                    .multilineTextAlignment(.center)
                
                Text("BeforeUScroll can remind you when intentional time is almost gone and when protection returns.")
                    .font(.headline)
                    .foregroundStyle(BYSTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            .cardEntrance(delay: 0.2)
            
            Spacer()
            
            VStack(spacing: 16) {
                BYSPrimaryButton(title: "Allow Notifications", systemImage: "bell.fill") {
                    requestNotifications()
                }
                
                Button("Not Now") {
                    goToNextPage()
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(BYSTheme.textMuted)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .cardEntrance(delay: 0.4)
        }
    }
    
    private var readyPage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            BYSBrandMark(size: .large, showsGlow: true)
                .cardEntrance()
            
            VStack(spacing: 12) {
                Text("You're ready.")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                
                Text("Protection is active. Recharge your Flame whenever you need intentional time.")
                    .font(.headline)
                    .foregroundStyle(BYSTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .cardEntrance(delay: 0.2)
            
            Spacer()
            
            BYSPrimaryButton(title: "Enter App", systemImage: "checkmark.circle.fill") {
                let goal = selectedGoal ?? .doomscrolling
                print("[BeforeUScroll][Onboarding] Enter App button tapped, selectedGoal:", goal.rawValue)
                appState.completeOnboarding(goal: goal)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .cardEntrance(delay: 0.4)
        }
    }
    
    private func onboardingStep(number: String, title: String, subtitle: String, delay: Double) -> some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.headline.weight(.black))
                .foregroundStyle(Color.black)
                .frame(width: 36, height: 36)
                .background(Circle().fill(BYSTheme.gold))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundStyle(BYSTheme.text)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BYSTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.06)))
        .cardEntrance(delay: delay)
    }
    
    private func goalButton(_ goal: ScrollGoal) -> some View {
        Button {
            BYSHaptics.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                selectedGoal = goal
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selectedGoal == goal ? BYSTheme.gold : BYSTheme.textFaint)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline.bold())
                        .foregroundStyle(BYSTheme.text)
                    
                    Text(goal.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(BYSTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selectedGoal == goal ? BYSTheme.gold.opacity(0.12) : Color.white.opacity(0.05))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(selectedGoal == goal ? BYSTheme.gold.opacity(0.5) : BYSTheme.border, lineWidth: 1))
            )
            .scaleEffect(selectedGoal == goal ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private func goToNextPage() {
        BYSHaptics.lightTap()
        page += 1
    }
    
    // Uses the async requestAuthorization API with @MainActor to avoid concurrency
    // violations when calling @MainActor-isolated appState methods from a background callback.
    private func requestNotifications() {
        Task { @MainActor in
            do {
                _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                // Authorization request failed — continue gracefully; user can enable later in Settings
            }
            appState.markNotificationPermissionAsked()
            goToNextPage()
        }
    }
}
