import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let deepOcean = Color(hex: "0A2463")
        static let oceanBlue = Color(hex: "1B4D8C")
        static let teal = Color(hex: "1B8A8C")
        static let aqua = Color(hex: "36C9C6")
        static let lightAqua = Color(hex: "7FEFEF")
        static let foamWhite = Color(hex: "E8F8F8")
        static let iceBlue = Color(hex: "D4F1F9")
        static let splashAccent = Color(hex: "00D4AA")
        static let coralPop = Color(hex: "FF6B6B")
    }

    // MARK: - Gradients
    enum Gradients {
        static let background = LinearGradient(
            colors: [Colors.iceBlue, Colors.foamWhite],
            startPoint: .top, endPoint: .bottom
        )
        static let wave = LinearGradient(
            colors: [Colors.aqua, Colors.oceanBlue],
            startPoint: .top, endPoint: .bottom
        )
        static let button = LinearGradient(
            colors: [Colors.aqua, Colors.teal],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        static let header = LinearGradient(
            colors: [Colors.deepOcean, Colors.oceanBlue],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        static let progressRing = AngularGradient(
            colors: [Colors.aqua, Colors.splashAccent, Colors.teal, Colors.aqua],
            center: .center
        )
    }

    // MARK: - Fonts
    enum Fonts {
        static func largeTitle() -> Font { .system(size: 34, weight: .bold, design: .rounded) }
        static func title() -> Font { .system(size: 24, weight: .semibold, design: .rounded) }
        static func headline() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
        static func body() -> Font { .system(size: 17, weight: .regular, design: .rounded) }
        static func caption() -> Font { .system(size: 13, weight: .regular, design: .rounded) }
        static func huge() -> Font { .system(size: 64, weight: .bold, design: .rounded) }
    }

    // MARK: - Spacing
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
