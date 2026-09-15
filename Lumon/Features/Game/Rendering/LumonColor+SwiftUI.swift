import SwiftUI

extension LumonColor {
    var swiftUIColor: Color {
        switch self {
        case .red: .red
        case .yellow: .yellow
        case .blue: .blue
        case .black: .black
        }
    }

    var accessibilityName: String {
        rawValue.capitalized
    }
}
