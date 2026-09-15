import Foundation

nonisolated struct LevelMetadata: Codable, Hashable, Sendable {
    let title: String
    let order: Int
}
