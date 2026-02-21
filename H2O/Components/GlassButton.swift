import SwiftUI

struct GlassButton: View {
    let action: () -> Void

    @State private var showRipple = false

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            withAnimation(.easeOut(duration: 0.3)) {
                showRipple = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showRipple = false
            }

            action()
        }) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.aqua.opacity(showRipple ? 0 : 0.3))
                    .scaleEffect(showRipple ? 2.0 : 1.0)
                    .frame(width: 80, height: 80)
                    .animation(.easeOut(duration: 0.3), value: showRipple)

                Circle()
                    .fill(AppTheme.Gradients.button)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppTheme.Colors.aqua.opacity(0.4), radius: 10, y: 4)

                VStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 24))
                    Text("+1")
                        .font(AppTheme.Fonts.caption())
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}
