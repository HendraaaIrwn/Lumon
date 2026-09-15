import Foundation

nonisolated enum AnswerValidation: Equatable, Sendable {
    case correct
    case incorrect
    case invalidInput
}

nonisolated struct PuzzleValidator: Sendable {
    let graph: NeighborGraph

    func validateAnswer(
        shapeID: String,
        color: LumonColor,
        solution: [String: LumonColor],
        availableColors: [LumonColor]
    ) -> AnswerValidation {
        guard graph.neighbors(of: shapeID) != nil,
              availableColors.contains(color),
              color != .black,
              let answer = solution[shapeID] else {
            return .invalidInput
        }
        return answer == color ? .correct : .incorrect
    }

    func isFeasiblePartialBoard(
        colors: [String: LumonColor],
        shapes: [PuzzleShape]
    ) -> Bool {
        let shapeIDs = Set(shapes.map(\.id))
        guard Set(colors.keys).isSubset(of: shapeIDs),
              !colors.values.contains(.black) else { return false }

        return shapes.allSatisfy { shape in
            guard let neighborIDs = graph.neighbors(of: shape.id) else { return false }
            let requiredCounts = counts(shape.clues.map(\.color))
            let revealedCounts = counts(neighborIDs.compactMap { colors[$0] })
            let unresolvedCount = neighborIDs.filter { colors[$0] == nil }.count

            var totalMissing = 0
            for (color, required) in requiredCounts {
                let revealed = revealedCounts[color, default: 0]
                totalMissing += max(0, required - revealed)
            }
            return totalMissing <= unresolvedCount
        }
    }

    func isValidCompleteBoard(
        colors: [String: LumonColor],
        shapes: [PuzzleShape]
    ) -> Bool {
        guard !shapes.isEmpty,
              Set(colors.keys) == Set(shapes.map(\.id)),
              !colors.values.contains(.black) else { return false }

        return shapes.allSatisfy { shape in
            guard let neighborIDs = graph.neighbors(of: shape.id) else { return false }
            let requiredCounts = counts(shape.clues.map(\.color))
            let neighborCounts = counts(neighborIDs.compactMap { colors[$0] })
            return requiredCounts.allSatisfy { color, required in
                neighborCounts[color, default: 0] >= required
            }
        }
    }

    private func counts(_ colors: [LumonColor]) -> [LumonColor: Int] {
        colors.reduce(into: [:]) { result, color in
            result[color, default: 0] += 1
        }
    }
}
