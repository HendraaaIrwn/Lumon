import Foundation

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }
}

private struct LevelRecipe {
    let number: Int
    let shapeCount: Int
    let columns: Int
    let mirrored: Bool
    let seed: UInt64
}

@main
struct LevelAuthoring {
    static func main() throws {
        let recipes = [
            LevelRecipe(number: 2, shapeCount: 6, columns: 3, mirrored: false, seed: 0x1002),
            LevelRecipe(number: 3, shapeCount: 6, columns: 2, mirrored: true, seed: 0x1003),
            LevelRecipe(number: 4, shapeCount: 7, columns: 4, mirrored: false, seed: 0x1004),
            LevelRecipe(number: 5, shapeCount: 8, columns: 4, mirrored: true, seed: 0x1005),
            LevelRecipe(number: 6, shapeCount: 9, columns: 3, mirrored: false, seed: 0x1006),
            LevelRecipe(number: 7, shapeCount: 10, columns: 5, mirrored: true, seed: 0x1007),
            LevelRecipe(number: 8, shapeCount: 10, columns: 4, mirrored: false, seed: 0x1008),
            LevelRecipe(number: 9, shapeCount: 11, columns: 4, mirrored: true, seed: 0x1009),
            LevelRecipe(number: 10, shapeCount: 12, columns: 4, mirrored: false, seed: 0x1010),
        ]

        let outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Lumon/Resources/Levels", isDirectory: true)
        let generator = LevelGenerator()
        let exporter = LevelExporter()

        for recipe in recipes {
            let levelID = String(format: "level_%03d", recipe.number)
            var random = SeededGenerator(seed: recipe.seed)
            let level = try generator.generate(
                from: template(for: recipe),
                levelID: levelID,
                metadata: LevelMetadata(title: "Level \(recipe.number)", order: recipe.number),
                using: &random
            )
            let url = try exporter.export(level: level, to: outputDirectory)
            print("Generated \(url.lastPathComponent)")
        }
    }

    private static func template(for recipe: LevelRecipe) -> ArtworkTemplate {
        let ids = (1...recipe.shapeCount).map { String(format: "shape_%02d", $0) }
        let shapes = ids.enumerated().map { index, id in
            let row = index / recipe.columns
            let positionInRow = index % recipe.columns
            let goesBackward = row.isMultiple(of: 2) == recipe.mirrored
            let column = goesBackward ? recipe.columns - 1 - positionInRow : positionInRow
            let x = 0.22 + Double(column) * 0.16
            let y = 0.22 + Double(row) * 0.16
            let neighbors = [index - 1, index + 1]
                .filter { ids.indices.contains($0) }
                .map { ids[$0] }

            return ArtworkShape(
                id: id,
                type: shapeType(at: index + recipe.number),
                position: NormalizedPoint(x: x, y: y),
                rotation: rotation(at: index),
                size: NormalizedSize(width: 0.16, height: 0.16),
                neighbors: neighbors
            )
        }

        return ArtworkTemplate(
            id: "artwork_\(recipe.number)",
            availableColors: [.red, .yellow, .blue],
            shapes: shapes
        )
    }

    private static func shapeType(at index: Int) -> ShapeType {
        switch index % 4 {
        case 0: .triangle
        case 1: .square
        case 2: .diamond
        default: .circle
        }
    }

    private static func rotation(at index: Int) -> Double {
        switch index % 3 {
        case 0: 0
        case 1: 15
        default: -15
        }
    }
}
