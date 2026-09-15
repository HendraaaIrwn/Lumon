import Foundation

/// One hidden color hint (PRS §5). A shape's clues describe the colors of
/// its *neighboring* shapes — never the shape's own color.
/// Minimal form shipped early (with TASK-007) because `PuzzleShape` cannot
/// compile without it; full clue semantics land in Phase 5 (TASK-019).
nonisolated struct ColorClue: Codable, Hashable, Sendable {
    /// ID of the neighboring shape this clue describes.
    let neighborID: String
    /// The neighbor's expected color.
    let color: LumonColor
 
     /// JSON key is `neighbor` per the level format (TDD §8), while Swift
     /// naming keeps `neighborID` as the property name.
     private enum CodingKeys: String, CodingKey {
         case neighborID = "neighbor"
         case color
     }
}
