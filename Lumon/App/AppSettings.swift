import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    private enum Key {
        static let soundEnabled = "lumon.settings.soundEnabled"
        static let hapticsEnabled = "lumon.settings.hapticsEnabled"
    }

    private let defaults: UserDefaults
    var isSoundEnabled: Bool {
        didSet {
            defaults.set(isSoundEnabled, forKey: Key.soundEnabled)
        }
    }

    var isHapticsEnabled: Bool {
        didSet {
            defaults.set(isHapticsEnabled, forKey: Key.hapticsEnabled)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isSoundEnabled = defaults.object(forKey: Key.soundEnabled) as? Bool ?? true
        isHapticsEnabled = defaults.object(forKey: Key.hapticsEnabled) as? Bool ?? true
    }
}
