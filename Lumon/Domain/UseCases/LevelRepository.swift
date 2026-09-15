import Foundation

protocol LevelRepository: Actor {
    nonisolated var availableLevelIDs: [String] { get }

    func level(id: String) async throws -> Level
}
