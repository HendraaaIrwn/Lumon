import SwiftUI

struct ColorPickerView: View {
    let colors: [LumonColor]
    let isEnabled: Bool
    let onSelectColor: (LumonColor) -> Void

    var body: some View {
        HStack(spacing: 22) {
            ForEach(colors, id: \.self) { color in
                Button {
                    onSelectColor(color)
                } label: {
                    Circle()
                        .fill(color.swiftUIColor)
                        .frame(width: 48, height: 48)
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .shadow(color: color.swiftUIColor.opacity(0.25), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1 : 0.35)
                .accessibilityLabel("Choose \(color.accessibilityName)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Choose color")
    }
}
