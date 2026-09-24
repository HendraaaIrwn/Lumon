import SwiftUI

struct RootView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var path: [AppDestination] = []
    @State private var settings = AppSettings()
    @State private var progress = ProgressStore()
    @ScaledMetric(relativeTo: .largeTitle) private var homeWordmarkSize: CGFloat = 68

    var body: some View {
        NavigationStack(path: $path) {
            home
                .navigationDestination(for: AppDestination.self, destination: destination)
        }
        .preferredColorScheme(.dark)
        .tint(LumonPalette.orange)
        .task { AudioManager.shared.setEnabled(settings.isSoundEnabled) }
        .onChange(of: settings.isSoundEnabled) { _, isEnabled in
            AudioManager.shared.setEnabled(isEnabled)
        }
    }

    private var home: some View {
        LumonScreenBackground(variant: .home) {
            GeometryReader { proxy in
                ScrollView {
                    homeMenu
                    .padding(.horizontal, LumonSpacing.lg)
                    .padding(.vertical, LumonSpacing.lg)
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: 468)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private var wordmark: some View {
        Text("LUMON")
            .font(.custom("TiltWarp-Regular", size: homeWordmarkSize, relativeTo: .largeTitle))
            .tracking(-1.4)
            .foregroundStyle(LumonPalette.cream)
            .shadow(color: LumonPalette.ink.opacity(0.85), radius: 3)
            .lineLimit(1)
            .minimumScaleFactor(0.64)
            .accessibilityLabel("LUMON")
    }

    private var homeMenu: some View {
        VStack(spacing: LumonSpacing.xl) {
            wordmark
            homeActions
        }
        .frame(maxWidth: 420)
    }

    private var homeActions: some View {
        VStack(spacing: LumonSpacing.md) {
            Button(action: play) {
                Text("Play")
            }
            .buttonStyle(.lumonHomePrimary)
            .accessibilityLabel("Play")

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: LumonSpacing.sm) {
                    levelSelectLink
                    settingsLink
                }
            } else {
                HStack(spacing: LumonSpacing.md) {
                    levelSelectLink
                    settingsLink
                }
            }
        }
    }

    private var levelSelectLink: some View {
        NavigationLink(value: AppDestination.levelSelect) {
            Label("Level Select", systemImage: "square.grid.2x2.fill")
        }
        .buttonStyle(.lumonHomeSecondary)
        .accessibilityLabel("Level Select")
    }

    private var settingsLink: some View {
        NavigationLink(value: AppDestination.settings) {
            Label("Settings", systemImage: "gearshape.fill")
        }
        .buttonStyle(.lumonHomeSecondary)
        .accessibilityLabel("Settings")
    }

    @ViewBuilder
    private func destination(_ destination: AppDestination) -> some View {
        switch destination {
        case let .game(levelID):
            GameView(
                levelID: levelID,
                progressStore: progress,
                hapticsEnabled: settings.isHapticsEnabled,
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
