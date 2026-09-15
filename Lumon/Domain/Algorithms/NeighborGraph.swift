import Foundation

nonisolated enum NeighborGraphError: LocalizedError, Sendable {
    case duplicateShapeID(String)
    case selfReference(String)
    case duplicateNeighbor(shapeID: String, neighborID: String)
    case unknownNeighbor(shapeID: String, neighborID: String)
    case asymmetricRelationship(shapeID: String, neighborID: String)

    var errorDescription: String? {
        switch self {
        case .duplicateShapeID(let id):
            "Shape ID \(id) is duplicated."
        case .selfReference(let id):
            "Shape \(id) cannot neighbor itself."
        case .duplicateNeighbor(let shapeID, let neighborID):
            "Shape \(shapeID) lists neighbor \(neighborID) more than once."
        case .unknownNeighbor(let shapeID, let neighborID):
            "Shape \(shapeID) references unknown neighbor \(neighborID)."
        case .asymmetricRelationship(let shapeID, let neighborID):
            "Neighbor relationship between \(shapeID) and \(neighborID) must be two-way."
        }
    }
}

nonisolated struct NeighborGraph: Sendable {
    private let adjacency: [String: Set<String>]

    init(shapes: [PuzzleShape]) throws {
        let ids = shapes.map(\.id)
        guard Set(ids).count == ids.count else {
            let duplicate = ids.first { id in ids.filter { $0 == id }.count > 1 } ?? "unknown"
            throw NeighborGraphError.duplicateShapeID(duplicate)
        }

        let knownIDs = Set(ids)
        var adjacency: [String: Set<String>] = [:]
        for shape in shapes {
            if shape.neighbors.contains(shape.id) {
                throw NeighborGraphError.selfReference(shape.id)
            }
            let neighbors = Set(shape.neighbors)
            if neighbors.count != shape.neighbors.count {
                let duplicate = shape.neighbors.first {
                    neighbor in shape.neighbors.filter { $0 == neighbor }.count > 1
                } ?? "unknown"
                throw NeighborGraphError.duplicateNeighbor(shapeID: shape.id, neighborID: duplicate)
            }
            if let unknown = neighbors.first(where: { !knownIDs.contains($0) }) {
                throw NeighborGraphError.unknownNeighbor(shapeID: shape.id, neighborID: unknown)
            }
            adjacency[shape.id] = neighbors
        }

        for (shapeID, neighbors) in adjacency {
            for neighborID in neighbors where adjacency[neighborID]?.contains(shapeID) != true {
                throw NeighborGraphError.asymmetricRelationship(
                    shapeID: shapeID,
                    neighborID: neighborID
                )
            }
        }
        self.adjacency = adjacency
    }

    func neighbors(of shapeID: String) -> Set<String>? {
        adjacency[shapeID]
    }
}
