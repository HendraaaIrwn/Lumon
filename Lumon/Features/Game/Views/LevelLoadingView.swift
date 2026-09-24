import SwiftUI

struct LevelLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: LumonRadius.small).fill(LumonPalette.coral)
                    .frame(width: 30, height: 30).offset(x: -22)
                Circle().fill(LumonPalette.orange).frame(width: 30, height: 30)
                LumonShape(type: .triangle, points: [], rotation: 0).fill(LumonPalette.blue)
                    .frame(width: 34, height: 34).offset(x: 24)
            }
            .rotationEffect(reduceMotion ? .zero : .degrees(isAnimating ? 360 : 0))
            .animation(
                reduceMotion ? nil : .linear(duration: 1.4).repeatForever(autoreverses: false),
                value: isAnimating
            )
            Text("Loading level…")
                .lumonTextStyle(.label, color: LumonPalette.cream.opacity(0.78))
        }
        .onAppear { isAnimating = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading level")
    }
}
