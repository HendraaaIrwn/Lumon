import SwiftUI

enum LumonTextStyle {
    case displayXL
    case display
    case title1
    case title2
    case body
    case label
    case caption

    var baseSize: CGFloat {
        switch self {
        case .displayXL: 52
        case .display: 40
        case .title1: 32
        case .title2: 24
        case .body: 17
        case .label: 16
        case .caption: 14
        }
    }

    var fontName: String {
        switch self {
        case .displayXL, .display, .title1, .title2:
            "TiltWarp-Regular"
        case .body, .caption:
            "Outfit-Thin_Regular"
        case .label:
            "Outfit-Thin_SemiBold"
        }
    }

    var relativeTextStyle: Font.TextStyle {
        switch self {
        case .displayXL, .display: .largeTitle
        case .title1: .title
        case .title2: .title2
        case .body: .body
        case .label: .callout
        case .caption: .footnote
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .body: 4
        case .caption: 3
        default: 0
        }
    }
}

struct LumonTypographyModifier: ViewModifier {
    let style: LumonTextStyle
    let color: Color
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.custom(style.fontName, size: style.baseSize, relativeTo: style.relativeTextStyle))
            .tracking(tracking)
            .lineSpacing(style.lineSpacing)
            .foregroundStyle(color)
    }
}

extension View {
    func lumonTextStyle(
        _ style: LumonTextStyle,
        color: Color = LumonPalette.cream,
        tracking: CGFloat = 0
    ) -> some View {
        modifier(LumonTypographyModifier(style: style, color: color, tracking: tracking))
    }
}
