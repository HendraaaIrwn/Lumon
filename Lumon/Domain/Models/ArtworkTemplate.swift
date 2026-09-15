import Foundation

nonisolated struct ArtworkTemplate: Codable, Hashable, Sendable {
    let id: String
    let availableColors: [LumonColor]
    let shapes: [ArtworkShape]
}

nonisolated struct ArtworkShape: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let type: ShapeType
    let position: NormalizedPoint
    let rotation: Double
    let size: NormalizedSize
    let points: [NormalizedPoint]
    let neighbors: [String]

    init(
        id: String,
        type: ShapeType,
        position: NormalizedPoint,
        rotation: Double = 0,
        size: NormalizedSize = .standard,
        points: [NormalizedPoint] = [],
        neighbors: [String] = []
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.size = size
        self.points = points
        self.neighbors = neighbors
    }

    func puzzleShape(clues: [ColorClue]) -> PuzzleShape {
        PuzzleShape(
            id: id,
            type: type,
            position: position,
            rotation: rotation,
            size: size,
            points: points,
            color: nil,
            neighbors: neighbors,
            clues: clues
        )
    }
}
