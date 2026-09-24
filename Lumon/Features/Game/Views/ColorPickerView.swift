import SwiftUI

struct ColorPickerView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    let colors: [LumonColor]
    let enabledColors: [LumonColor]
    let onSelectColor: (LumonColor) -> Void

    var body: some View {
        HStack(spacing: horizontalSizeClass == .regular ? LumonSpacing.lg : LumonSpacing.mdPlus) {
            ForEach(colors, id: \.self) { color in
                let isEnabled = enabledColors.contains(color)
                Button {
                    onSelectColor(color)
                } label: {
                    Circle()
                        .fill(color.swiftUIColor)
                        .frame(
                            width: horizontalSizeClass == .regular
                                ? LumonTouchTarget.colorButtonRegular
                                : LumonTouchTarget.colorButtonCompact,
                            height: horizontalSizeClass == .regular
                                ? LumonTouchTarget.colorButtonRegular
                                : LumonTouchTarget.colorButtonCompact
                        )
                        .overlay {
                            Circle().stroke(LumonPalette.ink, lineWidth: LumonStroke.medium)
                                .padding(-2)
                        }
                        .overlay {
                            Circle().stroke(LumonPalette.cream, lineWidth: LumonStroke.thin)
                                .padding(-6)
                        }
                        .overlay {
                            if differentiateWithoutColor {
                                Image(systemName: color.accessibilitySymbol)
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundStyle(LumonPalette.ink)
                                    .accessibilityHidden(true)
                            }
                        }
                }
                .buttonStyle(GameColorButtonStyle())
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1 : 0.4)
                .accessibilityLabel("Choose \(color.accessibilityName)")
            }
        }
        .padding(.vertical, LumonSpacing.smPlus)
        .frame(maxWidth: .infinity, minHeight: 80)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Choose a color")
    }
}

private struct GameColorButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(
                reduceMotion ? nil : .spring(duration: 0.18, bounce: 0.25),
                value: configuration.isPressed
            )
    }
}
