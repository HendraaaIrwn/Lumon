import SwiftUI

struct RootView: View {
    @State private var path: [AppDestination] = []
    @State private var settings = AppSettings()
    @State private var progress = ProgressStore()

    var body: some View {
        NavigationStack(path: $path) {
            home
                .navigationDestination(for: AppDestination.self, destination: destination)
        }
        .preferredColorScheme(.light)
        .task { AudioManager.shared.setEnabled(settings.isSoundEnabled) }
        .onChange(of: settings.isSoundEnabled) { _, isEnabled in
            AudioManager.shared.setEnabled(isEnabled)
        }
    }

    private var home: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 10) {
                Text("LUMON")
                    .font(.largeTitle.weight(.heavy))
                    .fontDesign(.rounded)
                    .tracking(8)
                Text("Reveal the hidden colors.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 20) {
                Button("PLAY", action: play)
                    .font(.title3.weight(.semibold))
                    .tracking(3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.black, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 40)

                HStack(spacing: 36) {
                    NavigationLink("Level Select", value: AppDestination.levelSelect)
                    NavigationLink("Settings", value: AppDestination.settings)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.bottom, 56)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.97))
    }

    @ViewBuilder
    private func destination(_ destination: AppDestination) -> some View {
        switch destination {
        case .game(let levelID):
            GameView(
                levelID: levelID,
                progressStore: progress,
                onNextLevel: { replaceCurrent(with: .game(levelID: $0)) },
                onShowLevelSelect: { replaceCurrent(with: .levelSelect) },
                onHome: { path.removeAll() }
            )
            .id(levelID)
        case .levelSelect:
            LevelSelectView(progressStore: progress) { levelID in
                path.append(.game(levelID: levelID))
            }
        case .settings:
            SettingsView(settings: settings, progressStore: progress)
        }
    }

    private func play() {
        if let levelID = progress.firstUnfinishedLevelID {
            path.append(.game(levelID: levelID))
        } else {
            path.append(.levelSelect)
        }
    }

    private func replaceCurrent(with destination: AppDestination) {
        guard !path.isEmpty else {
            path.append(destination)
            return
        }
        path[path.count - 1] = destination
    }
}

#Preview {
    RootView()
}
