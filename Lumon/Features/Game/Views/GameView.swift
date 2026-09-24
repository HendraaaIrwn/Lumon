import SwiftUI

struct GameView: View {
    private enum PresentationPhase {
        case playing
        case celebrating
        case result
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GameViewModel
    @State private var retryID = 0
    @State private var presentationPhase: PresentationPhase = .playing
    @State private var appearedShapeIDs: Set<String> = []
    @AccessibilityFocusState private var terminalFocused: Bool

    private let levelID: String
    private let progressStore: ProgressStore
    private let hapticsEnabled: Bool
    private let onNextLevel: (String) -> Void
    private let onShowLevelSelect: () -> Void
    private let onHome: () -> Void

    init(
        levelID: String,
        progressStore: ProgressStore,
        hapticsEnabled: Bool = true,
        onNextLevel: @escaping (String) -> Void,
        onShowLevelSelect: @escaping () -> Void,
        onHome: @escaping () -> Void
    ) {
        self.levelID = levelID
        self.progressStore = progressStore
        self.hapticsEnabled = hapticsEnabled
        self.onNextLevel = onNextLevel
        self.onShowLevelSelect = onShowLevelSelect
        self.onHome = onHome
        _viewModel = State(initialValue: GameViewModel(levelID: levelID, progressStore: progressStore))
    }

    var body: some View {
        LumonScreenBackground(variant: .game) {
            VStack(spacing: 0) {
                if case .loaded = viewModel.loadingState, let level = viewModel.level {
                    GameHUD(order: level.metadata.order, title: level.metadata.title,
                            lives: viewModel.lives, showLives: viewModel.status == .playing)
                } else {
                    LumonNavigationHeader(title: "LUMON")
                }

                Group {
                    switch viewModel.loadingState {
                    case .idle, .loading:
                        LevelLoadingView()
                    case .loaded:
                        if viewModel.level != nil { gameContent }
                    case .failed(let message):
                        LevelLoadErrorView(message: message) { retryID += 1 }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sensoryFeedback(trigger: viewModel.selectedShapeID) { _, _ in
            hapticsEnabled ? .selection : nil
        }
        .sensoryFeedback(trigger: viewModel.feedbackEvent) { _, _ in
            hapticsEnabled ? sensoryFeedback(for: viewModel.feedbackEvent) : nil
        }
        .task(id: retryID) { await viewModel.load() }
        .task(id: completionTrigger) { await presentCompletion() }
        .onChange(of: viewModel.status) { _, status in
            if status == .playing {
                presentationPhase = .playing
                terminalFocused = false
            } else if status == .gameOver {
                presentationPhase = .result
                terminalFocused = true
            }
        }
        .onChange(of: reduceMotion) { _, isReduced in
            if isReduced { appearedShapeIDs = Set(viewModel.shapes.map(\.id)) }
        }
    }

    private var gameContent: some View {
        GeometryReader { proxy in
            let wide = proxy.size.width >= 700 ||
                (proxy.size.width > proxy.size.height * 1.25 && proxy.size.height < 600)

            ScrollView {
                if wide {
                    wideContent(in: proxy.size)
                } else {
                    portraitContent(in: proxy.size)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func portraitContent(in size: CGSize) -> some View {
        let spaceForBoard = size.height - (viewModel.status == .playing ? 202.0 : 178.0)
        let boardSize = min(size.width - 48, max(220, spaceForBoard))

        return VStack(spacing: 0) {
            Spacer(minLength: 8)
            boardView.frame(width: boardSize, height: boardSize)
            Spacer(minLength: 12)
            controlSurface.frame(maxWidth: 460)
            Spacer(minLength: 16)
        }
        .padding(.horizontal, LumonSpacing.lg)
        .frame(maxWidth: .infinity)
        .frame(minHeight: size.height)
    }

    private func wideContent(in size: CGSize) -> some View {
        let sideWidth = min(340, max(260, size.width * 0.34))
        let boardSize = min(640, size.height - 32, size.width - 80 - sideWidth)

        return HStack(spacing: LumonSpacing.xl) {
            boardView.frame(width: max(220, boardSize), height: max(220, boardSize))
            controlSurface.frame(width: sideWidth)
        }
        .padding(.horizontal, LumonSpacing.lg)
        .frame(maxWidth: 1080)
        .frame(maxWidth: .infinity, minHeight: size.height)
    }

    private var boardView: some View {
        GameBoardView(
            shapes: viewModel.shapes,
            selectedShapeID: viewModel.status == .playing ? viewModel.selectedShapeID : nil,
            revealedClueShapeIDs: viewModel.revealedClueShapeIDs,
            selectableShapeIDs: viewModel.status == .playing ? viewModel.selectableShapeIDs : nil,
            tutorialHighlightedShapeIDs: viewModel.status == .playing
                ? viewModel.tutorialHighlightedShapeIDs : [],
            feedbackEvent: viewModel.feedbackEvent,
            onSelectShape: viewModel.selectShape,
            completionTrigger: completionTrigger,
            reduceMotion: reduceMotion,
            visibleShapeIDs: appearedShapeIDs
        )
        .aspectRatio(1, contentMode: .fit)
        .allowsHitTesting(viewModel.status == .playing)
        .accessibilityHidden(viewModel.status != .playing)
        .modifier(CompletionBoardAnimation(trigger: completionTrigger, isEnabled: !reduceMotion))
        .overlay {
            GameCelebrationAccents(trigger: completionTrigger, reduceMotion: reduceMotion)
        }
        .task(id: viewModel.level?.id) { await revealShapesOnEntry() }
    }

    @ViewBuilder
    private var controlSurface: some View {
        if viewModel.status == .playing {
            VStack(spacing: LumonSpacing.md) {
                if let tutorialStep = viewModel.tutorialStep {
                    let copy = tutorialCopy(for: tutorialStep)
                    GameInstruction(title: copy.title, message: copy.message, isTutorial: true)
                } else {
                    GameInstruction(
                        title: viewModel.canAssignColor ? "CHOOSE A COLOR" : "SELECT A SHAPE",
                        message: viewModel.canAssignColor
                            ? "Match the selected shape to its clues."
                            : "Tap a shape to reveal your choices.",
                        isTutorial: false
                    )
                }

                ColorPickerView(
                    colors: viewModel.availableColors,
                    enabledColors: viewModel.enabledColors,
                    onSelectColor: viewModel.assignColor
                )
                GameActions(
                    hints: viewModel.hintsRemaining,
                    canUseHint: viewModel.canUseHint,
                    onHint: viewModel.useHint,
                    onReset: resetGame
                )
            }
        } else if presentationPhase == .result {
            GameResult(
                isComplete: viewModel.status == .completed,
                isFinalLevel: nextLevelID == nil,
                onPrimary: primaryResultAction,
                onReplay: resetGame,
                onHome: onHome
            )
            .accessibilityFocused($terminalFocused)
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
        } else {
            Color.clear.frame(height: 120)
        }
    }

    private var nextLevelID: String? { progressStore.nextLevelID(after: levelID) }

    private var completionTrigger: UUID? {
        switch viewModel.feedbackEvent?.kind {
        case .completed, .completedByHint: viewModel.feedbackEvent?.id
        default: nil
        }
    }

    private func presentCompletion() async {
        guard completionTrigger != nil else { return }
        presentationPhase = .celebrating
        if !reduceMotion {
            try? await Task.sleep(for: .milliseconds(850))
        }
        guard !Task.isCancelled, viewModel.status == .completed else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.24)) {
            presentationPhase = .result
        }
        terminalFocused = true
    }

    private func revealShapesOnEntry() async {
        let shapeIDs = viewModel.shapes.map(\.id)
        guard !shapeIDs.isEmpty else { return }
        let allIDs = Set(shapeIDs)
        guard !allIDs.isSubset(of: appearedShapeIDs) else { return }
        if reduceMotion {
            appearedShapeIDs = allIDs
            return
        }

        let stepMilliseconds = min(110, max(45, 660 / shapeIDs.count))
        for shapeID in shapeIDs {
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.26)) {
                _ = appearedShapeIDs.insert(shapeID)
            }
            try? await Task.sleep(for: .milliseconds(stepMilliseconds))
        }
    }

    private func primaryResultAction() {
        if viewModel.status == .gameOver {
            resetGame()
        } else if let nextLevelID {
            onNextLevel(nextLevelID)
        } else {
            onShowLevelSelect()
        }
    }

    private func resetGame() {
        presentationPhase = .playing
        viewModel.reset()
    }

    private func tutorialCopy(for step: GameTutorialStep) -> (title: String, message: String) {
        switch step {
        case .selectOuter(let remainingCount):
            let noun = remainingCount == 1 ? "triangle" : "triangles"
            return ("READ THE CLUES", "\(remainingCount) red \(noun) remaining. Tap a triangle.")
        case .chooseRed:
            return ("CHOOSE RED", "Use the red color shown by the center clue.")
        case .selectCenter:
            return ("READ THE CLUES", "The yellow dots point to the center. Tap the center piece.")
        case .chooseYellow:
            return ("CHOOSE YELLOW", "Color the center piece to finish the tutorial.")
        }
    }

    private func sensoryFeedback(for event: GameFeedbackEvent?) -> SensoryFeedback? {
        switch event?.kind {
        case .correct, .hint, .completed, .completedByHint: .success
        case .incorrect: .error
        case nil: nil
        }
    }
}
