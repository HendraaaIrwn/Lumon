import Foundation

/// Device-independent board coordinate in normalized 0...1 space
/// (TASK-006 / TDD §5). Converts to screen space in Phase 3 via the
/// coordinate mapper, so the same level works on iPhone and iPad.
nonisolated struct NormalizedPoint: Codable, Hashable, Sendable {
    /// Horizontal position: 0 = left edge, 1 = right edge.
    let x: Double
    /// Vertical position: 0 = top edge, 1 = bottom edge.
    let y: Double

    static let center = NormalizedPoint(x: 0.5, y: 0.5)
}
