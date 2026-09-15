import Foundation

nonisolated struct LevelValidator: Sendable {
    let solverAssignmentLimit: Int

    init(solverAssignmentLimit: Int = 100_000) {
        self.solverAssignmentLimit = solverAssignmentLimit
    }

    func issues(for level: Level) -> [String] {
        var issues: [String] = []
        let shapeIDs = level.shapes.map(\.id)
        let knownShapeIDs = Set(shapeIDs)
        let availableColors = Set(level.availableColors)
        let solutionIDs = Set(level.solution.keys)

        if level.id.isEmpty { issues.append("Level ID must not be empty.") }
        if level.metadata.title.isEmpty { issues.append("Level title must not be empty.") }
        if level.metadata.order < 1 { issues.append("Level order must be positive.") }
        if level.shapes.isEmpty { issues.append("At least one shape is required.") }
        if knownShapeIDs.count != shapeIDs.count { issues.append("Shape IDs must be unique.") }
        if level.availableColors.isEmpty { issues.append("At least one playable color is required.") }
        if availableColors.count != level.availableColors.count {
            issues.append("Available colors must be unique.")
        }
        if level.availableColors.contains(.black) {
            issues.append("Black is reserved for unrevealed shapes.")
        }
        if solutionIDs != knownShapeIDs {
            issues.append("The solution must contain exactly one answer for every shape.")
        }
        if level.solution.values.contains(where: { !availableColors.contains($0) }) {
            issues.append("The solution contains a color outside the playable palette.")
        }

        for shape in level.shapes {
            validate(
                shape,
                knownShapeIDs: knownShapeIDs,
                availableColors: availableColors,
                issues: &issues
            )
        }

        guard issues.isEmpty else { return issues }

        let graph: NeighborGraph
        do {
            graph = try NeighborGraph(shapes: level.shapes)
        } catch {
            return [error.localizedDescription]
        }

        let validator = PuzzleValidator(graph: graph)
        guard validator.isValidCompleteBoard(colors: level.solution, shapes: level.shapes) else {
            return ["The solution does not satisfy the level clues."]
        }

        do {
            switch try PuzzleSolver(assignmentLimit: solverAssignmentLimit).solve(
                shapes: level.shapes,
                availableColors: level.availableColors
            ) {
            case .noSolution:
                issues.append("The puzzle has no solution.")
            case .unique(let solution):
                if solution != level.solution {
                    issues.append("The unique puzzle solution does not match the hidden solution.")
                }
            case .multipleSolutions:
                issues.append("The puzzle has more than one solution.")
            }
        } catch PuzzleSolverError.searchLimitReached {
            issues.append("Puzzle uniqueness could not be proven within the search limit.")
        } catch {
            issues.append(error.localizedDescription)
        }

        return issues
    }

    private func validate(
        _ shape: PuzzleShape,
        knownShapeIDs: Set<String>,
        availableColors: Set<LumonColor>,
        issues: inout [String]
    ) {
        let coordinates = [shape.position.x, shape.position.y]
        if shape.id.isEmpty { issues.append("Shape IDs must not be empty.") }
        if !coordinates.allSatisfy({ $0.isFinite && (0...1).contains($0) }) {
            issues.append("Shape \(shape.id) has an invalid position.")
        }
        if !shape.rotation.isFinite { issues.append("Shape \(shape.id) has an invalid rotation.") }
        if !shape.size.width.isFinite || !shape.size.height.isFinite
            || shape.size.width <= 0 || shape.size.height <= 0
            || shape.size.width > 1 || shape.size.height > 1 {
            issues.append("Shape \(shape.id) has an invalid size.")
        }
        if shape.neighbors.contains(shape.id) {
            issues.append("Shape \(shape.id) cannot neighbor itself.")
        }
        if Set(shape.neighbors).count != shape.neighbors.count {
            issues.append("Shape \(shape.id) has duplicate neighbors.")
        }
        if shape.neighbors.contains(where: { !knownShapeIDs.contains($0) }) {
            issues.append("Shape \(shape.id) references an unknown neighbor.")
        }
        if shape.clues.count > 6 {
            issues.append("Shape \(shape.id) has more than six clues.")
        }
        if shape.clues.contains(where: { !availableColors.contains($0.color) }) {
            issues.append("Shape \(shape.id) has a clue color outside the playable palette.")
        }
        if shape.clues.count > shape.neighbors.count {
            issues.append("Shape \(shape.id) has more clues than neighbors.")
        }

        if shape.type == .polygon {
            validatePolygon(shape, issues: &issues)
        } else if !shape.points.isEmpty {
            issues.append("Shape \(shape.id) defines polygon points for a standard shape.")
        }
    }

    private func validatePolygon(_ shape: PuzzleShape, issues: inout [String]) {
        let points = shape.points
        guard points.count >= 3, Set(points).count >= 3 else {
            issues.append("Polygon \(shape.id) needs at least three distinct points.")
            return
        }
        guard points.allSatisfy({ point in
            point.x.isFinite && point.y.isFinite
                && (0...1).contains(point.x) && (0...1).contains(point.y)
        }) else {
            issues.append("Polygon \(shape.id) has a point outside local coordinates.")
            return
        }

        let doubledArea = points.indices.reduce(0.0) { result, index in
            let next = points[(index + 1) % points.count]
            return result + points[index].x * next.y - next.x * points[index].y
        }
        if abs(doubledArea) <= .ulpOfOne {
            issues.append("Polygon \(shape.id) is degenerate.")
        }
    }
}
