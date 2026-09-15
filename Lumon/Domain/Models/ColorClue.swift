import Foundation

/// One hidden color hint (PRS §5). Repeated values represent the minimum
/// number of neighboring shapes that use that color.
nonisolated struct ColorClue: Codable, Hashable, Sendable {
    let color: LumonColor
}
