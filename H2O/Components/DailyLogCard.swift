import SwiftUI

struct DailyLogCard: View {
    let log: DailyLog
    let goal: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.date, format: .dateTime.weekday(.wide))
                    .font(AppTheme.Fonts.headline())
                    .foregroundStyle(AppTheme.Colors.deepOcean)
                Text(log.date, format: .dateTime.month().day())
                    .font(AppTheme.Fonts.caption())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ProgressRingView(
                progress: log.progress(goal: goal),
                current: log.glassesConsumed,
                goal: goal,
                lineWidth: 6,
                showLabel: false
            )
            .frame(width: 44, height: 44)

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(log.totalOunces)) oz")
                    .font(AppTheme.Fonts.headline())
                    .foregroundStyle(AppTheme.Colors.deepOcean)
                Text("\(log.glassesConsumed)/\(goal)")
                    .font(AppTheme.Fonts.caption())
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60)
        }
        .cardStyle()
    }
}
