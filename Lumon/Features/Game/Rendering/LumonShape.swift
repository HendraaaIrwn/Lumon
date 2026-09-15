import SwiftUI

struct LumonShape: Shape {
    let type: ShapeType
    let points: [NormalizedPoint]
    let rotation: Double

    func path(in rect: CGRect) -> Path {
        let renderer: any ShapeRenderer = switch type {
        case .triangle: TriangleShape()
        case .square: SquareShape()
        case .diamond: DiamondShape()
        case .circle: CircleShape()
        case .polygon: PolygonShape()
        }

        let path = renderer.path(in: rect, points: points)
        guard rotation != 0 else { return path }

        let radians = rotation * .pi / 180
        let transform = CGAffineTransform(translationX: rect.midX, y: rect.midY)
            .rotated(by: radians)
            .translatedBy(x: -rect.midX, y: -rect.midY)
        return path.applying(transform)
    }
}
