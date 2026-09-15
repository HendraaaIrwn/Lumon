import Foundation

nonisolated enum LevelLoaderError: LocalizedError, Sendable {
    case resourceNotFound(String)
    case unreadableData(String, any Error)
    case decodingFailed(String, any Error)
    case invalidLevel([String])

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let id):
            "Level \(id) could not be found."
        case .unreadableData(let id, _):
            "Level \(id) could not be read."
        case .decodingFailed(let id, _):
            "Level \(id) contains invalid JSON."
        case .invalidLevel(let issues):
            "The level is invalid: \(issues.joined(separator: " "))"
        }
    }
}
