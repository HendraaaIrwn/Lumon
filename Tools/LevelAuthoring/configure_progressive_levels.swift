import Foundation

@main
struct ProgressiveLevelConfiguration {
    static func main() throws {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Lumon/Resources/Levels", isDirectory: true)
        let decoder = JSONDecoder()
        let exporter = LevelExporter()
        let author = ProgressiveLevelAuthor()
        let validateOnly = CommandLine.arguments.contains("--validate-only")
        if CommandLine.arguments.contains("--self-test") {
            try runSelfTests(directory: directory, decoder: decoder)
            return
        }

        for number in 1...10 {
            let levelID = String(format: "level_%03d", number)
            let sourceURL = directory
                .appendingPathComponent(levelID)
                .appendingPathExtension("json")
            let level = try decoder.decode(Level.self, from: Data(contentsOf: sourceURL))
            if validateOnly {
                let issues = LevelValidator().issues(for: level)
                guard issues.isEmpty else {
                    throw NSError(
                        domain: "LumonLevelValidation",
                        code: number,
                        userInfo: [NSLocalizedDescriptionKey: issues.joined(separator: " ")]
                    )
                }
                print("Validated \(levelID)")
                continue
            }
            let configured = try author.configure(level)
            try exporter.export(level: configured, to: directory)

            let initialIDs = configured.shapes
                .filter(\.showsCluesInitially)
                .map(\.id)
                .joined(separator: ", ")
            print("Configured \(levelID): \(initialIDs)")
        }
    }

    private static func runSelfTests(directory: URL, decoder: JSONDecoder) throws {
        let legacyShapeJSON = #"{"id":"legacy","type":"circle","x":0.5,"y":0.5,"neighbors":[],"clues":[]}"#
        let legacyShape = try decoder.decode(
            PuzzleShape.self,
            from: Data(legacyShapeJSON.utf8)
        )
        guard !legacyShape.showsCluesInitially else {
            throw verificationError("Legacy shapes must default to hidden clues.")
        }

        let levelURL = directory.appendingPathComponent("level_001.json")
        let level = try decoder.decode(Level.self, from: Data(contentsOf: levelURL))
        let invalidLevel = Level(
            id: level.id,
            metadata: level.metadata,
            availableColors: level.availableColors,
            shapes: level.shapes.map { shape in
                var hidden = shape
                hidden.showsCluesInitially = false
                return hidden
            },
            solution: level.solution
        )
        let issues = LevelValidator().issues(for: invalidLevel)
        guard issues.contains(where: { $0.contains("requires exactly 3 initial clues") }) else {
            throw verificationError("Invalid initial clue counts must be rejected.")
        }

        let levelFiveURL = directory.appendingPathComponent("level_005.json")
        let levelFive = try decoder.decode(Level.self, from: Data(contentsOf: levelFiveURL))
        let layoutEngine = HintCircleLayoutEngine()
        guard let emptyLayout = layoutEngine.layout(
            type: .square,
            points: [],
            clueCount: 0,
            renderedWidth: 120,
            renderedHeight: 120
        ), emptyLayout.diameter == 0, emptyLayout.centers.isEmpty else {
            throw verificationError("Shapes without hints must produce an empty layout.")
        }

        for type in [ShapeType.circle, .square, .diamond] {
            try verifyCenteredLayout(
                engine: layoutEngine,
                type: type,
                points: [],
                clueCount: 1,
                width: 120,
                height: 120,
                maximumOffset: 0.001
            )
        }
        try verifyCenteredLayout(
            engine: layoutEngine,
            type: .triangle,
            points: [],
            clueCount: 3,
            width: 120,
            height: 120,
            maximumOffset: 4
        )
        try verifyBalancedLayout(
            engine: layoutEngine,
            type: .triangle,
            points: [],
            clueCount: 3,
            width: 120,
            height: 120,
            maximumCentroidOffset: 4,
            maximumAngularVariance: 0.8
        )
        for clueCount in 2...6 {
            try verifyBalancedLayout(
                engine: layoutEngine,
                type: .square,
                points: [],
                clueCount: clueCount,
                width: 120,
                height: 120,
                maximumCentroidOffset: 4,
                maximumAngularVariance: 0.8
            )
        }

        for shapeID in ["shape_12", "shape_13"] {
            guard let shape = levelFive.shapes.first(where: { $0.id == shapeID }) else {
                throw verificationError("Missing Level 5 narrow polygon \(shapeID).")
            }
            let layout = layoutEngine.layout(
                type: shape.type,
                points: shape.points,
                clueCount: shape.clues.count,
                renderedWidth: shape.size.width * 240,
                renderedHeight: shape.size.height * 240
            )
            guard layout?.centers.count == shape.clues.count,
                  layout?.diameter == HintCircleLayoutEngine.minimumDiameter else {
                throw verificationError("Narrow polygon \(shapeID) must fit all 6-point hints.")
            }
            try verifyCenteredLayout(
                engine: layoutEngine,
                type: shape.type,
                points: shape.points,
                clueCount: shape.clues.count,
                width: shape.size.width * 240,
                height: shape.size.height * 240,
                maximumOffset: min(shape.size.width, shape.size.height) * 240 * 0.25
            )
        }

        for boardSize in [240.0, 640.0] {
            for number in 1...10 {
                let levelID = String(format: "level_%03d", number)
                let levelURL = directory.appendingPathComponent(levelID).appendingPathExtension("json")
                let catalogLevel = try decoder.decode(Level.self, from: Data(contentsOf: levelURL))
                for shape in catalogLevel.shapes where !shape.clues.isEmpty {
                    let width = shape.size.width * boardSize
                    let height = shape.size.height * boardSize
                    let first = layoutEngine.layout(
                        type: shape.type,
                        points: shape.points,
                        clueCount: shape.clues.count,
                        renderedWidth: width,
                        renderedHeight: height
                    )
                    let second = layoutEngine.layout(
                        type: shape.type,
                        points: shape.points,
                        clueCount: shape.clues.count,
                        renderedWidth: width,
                        renderedHeight: height
                    )
                    guard let first,
                          first.centers.count == shape.clues.count,
                          first == second else {
                        throw verificationError(
                            "\(levelID) \(shape.id) must have a deterministic layout at \(Int(boardSize)) pt."
                        )
                    }
                }
            }
        }

        guard layoutEngine.layout(
            type: .triangle,
            points: [],
            clueCount: 2,
            renderedWidth: 8,
            renderedHeight: 8
        ) == nil else {
            throw verificationError("Impossible hint-circle layouts must be rejected.")
        }

        print("Passed legacy decoding, initial-clue, centered hint-circle, and catalog layout checks")
    }

    private static func verifyCenteredLayout(
        engine: HintCircleLayoutEngine,
        type: ShapeType,
        points: [NormalizedPoint],
        clueCount: Int,
        width: Double,
        height: Double,
        maximumOffset: Double
    ) throws {
        guard let layout = engine.layout(
            type: type,
            points: points,
            clueCount: clueCount,
            renderedWidth: width,
            renderedHeight: height
        ) else {
            throw verificationError("Expected a centered hint-circle layout.")
        }
        let center = layout.centers.reduce((x: 0.0, y: 0.0)) {
            ($0.x + $1.x, $0.y + $1.y)
        }
        let clusterCenter = NormalizedPoint(
            x: center.x / Double(layout.centers.count),
            y: center.y / Double(layout.centers.count)
        )
        let target = engine.targetCenter(type: type, points: points)
        let offset = hypot(
            (clusterCenter.x - target.x) * width,
            (clusterCenter.y - target.y) * height
        )
        guard offset <= maximumOffset + 0.000_1 else {
            throw verificationError(
                "Hint-circle group is \(String(format: "%.2f", offset)) pt from its shape centroid."
            )
        }
    }

    private static func verifyBalancedLayout(
        engine: HintCircleLayoutEngine,
        type: ShapeType,
        points: [NormalizedPoint],
        clueCount: Int,
        width: Double,
        height: Double,
        maximumCentroidOffset: Double,
        maximumAngularVariance: Double
    ) throws {
        guard let layout = engine.layout(
            type: type,
            points: points,
            clueCount: clueCount,
            renderedWidth: width,
            renderedHeight: height
        ) else {
            throw verificationError("Expected a balanced hint-circle layout.")
        }

        let center = layout.centers.reduce((x: 0.0, y: 0.0)) {
            ($0.x + $1.x, $0.y + $1.y)
        }
        let centroid = Point(
            x: center.x / Double(layout.centers.count) * width,
            y: center.y / Double(layout.centers.count) * height
        )
        let target = engine.targetCenter(type: type, points: points)
        let centroidOffset = hypot(
            centroid.x - target.x * width,
            centroid.y - target.y * height
        )
        guard centroidOffset <= maximumCentroidOffset + 0.000_1 else {
            throw verificationError("Hint circles are not centered on their parent shape.")
        }

        let angles = layout.centers.map { point in
            atan2((point.y * height) - centroid.y, (point.x * width) - centroid.x)
        }.sorted()
        let expectedGap = 2 * Double.pi / Double(clueCount)
        let variance = angles.indices
            .map { index in
                let next = angles[(index + 1) % angles.count]
                let adjustedNext = index == angles.count - 1 ? next + 2 * Double.pi : next
                let difference = adjustedNext - angles[index] - expectedGap
                return difference * difference
            }
            .reduce(0, +) / Double(clueCount)
        guard variance <= maximumAngularVariance else {
            throw verificationError("Hint circles are not spaced symmetrically around their center.")
        }
    }

    private struct Point {
        let x: Double
        let y: Double
    }

    private static func verificationError(_ message: String) -> NSError {
        NSError(
            domain: "LumonProgressiveClueVerification",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
