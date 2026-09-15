import Foundation

nonisolated struct Level: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let metadata: LevelMetadata
    let availableColors: [LumonColor]
    let shapes: [PuzzleShape]
    /// Authoritative hidden answer used for immediate validation and hints.
    let solution: [String: LumonColor]
}
