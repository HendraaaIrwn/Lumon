import SwiftUI

struct LumonLivesView: View {
    let lives: Int

    var body: some View {
        HStack(spacing: LumonSpacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                LifeSymbol()
                    .fill(LumonPalette.red.opacity(index < lives ? 1 : 0.3))
                    .frame(width: 20, height: 20)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(lives) of 3 lives remaining")
    }
}

/// Six broad arms echo the geometric life mark in the reference artwork.
nonisolated private struct LifeSymbol: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGPoint] = [
            CGPoint(x: 0.33, y: 0), CGPoint(x: 0.66, y: 0),
            CGPoint(x: 0.665, y: 0.255), CGPoint(x: 0.90, y: 0.17),
            CGPoint(x: 1, y: 0.50), CGPoint(x: 0.77, y: 0.585),
            CGPoint(x: 0.91, y: 0.77), CGPoint(x: 0.65, y: 0.96),
            CGPoint(x: 0.51, y: 0.78), CGPoint(x: 0.37, y: 1),
            CGPoint(x: 0.10, y: 0.80), CGPoint(x: 0.24, y: 0.60),
            CGPoint(x: 0, y: 0.53), CGPoint(x: 0.09, y: 0.19),
            CGPoint(x: 0.33, y: 0.26)
        ]

        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: CGPoint(x: rect.minX + first.x * rect.width, y: rect.minY + first.y * rect.height))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: rect.minX + point.x * rect.width, y: rect.minY + point.y * rect.height))
        }
        path.closeSubpath()
        return path
    }
}

struct LumonHintsView: View {
    let hints: Int

    var body: some View {
        HStack(spacing: LumonSpacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 15, weight: .bold))
            Text("\(hints)")
                .lumonTextStyle(.label)
        }
        .foregroundStyle(LumonPalette.orange)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(hints) hints remaining")
    }
}

struct LumonPanel<Content: View>: View {
    @ViewBuilder let content: Content
    let stroke: Color

    init(stroke: Color = LumonPalette.cream.opacity(0.35), @ViewBuilder content: () -> Content) {
        self.stroke = stroke
        self.content = content()
    }

    var body: some View {
        content
            .padding(LumonSpacing.md)
            .background(LumonPalette.ink.opacity(0.78), in: RoundedRectangle(cornerRadius: LumonRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: LumonRadius.medium)
                    .stroke(stroke, lineWidth: LumonStroke.thin)
            }
    }
}
