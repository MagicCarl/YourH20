import SwiftUI
import Combine

@main
struct YourH20WatchApp: App {
    @StateObject private var viewModel = WatchHydrationViewModel()

    var body: some Scene {
        WindowGroup {
            WatchDashboardView()
                .environmentObject(viewModel)
        }
    }
}
