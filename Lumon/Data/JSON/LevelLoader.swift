import Foundation

nonisolated struct LevelLoader: Sendable {
    private let bundle: Bundle
    private let validator: LevelValidator

    init(
        bundle: Bundle = .main,
        validator: LevelValidator = LevelValidator()
    ) {
        self.bundle = bundle
        self.validator = validator
    }

    func loadLevel(id: String) throws -> Level {
        guard let url = bundle.url(forResource: id, withExtension: "json", subdirectory: "Levels")
            ?? bundle.url(forResource: id, withExtension: "json") else {
            throw LevelLoaderError.resourceNotFound(id)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw LevelLoaderError.unreadableData(id, error)
        }

        let level: Level
        do {
            level = try JSONDecoder().decode(Level.self, from: data)
        } catch {
            throw LevelLoaderError.decodingFailed(id, error)
        }

        let issues = validator.issues(for: level)
        guard issues.isEmpty else {
            throw LevelLoaderError.invalidLevel(issues)
        }
        return level
    }
}
