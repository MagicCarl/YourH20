import SwiftUI

struct WaterDropView: View {
    let size: CGFloat
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: size))
            .foregroundStyle(
                LinearGradient(
                    colors: [AppTheme.Colors.lightAqua, AppTheme.Colors.aqua],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .scaleEffect(isAnimating ? 1.1 : 0.95)
            .opacity(isAnimating ? 1.0 : 0.8)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}
