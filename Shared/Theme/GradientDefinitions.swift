import SwiftUI

struct BackgroundGradientModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Gradients.background.ignoresSafeArea())
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.medium)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppTheme.Colors.oceanBlue.opacity(0.1), radius: 8, y: 4)
    }
}

extension View {
    func appBackground() -> some View {
        modifier(BackgroundGradientModifier())
    }

    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
