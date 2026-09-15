import Foundation

/// MVP shape vocabulary (TASK-005).
/// Union across the design docs: triangle/square/polygon (task list),
/// diamond (TDD §4), circle (GDD §3 / PRS §2).
/// Shape identity never determines color (PRS §2).
nonisolated enum ShapeType: String, Codable, CaseIterable, Sendable {
    case triangle
    case square
    case diamond
    case circle
    /// Custom-points shape; its points arrive with the level schema (Phase 2)
    /// and renderer (Phase 3).
    case polygon
}
