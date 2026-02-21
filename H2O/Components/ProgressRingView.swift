import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let current: Int
    let goal: Int
    var lineWidth: CGFloat = 12
    var showLabel: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.Colors.iceBlue, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppTheme.Gradients.progressRing,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)

            if showLabel {
                VStack(spacing: 4) {
                    Text("\(current)")
                        .font(AppTheme.Fonts.huge())
                        .foregroundStyle(AppTheme.Colors.deepOcean)
                    Text("of \(goal) glasses")
                        .font(AppTheme.Fonts.caption())
                        .foregroundStyle(AppTheme.Colors.teal)
                }
            }
        }
    }
}
