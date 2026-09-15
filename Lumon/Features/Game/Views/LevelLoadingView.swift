import SwiftUI

struct LevelLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 7).fill(.red)
                    .frame(width: 30, height: 30).offset(x: -22)
                Circle().fill(.yellow).frame(width: 30, height: 30)
                LumonShape(type: .triangle, points: [], rotation: 0).fill(.blue)
                    .frame(width: 34, height: 34).offset(x: 24)
            }
            .rotationEffect(reduceMotion ? .zero : .degrees(isAnimating ? 360 : 0))
            .animation(
                reduceMotion ? nil : .linear(duration: 1.4).repeatForever(autoreverses: false),
                value: isAnimating
            )
            Text("Loading level…").font(.headline).foregroundStyle(.secondary)
        }
        .onAppear { isAnimating = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading level")
    }
}
