import SwiftUI

/// A visual-only completion treatment. It walks the already-authored neighbor
/// lists in deterministic order and draws a cream outline over each connected
/// shape. Gameplay state is never mutated by this view.
struct CompletionPropagationOverlay: View {
    let shapes: [PuzzleShape]
    let originID: String?
    let trigger: UUID?
    let reduceMotion: Bool

    @State private var visibleShapeIDs: Set<String> = []

    var body: some View {
        GeometryReader { proxy in
            let mapper = CoordinateMapper(containerSize: proxy.size)

            ZStack {
                ForEach(shapes) { shape in
                    let isVisible = visibleShapeIDs.contains(shape.id)
                    LumonShape(type: shape.type, points: shape.points, rotation: shape.rotation)
                        .stroke(
                            LumonPalette.cream.opacity(isVisible ? 0.92 : 0),
                            style: StrokeStyle(lineWidth: LumonStroke.medium, lineJoin: .round)
                        )
                        .frame(width: mapper.size(for: shape).width, height: mapper.size(for: shape).height)
                        .position(mapper.position(for: shape.position))
                        .scaleEffect(isVisible ? 1.04 : 0.98)
                        .animation(
                            reduceMotion ? nil : .easeOut(duration: 0.24),
                            value: isVisible
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task(id: trigger) {
            await animatePropagation()
        }
    }

    private func animatePropagation() async {
        guard trigger != nil else {
            visibleShapeIDs = []
            return
        }

        let orderedIDs = connectedOrder()
        guard !orderedIDs.isEmpty else { return }

        visibleShapeIDs = []

        if reduceMotion {
            visibleShapeIDs = []
            return
        }

        let stepMilliseconds = max(20, 600 / max(1, orderedIDs.count))
        for shapeID in orderedIDs {
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.18)) {
                visibleShapeIDs.insert(shapeID)
            }
            try? await Task.sleep(for: .milliseconds(stepMilliseconds))
        }

        try? await Task.sleep(for: .milliseconds(110))
        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.16)) {
            visibleShapeIDs = []
        }
    }

    private func connectedOrder() -> [String] {
        guard let originID else { return shapes.map(\.id) }

        let byID = Dictionary(uniqueKeysWithValues: shapes.map { ($0.id, $0) })
        var visited: Set<String> = []
        var queue = [originID]
        var result: [String] = []

        while !queue.isEmpty {
            let currentID = queue.removeFirst()
            guard visited.insert(currentID).inserted else { continue }
            guard let shape = byID[currentID] else { continue }

            result.append(currentID)
            for neighborID in shape.neighbors where !visited.contains(neighborID) {
                queue.append(neighborID)
            }
        }

        // A malformed or intentionally disconnected level should still get a
        // complete visual treatment rather than leaving shapes unhighlighted.
        result.append(contentsOf: shapes.map(\.id).filter { !visited.contains($0) })
        return result
    }
}
