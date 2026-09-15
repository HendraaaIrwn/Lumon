import Foundation

enum AppDestination: Hashable {
    case game(levelID: String)
    case levelSelect
    case settings
}
