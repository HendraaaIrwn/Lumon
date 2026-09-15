import Foundation

nonisolated struct GameCompletionChecker: Sendable {
    let validator: PuzzleValidator

    func isComplete(
        shapes: [PuzzleShape],
        solution: [String: LumonColor]
    ) -> Bool {
        guard !shapes.isEmpty else { return false }
        let revealed = Dictionary(uniqueKeysWithValues: shapes.compactMap { shape in
            shape.color.map { (shape.id, $0) }
        })
        return revealed == solution
            && validator.isValidCompleteBoard(colors: revealed, shapes: shapes)
    }
}
