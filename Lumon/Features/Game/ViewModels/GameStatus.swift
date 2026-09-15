import Foundation

enum GameStatus: Equatable {
    case playing
    case completed
    case gameOver
}

struct GameFeedbackEvent: Equatable, Identifiable {
    enum Kind: Equatable {
        case correct
        case incorrect
        case hint
        case completed
        case completedByHint
    }

    let id = UUID()
    let shapeID: String?
    let kind: Kind
}
