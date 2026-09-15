import SwiftUI

struct GameBoardView: View {
    let shapes: [PuzzleShape]
    let selectedShapeID: String?
    let feedbackEvent: GameFeedbackEvent?
    let onSelectShape: (String) -> Void

    var body: some View {
        GeometryReader { proxy in
            let mapper = CoordinateMapper(containerSize: proxy.size)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
                    .accessibilityHidden(true)

                ForEach(shapes) { shape in
                    PuzzleShapeView(
                        shape: shape,
                        isSelected: selectedShapeID == shape.id,
                        feedbackEvent: feedbackEvent,
                        onSelect: { onSelectShape(shape.id) }
                    )
                    .frame(width: mapper.size(for: shape).width, height: mapper.size(for: shape).height)
                    .position(mapper.position(for: shape.position))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
