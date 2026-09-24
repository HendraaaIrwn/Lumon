import SwiftUI

/// Small, deterministic fixtures used by Xcode previews. These values are
/// intentionally independent of the production level loader so a visual
/// review can still run while a level file is being edited.
@MainActor
enum LumonPreviewFixtures {
    static let levelIDs = (1...10).map { String(format: "level_%03d", $0) }

    static func progressStore(completed: [String] = ["level_001", "level_002"]) -> ProgressStore {
        let suite = "LumonPreview.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let store = ProgressStore(levelIDs: levelIDs, defaults: defaults)
        completed.forEach { store.markCompleted($0) }
        return store
    }

    static func settings() -> AppSettings {
        AppSettings(
            defaults: UserDefaults(suiteName: "LumonPreview.Settings.\(UUID().uuidString)")!
        )
    }

    static func shape(
        id: String = "preview-shape",
        type: ShapeType = .triangle,
        color: LumonColor? = nil,
        clues: [ColorClue] = [],
        rotation: Double = 0,
        neighbors: [String] = []
    ) -> PuzzleShape {
        PuzzleShape(
            id: id,
            type: type,
            position: NormalizedPoint(x: 0.5, y: 0.5),
            rotation: rotation,
            size: NormalizedSize(width: 0.62, height: 0.62),
            points: type == .polygon
                ? [
                    NormalizedPoint(x: 0.08, y: 0.52),
                    NormalizedPoint(x: 0.28, y: 0.10),
                    NormalizedPoint(x: 0.72, y: 0.16),
                    NormalizedPoint(x: 0.92, y: 0.56),
                    NormalizedPoint(x: 0.56, y: 0.90),
                ]
                : [],
            color: color,
            neighbors: neighbors,
            clues: clues
        )
    }

    static func clues(_ colors: [LumonColor]) -> [ColorClue] {
        colors.map(ColorClue.init(color:))
    }
}

#Preview("Home") {
    RootView()
}

#Preview("Level Select – Mixed States") {
    LevelSelectView(progressStore: LumonPreviewFixtures.progressStore()) { _ in }
}

#Preview("Settings") {
    SettingsView(
        settings: LumonPreviewFixtures.settings(),
        progressStore: LumonPreviewFixtures.progressStore()
    )
}

#Preview("Loading") {
    LumonScreenBackground {
        LevelLoadingView()
    }
}

#Preview("Load Error") {
    LumonScreenBackground {
        LevelLoadErrorView(message: "The level file could not be read.") {}
    }
}

#Preview("Puzzle States") {
    HStack(spacing: LumonSpacing.lg) {
        PuzzleShapeView(
            shape: LumonPreviewFixtures.shape(id: "selected"),
            isSelected: true,
            areCluesVisible: false,
            isEnabled: true,
            isTutorialTarget: false,
            feedbackEvent: nil,
            onSelect: {}
        )
        .frame(width: 120, height: 120)

        PuzzleShapeView(
            shape: LumonPreviewFixtures.shape(
                id: "clued",
                type: .polygon,
                clues: LumonPreviewFixtures.clues([.red, .yellow, .blue, .blue]),
                rotation: 16
            ),
            isSelected: false,
            areCluesVisible: true,
            isEnabled: true,
            isTutorialTarget: true,
            feedbackEvent: nil,
            onSelect: {}
        )
        .frame(width: 150, height: 120)
    }
    .padding(LumonSpacing.lg)
    .background(LumonPalette.background)
}

#Preview("Clue Counts") {
    LumonScreenBackground {
        VStack(spacing: LumonSpacing.md) {
            ForEach(0...4, id: \.self) { count in
                HStack(spacing: LumonSpacing.md) {
                    Text("\(count)")
                        .lumonTextStyle(.label)
                        .frame(width: 20)

                    ClueDotsView(
                        clues: LumonPreviewFixtures.clues(Array([LumonColor.red, .yellow, .blue, .red].prefix(count))),
                        shape: LumonShape(type: .square, points: [], rotation: 0),
                        differentiateWithoutColor: false
                    )
                    .frame(width: 116, height: 44)
                    .background(LumonPalette.ink)
                }
            }
        }
        .padding(LumonSpacing.lg)
    }
}

#Preview("Narrow Polygon Hint Circles") {
    HStack(spacing: LumonSpacing.xl) {
        PuzzleShapeView(
            shape: PuzzleShape(
                id: "shape_12-preview",
                type: .polygon,
                position: .center,
                size: NormalizedSize(width: 0.08861, height: 0.15511),
                points: [
                    NormalizedPoint(x: 1, y: 0),
                    NormalizedPoint(x: 0.00352, y: 1),
                    NormalizedPoint(x: 0, y: 0.32672),
                ],
                clues: LumonPreviewFixtures.clues([.red, .blue, .blue])
            ),
            isSelected: false,
            areCluesVisible: true,
            isEnabled: true,
            isTutorialTarget: false,
            feedbackEvent: nil,
            onSelect: {}
        )
        .frame(width: 43, height: 74)

        PuzzleShapeView(
            shape: PuzzleShape(
                id: "shape_13-preview",
                type: .polygon,
                position: .center,
                size: NormalizedSize(width: 0.09069, height: 0.15387),
                points: [
                    NormalizedPoint(x: 0.99739, y: 1),
                    NormalizedPoint(x: 0, y: 0),
                    NormalizedPoint(x: 1, y: 0.33659),
                ],
                clues: LumonPreviewFixtures.clues([.yellow, .yellow, .blue])
            ),
            isSelected: false,
            areCluesVisible: true,
            isEnabled: true,
            isTutorialTarget: false,
            feedbackEvent: nil,
            onSelect: {}
        )
        .frame(width: 44, height: 74)
    }
    .padding(LumonSpacing.xl)
    .background(LumonPalette.background)
}

#Preview("Game – Tutorial") {
    GameView(
        levelID: "level_001",
        progressStore: LumonPreviewFixtures.progressStore(completed: []),
        onNextLevel: { _ in },
        onShowLevelSelect: {},
        onHome: {}
    )
}
