import SwiftUI

enum LumonBackgroundVariant {
    case home
    case standard
    case game
}

struct LumonScreenBackground<Content: View>: View {
    let variant: LumonBackgroundVariant
    @ViewBuilder let content: Content

    init(
        variant: LumonBackgroundVariant = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LumonPalette.background
                    .ignoresSafeArea()

                decoration(in: proxy.size)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func decoration(in size: CGSize) -> some View {
        switch variant {
        case .home:
            LumonHomeArtwork()
        case .game:
            LumonGameArtwork()
        case .standard:
            standardDecoration(in: size)
        }
    }

    @ViewBuilder
    private func standardDecoration(in size: CGSize) -> some View {
        let compact = size.width < 500
        let opacity = 0.18

        Circle()
            .fill(LumonPalette.orange.opacity(opacity))
            .frame(width: compact ? 94 : 160, height: compact ? 94 : 160)
            .position(x: size.width * 0.10, y: size.height * 0.16)

        Rectangle()
            .fill(LumonPalette.blue.opacity(opacity))
            .frame(width: compact ? 74 : 120, height: compact ? 74 : 120)
            .rotationEffect(.degrees(18))
            .position(x: size.width * 0.88, y: size.height * 0.24)

        TriangleDecoration()
            .fill(LumonPalette.coral.opacity(opacity))
            .frame(width: compact ? 92 : 150, height: compact ? 86 : 140)
            .rotationEffect(.degrees(-12))
            .position(x: size.width * 0.90, y: size.height * 0.84)

        Rectangle()
            .fill(LumonPalette.cream.opacity(opacity * 0.75))
            .frame(width: compact ? 38 : 64, height: compact ? 38 : 64)
            .rotationEffect(.degrees(45))
            .position(x: size.width * 0.08, y: size.height * 0.84)
    }
}

private nonisolated struct TriangleDecoration: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
