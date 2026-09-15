import Foundation

nonisolated enum PuzzleSolverError: LocalizedError, Sendable {
    case invalidInput(String)
    case searchLimitReached(Int)

    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            "The puzzle cannot be solved: \(message)"
        case .searchLimitReached(let limit):
            "The puzzle search reached its \(limit)-assignment limit."
        }
    }
}

nonisolated enum PuzzleSolverResult: Equatable, Sendable {
    case noSolution
    case unique([String: LumonColor])
    case multipleSolutions(first: [String: LumonColor])
}

nonisolated struct PuzzleSolver: Sendable {
    let assignmentLimit: Int

    init(assignmentLimit: Int = 100_000) {
        self.assignmentLimit = assignmentLimit
    }

    func solve(
        shapes: [PuzzleShape],
        availableColors: [LumonColor]
    ) throws -> PuzzleSolverResult {
        guard !shapes.isEmpty else {
            throw PuzzleSolverError.invalidInput("At least one shape is required.")
        }
        guard assignmentLimit > 0 else {
            throw PuzzleSolverError.invalidInput("The assignment limit must be positive.")
        }

        let playableColors = availableColors.filter { $0 != .black }
        guard !playableColors.isEmpty,
              playableColors.count == availableColors.count,
              Set(playableColors).count == playableColors.count else {
            throw PuzzleSolverError.invalidInput(
                "The playable palette must contain unique, non-black colors."
            )
        }
        guard shapes.allSatisfy({ shape in
            shape.clues.allSatisfy { playableColors.contains($0.color) }
        }) else {
            throw PuzzleSolverError.invalidInput(
                "Every clue color must belong to the playable palette."
            )
        }

        let graph: NeighborGraph
        do {
            graph = try NeighborGraph(shapes: shapes)
        } catch {
            throw PuzzleSolverError.invalidInput(error.localizedDescription)
        }

        let validator = PuzzleValidator(graph: graph)
        let shapeIDs = shapes.map(\.id)
        var assignments: [String: LumonColor] = [:]
        var firstSolution: [String: LumonColor]?
        var solutionCount = 0
        var attemptedAssignments = 0

        func search(shapeIndex: Int) throws {
            guard solutionCount < 2 else { return }

            if shapeIndex == shapeIDs.count {
                guard validator.isValidCompleteBoard(colors: assignments, shapes: shapes) else {
                    return
                }
                solutionCount += 1
                if firstSolution == nil {
                    firstSolution = assignments
                }
                return
            }

            let shapeID = shapeIDs[shapeIndex]
            for color in playableColors {
                guard attemptedAssignments < assignmentLimit else {
                    throw PuzzleSolverError.searchLimitReached(assignmentLimit)
                }
                attemptedAssignments += 1
                assignments[shapeID] = color

                if validator.isFeasiblePartialBoard(colors: assignments, shapes: shapes) {
                    try search(shapeIndex: shapeIndex + 1)
                }
                assignments.removeValue(forKey: shapeID)

                if solutionCount >= 2 {
                    return
                }
            }
        }

        try search(shapeIndex: 0)

        switch solutionCount {
        case 0:
            return .noSolution
        case 1:
            return .unique(firstSolution ?? [:])
        default:
            return .multipleSolutions(first: firstSolution ?? [:])
        }
    }
}
