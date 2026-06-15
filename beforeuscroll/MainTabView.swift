import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: BYSAppState

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Pause", systemImage: "pause.circle.fill")
                }

            BoundariesView()
                .tabItem {
                    Label("Boundaries", systemImage: "lock.shield.fill")
                }

            ScriptureView()
                .tabItem {
                    Label("Scripture", systemImage: "book.closed.fill")
                }

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
        .tint(BYSTheme.gold)
    }
}

#Preview {
    MainTabView()
        .environmentObject(BYSAppState())
}
