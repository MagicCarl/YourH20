import SwiftUI

struct WaveShape: Shape {
    var progress: Double
    var waveHeight: Double
    var phase: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(progress, phase) }
        set {
            progress = newValue.first
            phase = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let yOffset = height * (1 - progress)
        let wavelength = width / 1.5

        path.move(to: CGPoint(x: 0, y: yOffset))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + phase) * 2 * .pi)
            let y = yOffset + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}
