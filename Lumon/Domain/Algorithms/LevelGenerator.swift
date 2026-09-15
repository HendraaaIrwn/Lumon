import Foundation

nonisolated struct LevelGeneratorOptions: Equatable, Sendable {
    var maximumCandidates: Int
    var solverAssignmentLimit: Int

    init(maximumCandidates: Int = 100, solverAssignmentLimit: Int = 100_000) {
        self.maximumCandidates = maximumCandidates
        self.solverAssignmentLimit = solverAssignmentLimit
    }
}

nonisolated enum LevelGeneratorError: LocalizedError, Sendable {
    case invalidInput([String])
    case generationExhausted(Int)

    var errorDescription: String? {
        switch self {
        case .invalidInput(let issues):
            "The artwork template is invalid: \(issues.joined(separator: " "))"
        case .generationExhausted(let attempts):
            "A unique level could not be generated after \(attempts) candidates."
        }
    }
}

nonisolated struct LevelGenerator: Sendable {
    let options: LevelGeneratorOptions

    init(options: LevelGeneratorOptions = LevelGeneratorOptions()) {
        self.options = options
    }

    func generate(
        from template: ArtworkTemplate,
        levelID: String,
        metadata: LevelMetadata
    ) throws -> Level {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return try generate(
            from: template,
            levelID: levelID,
            metadata: metadata,
            using: &randomNumberGenerator
        )
    }

    func generate<R: RandomNumberGenerator>(
        from template: ArtworkTemplate,
        levelID: String,
        metadata: LevelMetadata,
        using randomNumberGenerator: inout R
    ) throws -> Level {
        let templateIssues = validate(
            template: template,
            levelID: levelID,
            metadata: metadata
        )
        guard templateIssues.isEmpty else {
            throw LevelGeneratorError.invalidInput(templateIssues)
        }

        let solver = PuzzleSolver(assignmentLimit: options.solverAssignmentLimit)
        for _ in 0..<options.maximumCandidates {
            let solution = Dictionary(uniqueKeysWithValues: template.shapes.map { shape in
                (shape.id, template.availableColors.randomElement(using: &randomNumberGenerator)!)
            })
            var clues = generateClues(
                for: template,
                solution: solution,
                using: &randomNumberGenerator
            )
            var level = makeLevel(
                template: template,
                levelID: levelID,
                metadata: metadata,
                solution: solution,
                clues: clues
            )

            do {
                guard try isUniqueAndMatching(level, solver: solver) else { continue }
            } catch PuzzleSolverError.searchLimitReached {
                continue
            } catch {
                throw LevelGeneratorError.invalidInput([error.localizedDescription])
            }

            clues = reduceClues(
                clues,
                template: template,
                levelID: levelID,
                metadata: metadata,
                solution: solution,
                solver: solver,
                using: &randomNumberGenerator
            )
            level = makeLevel(
                template: template,
                levelID: levelID,
                metadata: metadata,
                solution: solution,
                clues: clues
            )

            let issues = LevelValidator(
                solverAssignmentLimit: options.solverAssignmentLimit
            ).issues(for: level)
            if issues.isEmpty {
                return level
            }
        }

        throw LevelGeneratorError.generationExhausted(options.maximumCandidates)
    }

    private func generateClues<R: RandomNumberGenerator>(
        for template: ArtworkTemplate,
        solution: [String: LumonColor],
        using randomNumberGenerator: inout R
    ) -> [String: [ColorClue]] {
        Dictionary(uniqueKeysWithValues: template.shapes.map { shape in
            var neighborIDs = shape.neighbors
            if neighborIDs.count > 6 {
                neighborIDs.shuffle(using: &randomNumberGenerator)
                neighborIDs = Array(neighborIDs.prefix(6))
            }
            let clues = neighborIDs.compactMap { neighborID in
                solution[neighborID].map { ColorClue(color: $0) }
            }
            return (shape.id, clues)
        })
    }

    private func reduceClues<R: RandomNumberGenerator>(
        _ originalClues: [String: [ColorClue]],
        template: ArtworkTemplate,
        levelID: String,
        metadata: LevelMetadata,
        solution: [String: LumonColor],
        solver: PuzzleSolver,
        using randomNumberGenerator: inout R
    ) -> [String: [ColorClue]] {
        var clues = originalClues
        var removalOrder = template.shapes.flatMap { shape in
            originalClues[shape.id, default: []].map { (shape.id, $0) }
        }
        removalOrder.shuffle(using: &randomNumberGenerator)

        for (shapeID, clue) in removalOrder {
            guard let clueIndex = clues[shapeID]?.firstIndex(of: clue) else { continue }
            var candidateClues = clues
            candidateClues[shapeID]?.remove(at: clueIndex)
            let candidate = makeLevel(
                template: template,
                levelID: levelID,
                metadata: metadata,
                solution: solution,
                clues: candidateClues
            )

            do {
                if try isUniqueAndMatching(candidate, solver: solver) {
                    clues = candidateClues
                }
            } catch PuzzleSolverError.searchLimitReached {
                continue
            } catch {
                continue
            }
        }

        return clues
    }

    private func isUniqueAndMatching(
        _ level: Level,
        solver: PuzzleSolver
    ) throws -> Bool {
        switch try solver.solve(
            shapes: level.shapes,
            availableColors: level.availableColors
        ) {
        case .unique(let solution):
            return solution == level.solution
        case .noSolution, .multipleSolutions:
            return false
        }
    }

    private func makeLevel(
        template: ArtworkTemplate,
        levelID: String,
        metadata: LevelMetadata,
        solution: [String: LumonColor],
        clues: [String: [ColorClue]]
    ) -> Level {
        Level(
            id: levelID,
            metadata: metadata,
            availableColors: template.availableColors,
            shapes: template.shapes.map { shape in
                shape.puzzleShape(clues: clues[shape.id, default: []])
            },
            solution: solution
        )
    }

    private func validate(
        template: ArtworkTemplate,
        levelID: String,
        metadata: LevelMetadata
    ) -> [String] {
        var issues: [String] = []
        let shapeIDs = template.shapes.map(\.id)

        if template.id.isEmpty { issues.append("Artwork ID must not be empty.") }
        if levelID.isEmpty { issues.append("Level ID must not be empty.") }
        if metadata.title.isEmpty { issues.append("Level title must not be empty.") }
        if metadata.order < 1 { issues.append("Level order must be positive.") }
        if template.shapes.isEmpty { issues.append("At least one artwork shape is required.") }
        if Set(shapeIDs).count != shapeIDs.count { issues.append("Shape IDs must be unique.") }
        if shapeIDs.contains(where: \.isEmpty) { issues.append("Shape IDs must not be empty.") }
        if template.availableColors.isEmpty {
            issues.append("At least one playable color is required.")
        }
        if Set(template.availableColors).count != template.availableColors.count {
            issues.append("Playable colors must be unique.")
        }
        if template.availableColors.contains(.black) {
            issues.append("Black is reserved for unrevealed shapes.")
        }
        if options.maximumCandidates <= 0 {
            issues.append("The candidate limit must be positive.")
        }
        if options.solverAssignmentLimit <= 0 {
            issues.append("The solver assignment limit must be positive.")
        }

        for shape in template.shapes {
            if !shape.position.x.isFinite || !shape.position.y.isFinite
                || !(0...1).contains(shape.position.x)
                || !(0...1).contains(shape.position.y) {
                issues.append("Shape \(shape.id) has an invalid position.")
            }
            if !shape.rotation.isFinite {
                issues.append("Shape \(shape.id) has an invalid rotation.")
            }
            if !shape.size.width.isFinite || !shape.size.height.isFinite
                || shape.size.width <= 0 || shape.size.height <= 0
                || shape.size.width > 1 || shape.size.height > 1 {
                issues.append("Shape \(shape.id) has an invalid size.")
            }
            if shape.type == .polygon {
                if shape.points.count < 3 || Set(shape.points).count < 3 {
                    issues.append("Polygon \(shape.id) needs at least three distinct points.")
                } else if shape.points.contains(where: { point in
                    !point.x.isFinite || !point.y.isFinite
                        || !(0...1).contains(point.x) || !(0...1).contains(point.y)
                }) {
                    issues.append("Polygon \(shape.id) has a point outside local coordinates.")
                } else {
                    let doubledArea = shape.points.indices.reduce(0.0) { result, index in
                        let next = shape.points[(index + 1) % shape.points.count]
                        return result
                            + shape.points[index].x * next.y
                            - next.x * shape.points[index].y
                    }
                    if abs(doubledArea) <= .ulpOfOne {
                        issues.append("Polygon \(shape.id) is degenerate.")
                    }
                }
            } else if !shape.points.isEmpty {
                issues.append("Shape \(shape.id) defines polygon points for a standard shape.")
            }
        }

        if issues.isEmpty {
            do {
                _ = try NeighborGraph(
                    shapes: template.shapes.map { $0.puzzleShape(clues: []) }
                )
            } catch {
                issues.append(error.localizedDescription)
            }
        }

        return issues
    }
}
