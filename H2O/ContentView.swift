//
//  ContentView.swift
//  H2O
//
//  Created by Carl Andrews on 2/20/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var viewModel: HydrationViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if viewModel.hasCompletedOnboarding {
                TabView {
                    DashboardView(viewModel: viewModel)
                        .tabItem {
                            Label("Today", systemImage: "drop.fill")
                        }

                    HistoryView(viewModel: viewModel)
                        .tabItem {
                            Label("History", systemImage: "chart.bar.fill")
                        }

                    SettingsView(viewModel: viewModel)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                }
                .tint(AppTheme.Colors.aqua)
            } else {
                OnboardingView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.hasCompletedOnboarding)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.checkForDayChange()
            }
        }
    }
}
