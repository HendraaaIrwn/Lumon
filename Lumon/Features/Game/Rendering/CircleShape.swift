import SwiftUI

struct CircleShape: ShapeRenderer {
    nonisolated func path(in rect: CGRect, points: [NormalizedPoint]) -> Path {
        Path(ellipseIn: rect)
    }
}
