import SwiftUI

struct GameBoardView: View {
    let shapes: [PuzzleShape]
    let selectedShapeID: String?
    let revealedClueShapeIDs: Set<String>
    let selectableShapeIDs: Set<String>?
    let tutorialHighlightedShapeIDs: Set<String>
    let feedbackEvent: GameFeedbackEvent?
    let onSelectShape: (String) -> Void
    let completionTrigger: UUID?
    let reduceMotion: Bool
    let visibleShapeIDs: Set<String>?

    init(
        shapes: [PuzzleShape],
        selectedShapeID: String?,
        revealedClueShapeIDs: Set<String>,
        selectableShapeIDs: Set<String>?,
        tutorialHighlightedShapeIDs: Set<String>,
        feedbackEvent: GameFeedbackEvent?,
        onSelectShape: @escaping (String) -> Void,
        completionTrigger: UUID? = nil,
        reduceMotion: Bool = false,
        visibleShapeIDs: Set<String>? = nil
    ) {
        self.shapes = shapes
        self.selectedShapeID = selectedShapeID
        self.revealedClueShapeIDs = revealedClueShapeIDs
        self.selectableShapeIDs = selectableShapeIDs
        self.tutorialHighlightedShapeIDs = tutorialHighlightedShapeIDs
        self.feedbackEvent = feedbackEvent
        self.onSelectShape = onSelectShape
        self.completionTrigger = completionTrigger
        self.reduceMotion = reduceMotion
        self.visibleShapeIDs = visibleShapeIDs
    }

    var body: some View {
        GeometryReader { proxy in
            let mapper = CoordinateMapper(containerSize: proxy.size)

            ZStack {
                ForEach(shapes) { shape in
                    let isVisible = reduceMotion || (visibleShapeIDs?.contains(shape.id) ?? true)
                    PuzzleShapeView(
                        shape: shape,
                        isSelected: selectedShapeID == shape.id,
                        areCluesVisible: revealedClueShapeIDs.contains(shape.id),
                        isEnabled: selectableShapeIDs?.contains(shape.id) ?? true,
                        isTutorialTarget: tutorialHighlightedShapeIDs.contains(shape.id),
                        feedbackEvent: feedbackEvent,
                        onSelect: { onSelectShape(shape.id) }
                    )
                    .frame(width: mapper.size(for: shape).width, height: mapper.size(for: shape).height)
                    .position(mapper.position(for: shape.position))
                    .opacity(isVisible ? 1 : 0)
                    .allowsHitTesting(isVisible)
                    .accessibilityHidden(!isVisible)
                }

                CompletionPropagationOverlay(
                    shapes: shapes,
                    originID: feedbackEvent?.shapeID,
                    trigger: completionTrigger,
                    reduceMotion: reduceMotion
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
