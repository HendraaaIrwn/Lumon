import SwiftUI

struct GameView: View {
    @State private var viewModel: GameViewModel

    init(levelID: String) {
        _viewModel = State(initialValue: GameViewModel(levelID: levelID))
    }

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView("Loading level…")
            case .loaded:
                if let level = viewModel.level {
                    GameBoardView(
                        shapes: level.shapes,
                        selectedShapeID: viewModel.selectedShapeID,
                        onSelectShape: viewModel.selectShape
                    )
                    .padding(20)
                }
            case .failed(let message):
                LevelLoadErrorView(message: message, retry: viewModel.load)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.97))
        .navigationTitle(viewModel.level?.metadata.title ?? "LUMON")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.loadingState == .idle {
                viewModel.load()
            }
        }
    }
}
