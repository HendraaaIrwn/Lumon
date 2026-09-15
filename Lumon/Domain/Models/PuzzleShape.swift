import Foundation

/// One puzzle piece (TASK-007 / TDD §6). Pure Foundation value type —
/// no UI imports; the view layer adapts it in later phases.
nonisolated struct PuzzleShape: Identifiable, Codable, Hashable, Sendable {
    /// Stable identity used by neighbor references and clues.
    let id: String
    let type: ShapeType
    /// Position in normalized 0...1 space (TDD §5).
    let position: NormalizedPoint
    /// Rotation in degrees.
    let rotation: Double
    /// Width and height relative to the square board canvas.
    let size: NormalizedSize
    /// Local 0...1 vertices used only when `type` is `.polygon`.
    let points: [NormalizedPoint]
    /// Currently revealed color; `nil` while the shape is still hidden
    /// (all shapes start black, GDD §1). Correct answers become locked
    /// later in the game flow (PRS §13).
    var color: LumonColor?
    /// IDs of directly touching shapes (PRS §4 — edges/corners contact only).
    let neighbors: [String]
    /// Hidden color hints, shown when the player selects the shape (PRS §7).
    let clues: [ColorClue]

    /// Flat keys matching the level JSON format (TDD §8): the position is
    /// stored as top-level `x`/`y`. `rotation`, `neighbors`, `clues` and
    /// `color` are optional so hand-written levels can omit them.
    private enum CodingKeys: String, CodingKey {
        case id, type, color, neighbors, clues
        case x, y, rotation, size, points
    }

    init(
        id: String,
        type: ShapeType,
        position: NormalizedPoint,
        rotation: Double = 0,
        size: NormalizedSize = .standard,
        points: [NormalizedPoint] = [],
        color: LumonColor? = nil,
        neighbors: [String] = [],
        clues: [ColorClue] = []
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.size = size
        self.points = points
        self.color = color
        self.neighbors = neighbors
        self.clues = clues
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(ShapeType.self, forKey: .type)
        position = NormalizedPoint(
            x: try container.decode(Double.self, forKey: .x),
            y: try container.decode(Double.self, forKey: .y)
        )
        rotation = try container.decodeIfPresent(Double.self, forKey: .rotation) ?? 0
        size = try container.decodeIfPresent(NormalizedSize.self, forKey: .size) ?? .standard
        points = try container.decodeIfPresent([NormalizedPoint].self, forKey: .points) ?? []
        color = try container.decodeIfPresent(LumonColor.self, forKey: .color)
        neighbors = try container.decodeIfPresent([String].self, forKey: .neighbors) ?? []
        clues = try container.decodeIfPresent([ColorClue].self, forKey: .clues) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(position.x, forKey: .x)
        try container.encode(position.y, forKey: .y)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(size, forKey: .size)
        if !points.isEmpty {
            try container.encode(points, forKey: .points)
        }
        try container.encodeIfPresent(color, forKey: .color)
        try container.encode(neighbors, forKey: .neighbors)
        try container.encode(clues, forKey: .clues)
    }
}
