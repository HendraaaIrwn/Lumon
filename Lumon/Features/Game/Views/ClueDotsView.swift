import SwiftUI

struct ClueDotsView: View {
    let clues: [ColorClue]
    let shape: LumonShape
    let differentiateWithoutColor: Bool

    var body: some View {
        GeometryReader { proxy in
            let layout = HintCircleLayoutEngine().layout(
                type: shape.type,
                points: shape.points,
                clueCount: clues.count,
                renderedWidth: proxy.size.width,
                renderedHeight: proxy.size.height
            )

            if let layout {
                ZStack {
                    ForEach(clues.indices, id: \.self) { index in
                        let position = layout.centers[index]
                        Circle()
                            .fill(clues[index].color.swiftUIColor)
                            .overlay {
                                Circle()
                                    .strokeBorder(
                                        LumonPalette.cream,
                                        lineWidth: max(1, layout.diameter * 0.10)
                                    )
                            }
                            .overlay {
                                if differentiateWithoutColor {
                                    Image(systemName: clues[index].color.accessibilitySymbol)
                                        .font(.system(size: max(5, layout.diameter * 0.42), weight: .black))
                                        .foregroundStyle(LumonPalette.ink)
                                        .accessibilityHidden(true)
                                }
                            }
                            .frame(width: layout.diameter, height: layout.diameter)
                            .position(
                                x: proxy.size.width * position.x,
                                y: proxy.size.height * position.y
                            )
                    }
                }
                .rotationEffect(.degrees(shape.rotation))
            }
        }
        .accessibilityHidden(true)
    }
}
