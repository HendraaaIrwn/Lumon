import Foundation
import Observation

enum GameTutorialStep: Equatable {
    case selectOuter(remainingCount: Int)
    case chooseRed
    case selectCenter
    case chooseYellow
}

@MainActor
@Observable
final class GameViewModel {
    static let initialLives = 3
    static let initialHints = 6

    private static let tutorialLevelID = "level_001"
    private static let tutorialCenterID = "center"
    private static let tutorialOuterIDs = ["upper_left", "upper_right", "bottom"]

    private let levelID: String
    private let repository: any LevelRepository
    private let audioPlayer: any AudioPlaying
    private let progressStore: ProgressStore
    private let hintManager = HintManager()

    private(set) var level: Level?
    private(set) var shapes: [PuzzleShape] = []
    private(set) var loadingState: GameLoadingState = .idle
    private(set) var selectedShapeID: String?
    private(set) var revealedClueShapeIDs: Set<String> = []
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

    var tutorialStep: GameTutorialStep? {
        guard status == .playing, supportsLevelOneTutorial else { return nil }

        let remainingOuterIDs = Self.tutorialOuterIDs.filter { shapeID in
            shapes.first(where: { $0.id == shapeID })?.color == nil
        }
        if !remainingOuterIDs.isEmpty {
            if let selectedShapeID, remainingOuterIDs.contains(selectedShapeID) {
                return .chooseRed
            }
            return .selectOuter(remainingCount: remainingOuterIDs.count)
        }

        guard shapes.first(where: { $0.id == Self.tutorialCenterID })?.color == nil else {
            return nil
        }
        return selectedShapeID == Self.tutorialCenterID ? .chooseYellow : .selectCenter
    }

    var selectableShapeIDs: Set<String>? {
        guard let tutorialStep else { return nil }
        switch tutorialStep {
        case .selectOuter:
            return Set(Self.tutorialOuterIDs.filter { shapeID in
                shapes.first(where: { $0.id == shapeID })?.color == nil
            })
        case .selectCenter:
            return [Self.tutorialCenterID]
        case .chooseRed, .chooseYellow:
            return []
        }
    }

    var tutorialHighlightedShapeIDs: Set<String> {
        guard let tutorialStep else { return [] }
        switch tutorialStep {
        case .selectOuter, .selectCenter:
            return selectableShapeIDs ?? []
        case .chooseRed, .chooseYellow:
            return Set(selectedShapeID.map { [$0] } ?? [])
        }
    }

    var enabledColors: [LumonColor] {
        guard canAssignColor else { return [] }
        switch tutorialStep {
        case .chooseRed: return [.red]
        case .chooseYellow: return [.yellow]
        case .selectOuter, .selectCenter: return []
        case nil: return availableColors
        }
    }

    var canUseHint: Bool {
        tutorialStep == nil
            && status == .playing
            && hintsRemaining > 0
            && shapes.contains { $0.color == nil }
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
            revealedClueShapeIDs = []
            lives = Self.initialLives
            hintsRemaining = Self.initialHints
            status = .playing
            feedbackEvent = nil
            loadingState = .failed(message: error.localizedDescription)
        }
    }

    func selectShape(id: String) {
        guard shapes.contains(where: { $0.id == id }) else { return }
        if let selectableShapeIDs, !selectableShapeIDs.contains(id) { return }
        selectedShapeID = id
        audioPlayer.play(.tap)
    }

    func assignColor(_ color: LumonColor) {
        guard status == .playing,
              let level,
              let selectedShapeID,
              let index = shapes.firstIndex(where: { $0.id == selectedShapeID }),
              shapes[index].color == nil,
              enabledColors.contains(color) else { return }

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
            revealedClueShapeIDs.insert(selectedShapeID)
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
        revealedClueShapeIDs.insert(reveal.shapeID)
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
        revealedClueShapeIDs = Set(
            level.shapes
                .filter(\.showsCluesInitially)
                .map(\.id)
        )
        lives = Self.initialLives
        hintsRemaining = Self.initialHints
        status = .playing
        feedbackEvent = nil
    }

    private var supportsLevelOneTutorial: Bool {
        guard let level,
              level.id == Self.tutorialLevelID,
              !progressStore.isCompleted(Self.tutorialLevelID),
              level.availableColors.contains(.red),
              level.availableColors.contains(.yellow),
              level.solution[Self.tutorialCenterID] == .yellow,
              Self.tutorialOuterIDs.allSatisfy({ level.solution[$0] == .red }) else {
            return false
        }

        let shapeIDs = Set(level.shapes.map(\.id))
        return shapeIDs.contains(Self.tutorialCenterID)
            && Self.tutorialOuterIDs.allSatisfy(shapeIDs.contains)
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
