import Foundation

struct BundleLevelRepository: LevelRepository {
    let availableLevelIDs = ["level_001"]
    private let loader: LevelLoader

    init(bundle: Bundle = .main) {
        loader = LevelLoader(bundle: bundle)
    }

    func level(id: String) throws -> Level {
        guard availableLevelIDs.contains(id) else {
            throw LevelLoaderError.resourceNotFound(id)
        }
        return try loader.loadLevel(id: id)
    }
}
