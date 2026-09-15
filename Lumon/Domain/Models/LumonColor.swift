import Foundation

/// Player-facing color vocabulary (TASK-004 / TDD §7, PRS §2).
/// `black` represents the unrevealed state of a shape and is never a
/// player choice; the per-level player palette (red/yellow/blue) is
/// constrained by the level schema arriving in Phase 2.
nonisolated enum LumonColor: String, Codable, CaseIterable, Sendable {
    case red
    case yellow
    case blue
    case black
}
