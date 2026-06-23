//
//  beforeuscrollApp.swift
//  beforeuscroll
//
//  Created by Denzel Nyatsanza on 5/20/26.
//

import SwiftUI

@main
struct beforeuscrollApp: App {
    @StateObject private var appState = BYSAppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .onOpenURL { url in
                    appState.handleDeepLink(url)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        Task {
                            await appState.handleAppBecameActive()
                        }
                    }
                }
                .task {
                    await appState.configure()
                }
                .preferredColorScheme(.dark)
        }
    }
}

