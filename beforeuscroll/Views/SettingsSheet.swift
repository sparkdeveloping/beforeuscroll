import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject private var appState: BYSAppState
    @Environment(\.dismiss) private var dismiss
    @State private var presentedURL: BYSLinkSheetURL?

    var body: some View {
        NavigationStack {
            ZStack {
                BYSTheme.background.ignoresSafeArea()
                
                List {
                    Section {
                        VStack(spacing: 12) {
                            BYSBrandMark(size: .medium, showsGlow: true, showsBackground: true)
                            
                            VStack(spacing: 4) {
                                Text("BeforeUScroll")
                                    .font(.headline.bold())
                                Text("Version 1.0.0")
                                    .font(.caption)
                                    .foregroundStyle(BYSTheme.textFaint)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        Toggle("Web Guard", isOn: Binding(
                            get: { appState.settings.isWebGuardEnabled },
                            set: { appState.setWebGuardEnabled($0) }
                        ))
                        .tint(BYSTheme.gold)
                        .disabled(!appState.settings.isPremium)
                        
                        if appState.settings.isWebGuardEnabled {
                            Toggle("Adult Content Filter", isOn: Binding(
                                get: { appState.settings.isAdultFilterEnabled },
                                set: { appState.setAdultFilterEnabled($0) }
                            ))
                            .tint(BYSTheme.gold)
                            .padding(.leading, 16)
                        }
                    } header: {
                        HStack {
                            Text("Web Guard")
                            if !appState.settings.isPremium {
                                Text("PREMIUM").font(.caption2.bold()).foregroundStyle(BYSTheme.gold)
                            }
                        }
                    } footer: {
                        Text("Blocks adult websites and selected web domains where iOS supports filtering. Shield apps entirely when in-app content cannot be filtered.")
                    }

                    Section {
                        Toggle("Protection Enabled", isOn: Binding(
                            get: { appState.screenTimeService.isProtectionEnabled },
                            set: { appState.setProtectionEnabled($0) }
                        ))
                        .tint(BYSTheme.gold)
                    } header: {
                        Text("Protection")
                    }
                    
                    Section {
                        NavigationLink("Selected Apps") {
                            #if canImport(FamilyControls)
                            Text("Edit apps in Home screen") // FamilyActivityPicker is best handled from a direct button
                            #endif
                        }
                        
                        Picker("Focus", selection: Binding(
                            get: { appState.settings.selectedGoal },
                            set: { appState.setSelectedGoal($0) }
                        )) {
                            ForEach(ScrollGoal.allCases) { goal in
                                Text(goal.title).tag(goal)
                            }
                        }
                    } header: {
                        Text("Focus")
                    }
                    
                    Section {
                        Button {
                            presentedURL = BYSLinkSheetURL(url: AppLinks.privacy)
                        } label: {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                        }
                        Button {
                            presentedURL = BYSLinkSheetURL(url: AppLinks.terms)
                        } label: {
                            Label("Terms & Conditions", systemImage: "doc.text.fill")
                        }
                        Link(destination: AppLinks.support) {
                            Label("Support", systemImage: "questionmark.circle.fill")
                        }
                    } header: {
                        Text("Legal & Support")
                    }
                    
                    Section {
                        Button("Restore Purchases") {
                            Task {
                                await appState.syncPremiumStatus()
                            }
                        }
                    } header: {
                        Text("Subscription")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .foregroundStyle(BYSTheme.text)
            .sheet(item: $presentedURL) { item in
                SafariWebSheet(url: item.url)
            }
        }
    }
}
