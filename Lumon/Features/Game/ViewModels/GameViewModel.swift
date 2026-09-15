import Foundation
import Observation

@MainActor
@Observable
final class GameViewModel {
    private let levelID: String
    private let repository: any LevelRepository

    private(set) var level: Level?
    private(set) var loadingState: GameLoadingState = .idle
    private(set) var selectedShapeID: String?

    init(levelID: String, repository: any LevelRepository = BundleLevelRepository()) {
        self.levelID = levelID
        self.repository = repository
    }

    func load() {
        loadingState = .loading
        do {
            level = try repository.level(id: levelID)
            selectedShapeID = nil
            loadingState = .loaded
        } catch {
            level = nil
            selectedShapeID = nil
            loadingState = .failed(message: error.localizedDescription)
        }
    }

    func selectShape(id: String) {
        guard level?.shapes.contains(where: { $0.id == id }) == true else { return }
        selectedShapeID = id
    }
}
