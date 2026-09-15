import SwiftUI

struct CoordinateMapper {
    let containerSize: CGSize

    var canvasFrame: CGRect {
        let side = min(containerSize.width, containerSize.height)
        return CGRect(
            x: (containerSize.width - side) / 2,
            y: (containerSize.height - side) / 2,
            width: side,
            height: side
        )
    }

    func position(for point: NormalizedPoint) -> CGPoint {
        CGPoint(
            x: canvasFrame.minX + canvasFrame.width * point.x,
            y: canvasFrame.minY + canvasFrame.height * point.y
        )
    }

    func size(for shape: PuzzleShape) -> CGSize {
        let width = canvasFrame.width * shape.size.width
        let height = canvasFrame.height * shape.size.height

        if shape.type == .square || shape.type == .circle {
            let side = min(width, height)
            return CGSize(width: side, height: side)
        }
        return CGSize(width: width, height: height)
    }
}
