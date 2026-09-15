import Foundation

nonisolated enum LevelExporterError: LocalizedError, Sendable {
    case invalidLevel([String])
    case unsafeLevelID(String)

    var errorDescription: String? {
        switch self {
        case .invalidLevel(let issues):
            "The level cannot be exported: \(issues.joined(separator: " "))"
        case .unsafeLevelID(let id):
            "The level ID cannot be used as a file name: \(id)"
        }
    }
}

nonisolated struct LevelExporter: Sendable {
    private let validator: LevelValidator

    init(validator: LevelValidator = LevelValidator()) {
        self.validator = validator
    }

    func encode(level: Level) throws -> Data {
        let exportLevel = levelWithHiddenPlayerColors(level)
        let issues = validator.issues(for: exportLevel)
        guard issues.isEmpty else {
            throw LevelExporterError.invalidLevel(issues)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(exportLevel)
    }

    @discardableResult
    func export(level: Level, to directory: URL) throws -> URL {
        guard isSafeFileName(level.id) else {
            throw LevelExporterError.unsafeLevelID(level.id)
        }

        let data = try encode(level: level)
        let destination = directory
            .appendingPathComponent(level.id, isDirectory: false)
            .appendingPathExtension("json")
        try data.write(to: destination, options: .atomic)
        return destination
    }

    private func levelWithHiddenPlayerColors(_ level: Level) -> Level {
        Level(
            id: level.id,
            metadata: level.metadata,
            availableColors: level.availableColors,
            shapes: level.shapes.map { shape in
                var hiddenShape = shape
                hiddenShape.color = nil
                return hiddenShape
            },
            solution: level.solution
        )
    }

    private func isSafeFileName(_ id: String) -> Bool {
        !id.isEmpty
            && id != "."
            && id != ".."
            && !id.contains("/")
            && !id.contains("\\")
    }
}
