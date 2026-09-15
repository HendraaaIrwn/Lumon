import Foundation

/// Device-independent shape size relative to the square game board.
nonisolated struct NormalizedSize: Codable, Hashable, Sendable {
    let width: Double
    let height: Double

    static let standard = NormalizedSize(width: 0.2, height: 0.2)
}
