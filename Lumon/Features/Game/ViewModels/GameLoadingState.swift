import Foundation

enum GameLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case failed(message: String)
}
