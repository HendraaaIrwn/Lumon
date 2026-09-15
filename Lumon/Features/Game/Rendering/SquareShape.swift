import SwiftUI

struct SquareShape: ShapeRenderer {
    nonisolated func path(in rect: CGRect, points: [NormalizedPoint]) -> Path {
        Path(rect)
    }
}
