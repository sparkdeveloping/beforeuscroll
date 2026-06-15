import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: BYSAppState

    var body: some View {
        HomeView()
            .environmentObject(appState)
    }
}

#Preview {
    MainTabView()
        .environmentObject(BYSAppState())
}
