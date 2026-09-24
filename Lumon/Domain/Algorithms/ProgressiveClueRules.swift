import Foundation

nonisolated enum ProgressiveClueRules {
    static func expectedInitialClueCount(for levelOrder: Int) -> Int {
        switch levelOrder {
        case ...3: 3
        case 4...7: 2
        default: 1
        }
    }
}

nonisolated enum ProgressiveClueValidationError: LocalizedError, Sendable {
    case searchLimitReached(Int)

    var errorDescription: String? {
        switch self {
        case .searchLimitReached(let limit):
            "Progressive clue validation reached its \(limit)-assignment limit."
        }
    }
}

/// Proves that the visible clues always expose at least one correct next move.
/// Hidden clues do not participate until their owning shape is solved.
nonisolated struct ProgressiveClueValidator: Sendable {
    let assignmentLimit: Int

    init(assignmentLimit: Int = 1_000_000) {
        self.assignmentLimit = assignmentLimit
    }

    func issue(for level: Level) throws -> String? {
        let initialShapes = level.shapes.filter(\.showsCluesInitially)
        let expectedCount = ProgressiveClueRules.expectedInitialClueCount(
            for: level.metadata.order
        )

        guard initialShapes.count == expectedCount else {
            return "Level order \(level.metadata.order) requires exactly \(expectedCount) initial clues."
        }
        guard initialShapes.allSatisfy({ !$0.clues.isEmpty }) else {
            return "A shape marked as an initial clue must contain at least one clue."
        }

        var solved: [String: LumonColor] = [:]
        var visibleClueIDs = Set(initialShapes.map(\.id))

        while solved.count < level.shapes.count {
            let visibleShapes = level.shapes.map { shape in
                shapeWithClues(shape, visible: visibleClueIDs.contains(shape.id))
            }
            let graph = try NeighborGraph(shapes: visibleShapes)
            let validator = PuzzleValidator(graph: graph)
            let possibilities = try possibleColors(
                shapes: visibleShapes,
                availableColors: level.availableColors,
                fixedColors: solved,
                validator: validator
            )
            let forcedShapeIDs = level.shapes.compactMap { shape -> String? in
                guard solved[shape.id] == nil,
                      let answer = level.solution[shape.id],
                      possibilities[shape.id] == Set([answer]) else { return nil }
                return shape.id
            }

            guard !forcedShapeIDs.isEmpty else {
                let unresolved = level.shapes
                    .map(\.id)
                    .filter { solved[$0] == nil }
                    .joined(separator: ", ")
                return "Progressive clues reach a deduction dead end at: \(unresolved)."
            }

            for shapeID in forcedShapeIDs {
                solved[shapeID] = level.solution[shapeID]
                visibleClueIDs.insert(shapeID)
            }
        }

        return nil
    }

    private func possibleColors(
        shapes: [PuzzleShape],
        availableColors: [LumonColor],
        fixedColors: [String: LumonColor],
        validator: PuzzleValidator
    ) throws -> [String: Set<LumonColor>] {
        guard validator.isFeasiblePartialBoard(colors: fixedColors, shapes: shapes) else {
            return [:]
        }

        let shapeIDs = shapes.map(\.id)
        let playableColors = availableColors.filter { $0 != .black }
        var assignments = fixedColors
        var attemptedAssignments = 0
        var possibilities = Dictionary(
            uniqueKeysWithValues: shapeIDs
                .filter { fixedColors[$0] == nil }
                .map { ($0, Set<LumonColor>()) }
        )

        func search() throws {
            guard let shapeID = shapeIDs.first(where: { assignments[$0] == nil }) else {
                guard validator.isValidCompleteBoard(colors: assignments, shapes: shapes) else {
                    return
                }
                for unresolvedID in Array(possibilities.keys) {
                    if let color = assignments[unresolvedID] {
                        possibilities[unresolvedID, default: []].insert(color)
                    }
                }
                return
            }

            for color in playableColors {
                guard attemptedAssignments < assignmentLimit else {
                    throw ProgressiveClueValidationError.searchLimitReached(assignmentLimit)
                }
                attemptedAssignments += 1
                assignments[shapeID] = color
                if validator.isFeasiblePartialBoard(colors: assignments, shapes: shapes) {
                    try search()
                }
                assignments.removeValue(forKey: shapeID)
            }
        }

        try search()
        return possibilities
    }

    private func shapeWithClues(_ shape: PuzzleShape, visible: Bool) -> PuzzleShape {
        PuzzleShape(
            id: shape.id,
            type: shape.type,
            position: shape.position,
            rotation: shape.rotation,
            size: shape.size,
            points: shape.points,
            color: nil,
            neighbors: shape.neighbors,
            clues: visible ? shape.clues : [],
            showsCluesInitially: shape.showsCluesInitially
        )
    }
}

nonisolated enum ProgressiveLevelAuthoringError: LocalizedError, Sendable {
    case unableToConfigure(String)

    var errorDescription: String? {
        switch self {
        case .unableToConfigure(let levelID):
            "A progressive clue path could not be authored for \(levelID)."
        }
    }
}

/// Adds the minimum missing neighbor clues and chooses the first valid set of
/// initial clue shapes in stable level order. Existing geometry and solutions
/// are never changed.
nonisolated struct ProgressiveLevelAuthor: Sendable {
    private let validator: ProgressiveClueValidator

    init(validator: ProgressiveClueValidator = ProgressiveClueValidator()) {
        self.validator = validator
    }

    func configure(_ level: Level) throws -> Level {
        if try validator.issue(for: level) == nil {
            return level
        }

        let missingClues = missingFullClues(in: level)

        for additionCount in 0...missingClues.count {
            for additions in combinations(of: missingClues, choosing: additionCount) {
                let shapesWithAdditions = adding(additions, to: level.shapes)
                let eligibleIDs = shapesWithAdditions
                    .filter { !$0.clues.isEmpty }
                    .map(\.id)
                let initialCount = ProgressiveClueRules.expectedInitialClueCount(
                    for: level.metadata.order
                )
                guard eligibleIDs.count >= initialCount else { continue }

                for initialIDs in combinations(of: eligibleIDs, choosing: initialCount) {
                    let initialSet = Set(initialIDs)
                    let candidate = Level(
                        id: level.id,
                        metadata: level.metadata,
                        availableColors: level.availableColors,
                        shapes: shapesWithAdditions.map { shape in
                            var configured = shape
                            configured.showsCluesInitially = initialSet.contains(shape.id)
                            return configured
                        },
                        solution: level.solution
                    )
                    if try validator.issue(for: candidate) == nil {
                        return candidate
                    }
                }
            }
        }

        throw ProgressiveLevelAuthoringError.unableToConfigure(level.id)
    }

    private func missingFullClues(in level: Level) -> [(shapeID: String, clue: ColorClue)] {
        level.shapes.flatMap { shape in
            var remainingExisting = shape.clues.map(\.color)
            return shape.neighbors.compactMap { neighborID -> (shapeID: String, clue: ColorClue)? in
                guard let color = level.solution[neighborID] else { return nil }
                if let index = remainingExisting.firstIndex(of: color) {
                    remainingExisting.remove(at: index)
                    return nil
                }
                return (shape.id, ColorClue(color: color))
            }
        }
    }

    private func adding(
        _ additions: [(shapeID: String, clue: ColorClue)],
        to shapes: [PuzzleShape]
    ) -> [PuzzleShape] {
        shapes.map { shape in
            let addedClues = additions
                .filter { $0.shapeID == shape.id }
                .map(\.clue)
            guard !addedClues.isEmpty else { return shape }
            return PuzzleShape(
                id: shape.id,
                type: shape.type,
                position: shape.position,
                rotation: shape.rotation,
                size: shape.size,
                points: shape.points,
                color: shape.color,
                neighbors: shape.neighbors,
                clues: shape.clues + addedClues,
                showsCluesInitially: shape.showsCluesInitially
            )
        }
    }

    private func combinations<Element>(
        of elements: [Element],
        choosing count: Int
    ) -> [[Element]] {
        guard count > 0 else { return [[]] }
        guard count <= elements.count else { return [] }
        if count == elements.count { return [elements] }

        var result: [[Element]] = []
        func appendCombinations(start: Int, selected: [Element]) {
            if selected.count == count {
                result.append(selected)
                return
            }
            let remainingNeeded = count - selected.count
            guard start <= elements.count - remainingNeeded else { return }
            for index in start...(elements.count - remainingNeeded) {
                appendCombinations(
                    start: index + 1,
                    selected: selected + [elements[index]]
                )
            }
        }
        appendCombinations(start: 0, selected: [])
        return result
    }
}
