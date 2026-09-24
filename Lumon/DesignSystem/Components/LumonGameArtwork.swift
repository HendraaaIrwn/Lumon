import SwiftUI

/// A static poster border that leaves the board and scrolling controls on solid teal.
struct LumonGameArtwork: View {
    var body: some View {
        Canvas { context, size in
            // Gameplay content has 24 pt horizontal padding. Keep every accent
            // inside a narrower rail, even after rotation or on a short viewport.
            let rail = min(18, size.width * 0.045)
            let bounds = CGRect(origin: .zero, size: size)
            var perimeter = Path(bounds)
            perimeter.addRect(bounds.insetBy(dx: rail, dy: rail))
            context.clip(to: perimeter, style: FillStyle(eoFill: true))

            // Upper corners: a warm disc and an offset blue block.
            disc(in: &context, at: CGPoint(x: 2, y: 48), diameter: 34, color: LumonPalette.orange)
            block(in: &context, at: CGPoint(x: 52, y: 2), size: CGSize(width: 22, height: 10),
                  angle: -18, color: LumonPalette.cream)
            block(in: &context, at: CGPoint(x: size.width - 3, y: 82), size: CGSize(width: 28, height: 28),
                  angle: 24, color: LumonPalette.blue)
            disc(in: &context, at: CGPoint(x: size.width - 54, y: 1), diameter: 18, color: LumonPalette.yellow)

            // Sparse side accents stay outside the entire playable column.
            block(in: &context, at: CGPoint(x: rail / 2, y: size.height * 0.31), size: CGSize(width: 8, height: 8),
                  angle: 45, color: LumonPalette.earth)
            disc(in: &context, at: CGPoint(x: size.width - rail / 2, y: size.height * 0.39),
                 diameter: 7, color: LumonPalette.cream)
            notchedBlock(in: &context, at: CGPoint(x: -7, y: size.height * 0.59))
            block(in: &context, at: CGPoint(x: size.width - 5, y: size.height * 0.69), size: CGSize(width: 9, height: 23),
                  angle: -16, color: LumonPalette.yellow)

            // Unequal lower clusters frame the controls without sitting behind them.
            disc(in: &context, at: CGPoint(x: 0, y: size.height - 54), diameter: 30, color: LumonPalette.mutedBlue)
            block(in: &context, at: CGPoint(x: 46, y: size.height - 2), size: CGSize(width: 17, height: 17),
                  angle: 28, color: LumonPalette.coral)
            disc(in: &context, at: CGPoint(x: size.width - 3, y: size.height - 76),
                 diameter: 26, color: LumonPalette.orange)
            block(in: &context, at: CGPoint(x: size.width - 43, y: size.height - 4), size: CGSize(width: 9, height: 9),
                  angle: 45, color: LumonPalette.cream)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private func disc(in context: inout GraphicsContext, at center: CGPoint, diameter: CGFloat, color: Color) {
        let rect = CGRect(x: center.x - diameter / 2, y: center.y - diameter / 2,
                          width: diameter, height: diameter)
        context.fill(Path(ellipseIn: rect), with: .color(color))
    }

    private func block(
        in context: inout GraphicsContext,
        at center: CGPoint,
        size: CGSize,
        angle: Double,
        color: Color
    ) {
        context.drawLayer { layer in
            layer.translateBy(x: center.x, y: center.y)
            layer.rotate(by: .degrees(angle))
            let rect = CGRect(x: -size.width / 2, y: -size.height / 2,
                              width: size.width, height: size.height)
            layer.fill(Path(rect), with: .color(color))
        }
    }

    private func notchedBlock(in context: inout GraphicsContext, at origin: CGPoint) {
        // A square with a rectangular bite: the same cutout language as the home artwork.
        var path = Path(CGRect(x: origin.x, y: origin.y, width: 23, height: 28))
        path.addRect(CGRect(x: origin.x + 11, y: origin.y + 8, width: 12, height: 12))
        context.fill(path, with: .color(LumonPalette.ink), style: FillStyle(eoFill: true))
    }
}

#Preview("Portrait gameplay background") {
    LumonScreenBackground(variant: .game) {
        Color.clear
    }
    .preferredColorScheme(.dark)
}
