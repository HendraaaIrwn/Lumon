import AVFoundation
import Foundation
import OSLog

nonisolated enum SoundEffect: String, CaseIterable, Sendable {
    case tap
    case correct
    case wrong
    case complete
}

@MainActor
protocol AudioPlaying: AnyObject {
    func play(_ effect: SoundEffect)
    func setEnabled(_ isEnabled: Bool)
}

@MainActor
final class AudioManager: AudioPlaying {
    static let shared = AudioManager()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Lumon",
        category: "Audio"
    )

    private let bundle: Bundle
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var isEnabled = true

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        configureAudioSession()
        preparePlayers()
    }

    func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        guard let player = players[effect] else {
            Self.logger.error("Sound resource unavailable: \(effect.rawValue, privacy: .public)")
            return
        }

        player.currentTime = 0
        if !player.play() {
            Self.logger.error("Sound playback did not start: \(effect.rawValue, privacy: .public)")
        }
    }

    func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        if !isEnabled {
            players.values.forEach { $0.stop() }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch {
            Self.logger.error(
                "Audio session configuration failed: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private func preparePlayers() {
        for effect in SoundEffect.allCases {
            guard let url = bundle.url(
                forResource: effect.rawValue,
                withExtension: "wav",
                subdirectory: "Audio"
            ) ?? bundle.url(forResource: effect.rawValue, withExtension: "wav") else {
                Self.logger.error("Missing sound resource: \(effect.rawValue, privacy: .public).wav")
                continue
            }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                if !player.prepareToPlay() {
                    Self.logger.error(
                        "Sound resource could not be prepared: \(effect.rawValue, privacy: .public)"
                    )
                }
                players[effect] = player
            } catch {
                Self.logger.error(
                    "Sound resource failed to load: \(effect.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)"
                )
            }
        }
    }
}
