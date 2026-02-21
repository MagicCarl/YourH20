import SwiftUI
import Combine

struct HistoryView: View {
    @ObservedObject var viewModel: HydrationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Header
                Text("History")
                    .font(AppTheme.Fonts.largeTitle())
                    .foregroundStyle(AppTheme.Colors.deepOcean)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, AppTheme.Spacing.small)

                // Weekly chart
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Text("This Week")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)

                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(viewModel.weeklyHistory) { log in
                            VStack(spacing: 4) {
                                Text("\(log.glassesConsumed)")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.Colors.oceanBlue)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        log.progress(goal: viewModel.dailyGoalGlasses) >= 1.0
                                        ? AppTheme.Gradients.button
                                        : LinearGradient(
                                            colors: [AppTheme.Colors.iceBlue, AppTheme.Colors.lightAqua.opacity(0.5)],
                                            startPoint: .bottom, endPoint: .top
                                        )
                                    )
                                    .frame(
                                        height: max(8, CGFloat(log.progress(goal: viewModel.dailyGoalGlasses)) * 100)
                                    )

                                Text(log.date, format: .dateTime.weekday(.narrow))
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 140, alignment: .bottom)

                    // Goal line label
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.Colors.splashAccent)
                            .frame(width: 8, height: 8)
                        Text("Goal: \(viewModel.dailyGoalGlasses) glasses")
                            .font(AppTheme.Fonts.caption())
                            .foregroundStyle(.secondary)
                    }
                }
                .cardStyle()
                .padding(.horizontal)

                // All days
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text("All Days")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)
                        .padding(.horizontal)

                    if viewModel.sortedHistory.isEmpty {
                        VStack(spacing: AppTheme.Spacing.medium) {
                            Image(systemName: "drop")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.Colors.iceBlue)
                            Text("No history yet")
                                .font(AppTheme.Fonts.body())
                                .foregroundStyle(.secondary)
                            Text("Start logging water to see your history here")
                                .font(AppTheme.Fonts.caption())
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.extraLarge)
                    } else {
                        ForEach(viewModel.sortedHistory) { log in
                            DailyLogCard(log: log, goal: viewModel.dailyGoalGlasses)
                                .padding(.horizontal)
                        }
                    }
                }

                Spacer(minLength: AppTheme.Spacing.extraLarge)
            }
        }
        .appBackground()
    }
}
