import SwiftUI
import Combine

@main
struct H2OWatchApp: App {
    @StateObject private var viewModel = WatchHydrationViewModel()

    var body: some Scene {
        WindowGroup {
            WatchDashboardView()
                .environmentObject(viewModel)
        }
    }
}
