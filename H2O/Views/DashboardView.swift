import SwiftUI
import Combine

struct DashboardView: View {
    @ObservedObject var viewModel: HydrationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Date header
                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(AppTheme.Fonts.headline())
                    .foregroundStyle(AppTheme.Colors.deepOcean)
                    .padding(.top, AppTheme.Spacing.small)

                // Wave container
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppTheme.Colors.foamWhite)
                        .frame(height: 300)

                    WaveAnimationView(progress: viewModel.todayProgress)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .frame(height: 300)

                    // Overlay text
                    VStack(spacing: 8) {
                        Text("\(viewModel.glassesConsumedToday)")
                            .font(AppTheme.Fonts.huge())
                            .foregroundStyle(AppTheme.Colors.deepOcean)
                            .shadow(color: .white.opacity(0.6), radius: 4)
                        Text("of \(viewModel.dailyGoalGlasses) glasses")
                            .font(AppTheme.Fonts.title())
                            .foregroundStyle(Color(hex: "BF360C"))
                            .shadow(color: .white.opacity(0.7), radius: 3)
                        Text("\(Int(viewModel.todayLog.totalOunces)) / \(Int(viewModel.dailyGoalOunces)) oz")
                            .font(AppTheme.Fonts.body())
                            .foregroundStyle(Color(hex: "BF360C"))
                            .shadow(color: .white.opacity(0.6), radius: 2)
                    }
                }
                .shadow(color: AppTheme.Colors.oceanBlue.opacity(0.2), radius: 12, y: 6)
                .padding(.horizontal)

                // Goal met banner
                if viewModel.isGoalMet {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Daily goal reached!")
                    }
                    .font(AppTheme.Fonts.headline())
                    .foregroundStyle(AppTheme.Colors.splashAccent)
                    .padding()
                    .background(AppTheme.Colors.splashAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.scale.combined(with: .opacity))
                }

                // Log button
                GlassButton {
                    withAnimation(.spring(response: 0.5)) {
                        viewModel.logGlass()
                    }
                }

                // Glasses remaining
                if !viewModel.isGoalMet {
                    Text("\(viewModel.glassesRemaining) glasses to go")
                        .font(AppTheme.Fonts.body())
                        .foregroundStyle(AppTheme.Colors.teal)
                }

                // Undo button
                if viewModel.glassesConsumedToday > 0 {
                    Button(action: {
                        withAnimation(.spring(response: 0.5)) {
                            viewModel.undoLastGlass()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Undo last glass")
                        }
                        .font(AppTheme.Fonts.caption())
                        .foregroundStyle(AppTheme.Colors.oceanBlue.opacity(0.7))
                    }
                }

                // Today's entries
                if !viewModel.todayLog.entries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Intake")
                            .font(AppTheme.Fonts.headline())
                            .foregroundStyle(AppTheme.Colors.deepOcean)

                        ForEach(viewModel.todayLog.entries.reversed()) { entry in
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundStyle(AppTheme.Colors.aqua)
                                    .font(.system(size: 14))
                                Text("8 oz glass")
                                    .font(AppTheme.Fonts.body())
                                Spacer()
                                Text(entry.timestamp, format: .dateTime.hour().minute())
                                    .font(AppTheme.Fonts.caption())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal)
                }

                Spacer(minLength: AppTheme.Spacing.extraLarge)
            }
        }
        .appBackground()
    }
}
