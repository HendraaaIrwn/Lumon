import SwiftUI

enum LumonButtonKind {
    case primary
    case secondary
    case destructive

    var foreground: Color {
        switch self {
        case .primary: LumonPalette.background
        case .secondary: LumonPalette.cream
        case .destructive: LumonPalette.coral
        }
    }

    var fill: Color {
        switch self {
        case .primary: LumonPalette.cream
        case .secondary, .destructive: .clear
        }
    }

    var stroke: Color {
        switch self {
        case .primary: .clear
        case .secondary: LumonPalette.cream
        case .destructive: LumonPalette.coral
        }
    }
}

struct LumonButtonStyle: ButtonStyle {
    let kind: LumonButtonKind
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lumonTextStyle(.label, color: kind.foreground, tracking: 0.8)
            .frame(maxWidth: .infinity)
            .frame(minHeight: LumonTouchTarget.primaryButtonHeight)
            .padding(.horizontal, LumonSpacing.md)
            .background(kind.fill, in: RoundedRectangle(cornerRadius: LumonRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: LumonRadius.medium)
                    .stroke(kind.stroke, lineWidth: LumonStroke.thin)
            }
            .contentShape(RoundedRectangle(cornerRadius: LumonRadius.medium))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(reduceMotion ? nil : LumonMotion.tap, value: configuration.isPressed)
    }
}

struct LumonHomePrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: LumonSpacing.smPlus) {
            Image(systemName: "play.fill")
                .font(.system(size: 19, weight: .black))
                .foregroundStyle(LumonPalette.orange)
                .accessibilityHidden(true)

            configuration.label
                .textCase(.uppercase)
                .font(.custom("TiltWarp-Regular", size: 23, relativeTo: .title2))
                .tracking(1.2)
                .foregroundStyle(LumonPalette.background)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 60)
        .padding(.horizontal, LumonSpacing.md)
        .background(LumonPalette.cream, in: RoundedRectangle(cornerRadius: LumonRadius.medium))
        .contentShape(RoundedRectangle(cornerRadius: LumonRadius.medium))
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
        .animation(reduceMotion ? nil : LumonMotion.tap, value: configuration.isPressed)
    }
}

struct LumonHomeSecondaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textCase(.uppercase)
            .lumonTextStyle(.label, color: LumonPalette.cream, tracking: 0.4)
            .labelStyle(.titleAndIcon)
            .shadow(color: LumonPalette.ink.opacity(0.85), radius: 3)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(reduceMotion ? nil : LumonMotion.tap, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == LumonButtonStyle {
    static var lumonPrimary: LumonButtonStyle { LumonButtonStyle(kind: .primary) }
    static var lumonSecondary: LumonButtonStyle { LumonButtonStyle(kind: .secondary) }
    static var lumonDestructive: LumonButtonStyle { LumonButtonStyle(kind: .destructive) }
    static var lumonHomePrimary: LumonHomePrimaryButtonStyle { LumonHomePrimaryButtonStyle() }
    static var lumonHomeSecondary: LumonHomeSecondaryButtonStyle { LumonHomeSecondaryButtonStyle() }
}
