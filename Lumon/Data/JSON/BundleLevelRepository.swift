import Foundation

actor BundleLevelRepository: LevelRepository {
    nonisolated let availableLevelIDs = (1...10).map { String(format: "level_%03d", $0) }
    private let loader: LevelLoader

    init(bundle: Bundle = .main) {
        loader = LevelLoader(bundle: bundle)
    }

    func level(id: String) async throws -> Level {
        guard availableLevelIDs.contains(id) else {
            throw LevelLoaderError.resourceNotFound(id)
        }
        return try loader.loadLevel(id: id)
    }
}
