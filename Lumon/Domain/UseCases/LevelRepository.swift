import Foundation

protocol LevelRepository {
    var availableLevelIDs: [String] { get }

    func level(id: String) throws -> Level
}
