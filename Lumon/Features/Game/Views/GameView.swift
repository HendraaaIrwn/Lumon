import SwiftUI

struct GameView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GameViewModel
    @State private var retryID = 0

    private let levelID: String
    private let progressStore: ProgressStore
    private let onNextLevel: (String) -> Void
    private let onShowLevelSelect: () -> Void
    private let onHome: () -> Void

    init(
        levelID: String,
        progressStore: ProgressStore,
        onNextLevel: @escaping (String) -> Void,
        onShowLevelSelect: @escaping () -> Void,
        onHome: @escaping () -> Void
    ) {
        self.levelID = levelID
        self.progressStore = progressStore
        self.onNextLevel = onNextLevel
        self.onShowLevelSelect = onShowLevelSelect
        self.onHome = onHome
        _viewModel = State(initialValue: GameViewModel(levelID: levelID, progressStore: progressStore))
    }

    var body: some View {
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
        .background(Color(white: 0.97))
        .navigationTitle(viewModel.level?.metadata.title ?? "LUMON")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: viewModel.selectedShapeID)
        .sensoryFeedback(trigger: viewModel.feedbackEvent) { _, _ in
            sensoryFeedback(for: viewModel.feedbackEvent)
        }
        .task(id: retryID) { await viewModel.load() }
    }

    private var gameContent: some View {
        VStack(spacing: 18) {
            resourceBar
            GameBoardView(
                shapes: viewModel.shapes,
                selectedShapeID: viewModel.selectedShapeID,
                feedbackEvent: viewModel.feedbackEvent,
                onSelectShape: viewModel.selectShape
            )
            .frame(maxHeight: .infinity)
            .modifier(CompletionBoardAnimation(trigger: completionTrigger, isEnabled: !reduceMotion))

            ColorPickerView(
                colors: viewModel.availableColors,
                isEnabled: viewModel.canAssignColor,
                onSelectColor: viewModel.assignColor
            )
            actionBar
            if viewModel.status != .playing { terminalPanel.transition(.scale.combined(with: .opacity)) }
        }
        .padding(20)
        .animation(reduceMotion ? nil : .spring(duration: 0.35), value: viewModel.status)
    }

    private var completionTrigger: UUID? {
        switch viewModel.feedbackEvent?.kind {
        case .completed, .completedByHint: viewModel.feedbackEvent?.id
        default: nil
        }
    }

    private var resourceBar: some View {
        HStack {
            Label("\(viewModel.lives)", systemImage: "heart.fill")
                .foregroundStyle(.red)
                .accessibilityLabel("\(viewModel.lives) lives remaining")
            Spacer()
            Label("\(viewModel.hintsRemaining)", systemImage: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .accessibilityLabel("\(viewModel.hintsRemaining) hints remaining")
        }
        .font(.headline)
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button { viewModel.useHint() } label: {
                Label("Hint", systemImage: "lightbulb").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canUseHint)

            Button { viewModel.reset() } label: {
                Label("Reset", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var terminalPanel: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.status == .completed ? "sparkles" : "heart.slash")
                .font(.title)
            Text(terminalTitle).font(.title2.bold())

            if viewModel.status == .completed,
               let nextLevelID = progressStore.nextLevelID(after: levelID) {
                Button("Next Level") { onNextLevel(nextLevelID) }
                    .buttonStyle(.borderedProminent)
            } else if viewModel.status == .completed {
                Button("Level Select", action: onShowLevelSelect)
                    .buttonStyle(.borderedProminent)
            }

            HStack {
                Button("Replay") { viewModel.reset() }
                Spacer()
                Button("Home", action: onHome)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var terminalTitle: String {
        guard viewModel.status == .completed else { return "Game Over" }
        return progressStore.nextLevelID(after: levelID) == nil
            ? "All Levels Completed"
            : "Level Completed"
    }

    private func sensoryFeedback(for event: GameFeedbackEvent?) -> SensoryFeedback? {
        switch event?.kind {
        case .correct, .hint, .completed, .completedByHint: .success
        case .incorrect: .error
        case nil: nil
        }
    }
}
