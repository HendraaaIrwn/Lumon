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
    private nonisolated enum AudioSessionActivationResult: Sendable {
        case activated
        case failed(String)
    }

    static let shared = AudioManager()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Lumon",
        category: "Audio"
    )

    private let bundle: Bundle
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var isEnabled = true
    private var isPreparingAudio = false
    private var didPreparePlayers = false
    private var pendingEffect: SoundEffect?

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        prepareAudioIfNeeded()
    }

    func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        guard didPreparePlayers else {
            pendingEffect = effect
            prepareAudioIfNeeded()
            return
        }
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
            pendingEffect = nil
            players.values.forEach { $0.stop() }
        } else {
            prepareAudioIfNeeded()
        }
    }

    private func prepareAudioIfNeeded() {
        guard !didPreparePlayers, !isPreparingAudio else { return }
        isPreparingAudio = true

        Task { [weak self] in
            await self?.activateAudioSessionAndPreparePlayers()
        }
    }

    private func activateAudioSessionAndPreparePlayers() async {
        let activationResult: AudioSessionActivationResult
        if #available(iOS 27.0, *) {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.ambient)
                activationResult = try await audioSession.activate()
                    ? .activated
                    : .failed("Activation did not succeed")
            } catch {
                activationResult = .failed(error.localizedDescription)
            }
        } else {
            activationResult = await Self.activateLegacyAudioSession()
        }

        guard case .activated = activationResult else {
            isPreparingAudio = false
            if case .failed(let message) = activationResult {
                Self.logger.error("Audio session activation failed: \(message, privacy: .public)")
            }
            return
        }

        preparePlayers()
        didPreparePlayers = true
        isPreparingAudio = false

        if let pendingEffect, isEnabled {
            self.pendingEffect = nil
            play(pendingEffect)
        }
    }

    @concurrent
    private nonisolated static func activateLegacyAudioSession() async -> AudioSessionActivationResult {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient)
            try audioSession.setActive(true)
            return .activated
        } catch {
            return .failed(error.localizedDescription)
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
