//
//  Your H20App.swift
//  Your H20
//
//  Created by Carl Andrews on 2/20/26.
//

import SwiftUI
import Combine
import UserNotifications

@main
struct YourH20App: App {
    @StateObject private var viewModel = HydrationViewModel()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        _ = PhoneConnectivityService.shared

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
