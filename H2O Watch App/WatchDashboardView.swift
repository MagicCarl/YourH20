import SwiftUI
import Combine
import WatchKit

struct WatchDashboardView: View {
    @EnvironmentObject var viewModel: WatchHydrationViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.iceBlue, lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: viewModel.todayProgress)
                        .stroke(
                            AngularGradient(
                                colors: [AppTheme.Colors.aqua, AppTheme.Colors.splashAccent,
                                         AppTheme.Colors.teal, AppTheme.Colors.aqua],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: viewModel.todayProgress)

                    VStack(spacing: 2) {
                        Text("\(viewModel.glassesConsumedToday)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.aqua)
                        Text("of \(viewModel.dailyGoalGlasses)")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.teal)
                    }
                }
                .frame(width: 120, height: 120)

                // Goal met indicator
                if viewModel.isGoalMet {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Goal reached!")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.splashAccent)
                }

                // Log Glass Button
                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    viewModel.logGlass()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 16))
                        Text("+1 Glass")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.aqua, AppTheme.Colors.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                // Ounces detail
                Text("\(Int(viewModel.todayTotalOunces)) / \(Int(viewModel.dailyGoalOunces)) oz")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)

                // Remaining glasses
                if !viewModel.isGoalMet {
                    Text("\(viewModel.glassesRemaining) to go")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.teal)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("YourH20")
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.checkForDayChange()
            }
        }
    }
}
