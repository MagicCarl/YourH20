import SwiftUI

struct WaveAnimationView: View {
    let progress: Double

    @State private var phase1: Double = 0
    @State private var phase2: Double = 0

    var body: some View {
        GeometryReader { _ in
            ZStack {
                WaveShape(progress: progress, waveHeight: 8, phase: phase2)
                    .fill(AppTheme.Colors.lightAqua.opacity(0.4))

                WaveShape(progress: progress, waveHeight: 10, phase: phase1)
                    .fill(AppTheme.Gradients.wave)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                phase1 = 1.0
            }
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                phase2 = 1.0
            }
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
    }
}
