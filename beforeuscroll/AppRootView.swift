import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: BYSAppState

    var body: some View {
        Group {
            if appState.settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .background(BYSTheme.background.ignoresSafeArea())
        .sheet(item: $appState.activePauseTrigger) { active in
            PauseFlowView(
                trigger: active.trigger,
                presetVerse: VerseLibrary.verse(for: appState.settings.selectedGoal)
            )
            .environmentObject(appState)
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(BYSAppState())
}
