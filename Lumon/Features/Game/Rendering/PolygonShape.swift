import SwiftUI

struct PolygonShape: ShapeRenderer {
    nonisolated func path(in rect: CGRect, points: [NormalizedPoint]) -> Path {
        guard let firstPoint = points.first else { return Path() }

        return Path { path in
            path.move(to: map(firstPoint, into: rect))
            for point in points.dropFirst() {
                path.addLine(to: map(point, into: rect))
            }
            path.closeSubpath()
        }
    }

    nonisolated private func map(_ point: NormalizedPoint, into rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * point.x,
            y: rect.minY + rect.height * point.y
        )
    }
}
