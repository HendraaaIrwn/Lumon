# LUMON

Native SwiftUI color-logic puzzle for iOS 26.5 and later.

## MVP

- Ten sequential JSON levels
- Immediate answer validation, three lives, and six hints per session
- Progressive clues with a solver-proven no-guess path
- Local completion progress with Level Select and Next Level
- Persistent sound setting and progress reset
- Native sound, haptic feedback, and reduced-motion-aware animations

## Build

```bash
rtk proxy xcodebuild -project Lumon.xcodeproj -scheme Lumon -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Use `Release` in place of `Debug` for the release build gate.

## Regenerate Levels 2–10

Run from the repository root:

```bash
rtk proxy swiftc -parse-as-library -o /tmp/lumon-level-author \
  Tools/LevelAuthoring/generate_levels.swift \
  Lumon/Domain/Models/ArtworkTemplate.swift \
  Lumon/Domain/Models/ColorClue.swift \
  Lumon/Domain/Models/Level.swift \
  Lumon/Domain/Models/LevelMetadata.swift \
  Lumon/Domain/Models/LumonColor.swift \
  Lumon/Domain/Models/NormalizedPoint.swift \
  Lumon/Domain/Models/NormalizedSize.swift \
  Lumon/Domain/Models/PuzzleShape.swift \
  Lumon/Domain/Models/ShapeType.swift \
  Lumon/Domain/Algorithms/LevelGenerator.swift \
  Lumon/Domain/Algorithms/HintCircleLayout.swift \
  Lumon/Domain/Algorithms/LevelValidator.swift \
  Lumon/Domain/Algorithms/ProgressiveClueRules.swift \
  Lumon/Domain/Algorithms/NeighborGraph.swift \
  Lumon/Domain/Algorithms/PuzzleSolver.swift \
  Lumon/Domain/Algorithms/PuzzleValidator.swift \
  Lumon/Data/JSON/LevelExporter.swift
rtk proxy /tmp/lumon-level-author
```

The authoring command uses deterministic seeds. Export fails unless the
production validator proves exactly one solution that matches the hidden
answer, a progressive no-guess deduction path, and readable hint-circle
placement fully inside each clue-bearing shape at the 240-point board minimum.

Use `Tools/LevelAuthoring/configure_progressive_levels.swift` with the same
model, validator, solver, and exporter sources to rebalance existing levels.
Pass `--validate-only` to validate the bundled catalog without rewriting it.

## Verification boundary

The project still has no XCTest target. The progressive authoring utility
provides catalog validation and focused compatibility checks through
`--validate-only` and `--self-test`. Debug/Release builds and simulator smoke
testing remain the release gates for gameplay and animation behavior.
