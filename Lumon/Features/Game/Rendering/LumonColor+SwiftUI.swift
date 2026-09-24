import SwiftUI

extension LumonColor {
    var swiftUIColor: Color {
        switch self {
        case .red: LumonPalette.red
        case .yellow: LumonPalette.yellow
        case .blue: LumonPalette.blue
        case .black: LumonPalette.ink
        }
    }

    var accessibilityName: String {
        rawValue.capitalized
    }

    var accessibilitySymbol: String {
        switch self {
        case .red: "triangle.fill"
        case .yellow: "circle.fill"
        case .blue: "square.fill"
        case .black: "xmark"
        }
    }
}
