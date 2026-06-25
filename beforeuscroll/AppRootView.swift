import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: BYSAppState

    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()

            if appState.settings.hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appState.settings.hasCompletedOnboarding)
        .sheet(item: $appState.activePauseTrigger) { active in
            PauseFlowView(trigger: active.trigger, goal: appState.settings.selectedGoal)
                .environmentObject(appState)
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(BYSAppState())
}
