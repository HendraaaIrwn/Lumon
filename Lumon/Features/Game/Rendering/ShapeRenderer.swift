import SwiftUI

protocol ShapeRenderer {
    nonisolated func path(in rect: CGRect, points: [NormalizedPoint]) -> Path
}
