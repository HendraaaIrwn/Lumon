import Foundation

nonisolated struct HintReveal: Equatable, Sendable {
    let shapeID: String
    let color: LumonColor
}

nonisolated struct HintManager: Sendable {
    func reveal(
        selectedShapeID: String?,
        shapes: [PuzzleShape],
        solution: [String: LumonColor]
    ) -> HintReveal? {
        let unresolvedIDs = shapes.filter { $0.color == nil }.map(\.id)
        let targetID: String?
        if let selectedShapeID, unresolvedIDs.contains(selectedShapeID) {
            targetID = selectedShapeID
        } else {
            targetID = unresolvedIDs.first
        }

        guard let targetID, let color = solution[targetID] else { return nil }
        return HintReveal(shapeID: targetID, color: color)
    }
}
