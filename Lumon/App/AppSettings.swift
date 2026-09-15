import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    private enum Key {
        static let soundEnabled = "lumon.settings.soundEnabled"
    }

    private let defaults: UserDefaults
    var isSoundEnabled: Bool {
        didSet {
            defaults.set(isSoundEnabled, forKey: Key.soundEnabled)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isSoundEnabled = defaults.object(forKey: Key.soundEnabled) as? Bool ?? true
    }
}
