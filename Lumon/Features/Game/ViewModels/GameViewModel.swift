import Foundation
import Observation

@MainActor
@Observable
final class GameViewModel {
    static let initialLives = 3
    static let initialHints = 6

    private let levelID: String
    private let repository: any LevelRepository
    private let audioPlayer: any AudioPlaying
    private let progressStore: ProgressStore
    private let hintManager = HintManager()

    private(set) var level: Level?
    private(set) var shapes: [PuzzleShape] = []
    private(set) var loadingState: GameLoadingState = .idle
    private(set) var selectedShapeID: String?
    private(set) var lives = initialLives
    private(set) var hintsRemaining = initialHints
    private(set) var status: GameStatus = .playing
    private(set) var feedbackEvent: GameFeedbackEvent?
    private var activeLoadID: UUID?

    var availableColors: [LumonColor] {
        level?.availableColors.filter { $0 != .black } ?? []
    }

    var canAssignColor: Bool {
        guard status == .playing,
              let selectedShapeID,
              let shape = shapes.first(where: { $0.id == selectedShapeID }) else {
            return false
        }
        return shape.color == nil
    }

    var canUseHint: Bool {
        status == .playing && hintsRemaining > 0 && shapes.contains { $0.color == nil }
    }

    init(
        levelID: String,
        repository: any LevelRepository = BundleLevelRepository(),
        audioPlayer: any AudioPlaying = AudioManager.shared,
        progressStore: ProgressStore
    ) {
        self.levelID = levelID
        self.repository = repository
        self.audioPlayer = audioPlayer
        self.progressStore = progressStore
    }

    func load() async {
        let requestID = UUID()
        activeLoadID = requestID
        loadingState = .loading
        do {
            let loadedLevel = try await repository.level(id: levelID)
            try Task.checkCancellation()
            guard activeLoadID == requestID else { return }
            level = loadedLevel
            startSession(from: loadedLevel)
            loadingState = .loaded
        } catch is CancellationError {
            return
        } catch {
            guard activeLoadID == requestID else { return }
            level = nil
            shapes = []
            selectedShapeID = nil
            lives = Self.initialLives
            hintsRemaining = Self.initialHints
            status = .playing
            feedbackEvent = nil
            loadingState = .failed(message: error.localizedDescription)
        }
    }

    func selectShape(id: String) {
        guard shapes.contains(where: { $0.id == id }) else { return }
        selectedShapeID = id
        audioPlayer.play(.tap)
    }

    func assignColor(_ color: LumonColor) {
        guard status == .playing,
              let level,
              let selectedShapeID,
              let index = shapes.firstIndex(where: { $0.id == selectedShapeID }),
              shapes[index].color == nil else { return }

        let validator: PuzzleValidator
        do {
            validator = PuzzleValidator(graph: try NeighborGraph(shapes: shapes))
        } catch {
            return
        }

        switch validator.validateAnswer(
            shapeID: selectedShapeID,
            color: color,
            solution: level.solution,
            availableColors: level.availableColors
        ) {
        case .correct:
            shapes[index].color = color
            completeIfNeeded(
                using: validator,
                shapeID: selectedShapeID,
                fallback: .correct,
                completion: .completed
            )
        case .incorrect:
            lives -= 1
            if lives == 0 {
                status = .gameOver
            }
            feedbackEvent = GameFeedbackEvent(shapeID: selectedShapeID, kind: .incorrect)
            audioPlayer.play(.wrong)
        case .invalidInput:
            return
        }
    }

    func useHint() {
        guard let level, canUseHint,
              let reveal = hintManager.reveal(
                selectedShapeID: selectedShapeID,
                shapes: shapes,
                solution: level.solution
              ),
              let index = shapes.firstIndex(where: { $0.id == reveal.shapeID }) else { return }

        shapes[index].color = reveal.color
        selectedShapeID = reveal.shapeID
        hintsRemaining -= 1

        guard let graph = try? NeighborGraph(shapes: shapes) else { return }
        completeIfNeeded(
            using: PuzzleValidator(graph: graph),
            shapeID: reveal.shapeID,
            fallback: .hint,
            completion: .completedByHint
        )
    }

    func reset() {
        guard let level else { return }
        audioPlayer.play(.tap)
        startSession(from: level)
    }

    private func startSession(from level: Level) {
        shapes = level.shapes.map { shape in
            var hiddenShape = shape
            hiddenShape.color = nil
            return hiddenShape
        }
        selectedShapeID = nil
        lives = Self.initialLives
        hintsRemaining = Self.initialHints
        status = .playing
        feedbackEvent = nil
    }

    private func completeIfNeeded(
        using validator: PuzzleValidator,
        shapeID: String,
        fallback: GameFeedbackEvent.Kind,
        completion: GameFeedbackEvent.Kind
    ) {
        guard let level else { return }
        let kind: GameFeedbackEvent.Kind
        if GameCompletionChecker(validator: validator).isComplete(
            shapes: shapes,
            solution: level.solution
        ) {
            status = .completed
            progressStore.markCompleted(levelID)
            kind = completion
        } else {
            kind = fallback
        }
        feedbackEvent = GameFeedbackEvent(shapeID: shapeID, kind: kind)

        switch kind {
        case .correct, .hint:
            audioPlayer.play(.correct)
        case .completed, .completedByHint:
            audioPlayer.play(.complete)
        case .incorrect:
            audioPlayer.play(.wrong)
        }
    }
}
