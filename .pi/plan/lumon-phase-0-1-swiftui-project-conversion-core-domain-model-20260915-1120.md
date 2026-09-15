# LUMON — Phase 0–1 Implementation Plan

**Source of truth:** the 4 docs in `Lumon/Docs/` (Atomic Task List, Technical Design, Puzzle Rule Spec, GDD).
**Scope:** Phase 0 (TASK-001…003) + Phase 1 (TASK-004…007). Nothing beyond.

## Current State (verified)

- `Lumon.xcodeproj` exists (Xcode 26.6, objectVersion 77, **filesystem-synchronized groups** — new files/folders under `Lumon/` auto-join the target, no per-file pbxproj edits needed).
- It is a **SpriteKit/UIKit Game template**: `AppDelegate.swift`, `SceneDelegate.swift`, `GameViewController.swift`, `GameScene.swift`, `Main.storyboard`, `Actions.sks`, `GameScene.sks` — all contrary to the docs (SwiftUI app required).
- `SWIFT_VERSION = 5.0` (docs require Swift 6). Already set: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`, deployment target iOS 26.5 (docs: iOS 26+ ✓), bundle ID configured ✓.
- Info.plist references a `SceneDelegate` + `Main` storyboard and a launch-screen color "Black" that doesn't exist in the asset catalog.
- Scheme `Lumon` exists; Xcode 26.6 + iPhone 17 Pro simulator available; git repo (SpriteKit files already committed).

---

## Phase 0 — Project Initialization

### TASK-001 — Convert project to SwiftUI / Swift 6 (TASK-001 "Create Xcode Project" reinterpreted as conversion, since the project already exists)

**Delete (SpriteKit template leftovers):**
- `Lumon/AppDelegate.swift`, `Lumon/SceneDelegate.swift`, `Lumon/GameViewController.swift`, `Lumon/GameScene.swift`
- `Lumon/Base.lproj/Main.storyboard` (whole folder), `Lumon/Actions.sks`, `Lumon/GameScene.sks`

**Edit `Lumon.xcodeproj/project.pbxproj`** (3 deterministic string edits, applied to both Debug & Release target configs):
1. `SWIFT_VERSION = 5.0;` → `SWIFT_VERSION = 6.0;` (Swift 6 language mode; approachable-concurrency settings already present = "Observation framework support" per TASK-001)
2. Remove `INFOPLIST_KEY_UIMainStoryboardFile = Main;` (storyboard deleted)
3. Add the 4 `Docs/*.md` files to the synchronized group `membershipExceptions` so design docs aren't copied into the app bundle

**Rewrite `Lumon/Info.plist`** for pure SwiftUI lifecycle:
- `UIApplicationSceneManifest` → keep only `UIApplicationSupportsMultipleScenes = false` (no scene delegate class, no storyboard)
- `UILaunchScreen` → empty `<dict/>` (removes the missing "Black" color reference)

### TASK-002 — Folder structure (per TDD §2 / tech doc structure)

Create under `Lumon/` (`.gitkeep` in each empty folder so git tracks them; Xcode auto-syncs them as groups):

```
Lumon/
├── App/                  ← LUMONApp.swift, RootView.swift
├── Features/
│   ├── Game/  ├── Level/  ├── Puzzle/  └── Settings/
├── Domain/
│   ├── Models/           ← Phase 1 model files
│   ├── UseCases/  └── Algorithms/
├── Data/JSON/
├── Core/Animation/  Core/Audio/  Core/Utilities/
└── Resources/
```

`Assets.xcassets`, `Docs/`, `Info.plist` stay where they are.

### TASK-003 — App entry point

**`Lumon/App/LUMONApp.swift`**
```swift
import SwiftUI

@main
struct LUMONApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}
```

**`Lumon/App/RootView.swift`** — empty home screen (GDD §12 Home / §11 Apple-minimal style: white background, strong whitespace):
- "LUMON" wordmark (`.rounded`, heavy), tagline "Reveal the hidden colors."
- Placeholder `PLAY` button + Level Select / Settings placeholders — **no navigation logic yet** (later phases). Includes `#Preview`.
- Acceptance: app launches and shows this screen.

---

## Phase 1 — Core Domain Model (`Lumon/Domain/Models/`, pure Foundation, no UI imports)

All types: `nonisolated` (opts out of default MainActor isolation so the Phase 9 solver can use them later) + `Sendable` + `Codable` with JSON raw values matching tech doc §8.

### TASK-004 — `LumonColor.swift`
```swift
nonisolated enum LumonColor: String, Codable, CaseIterable, Sendable {
    case red, yellow, blue, black   // black = unrevealed state; player palette (red/yellow/blue) is constrained per-level later
}
```

### TASK-005 — `ShapeType.swift`
Union of all 4 docs (task list: triangle/square/polygon; tech doc: +diamond; PRS/GDD: +circle):
```swift
nonisolated enum ShapeType: String, Codable, CaseIterable, Sendable {
    case triangle, square, diamond, circle, polygon
}
```
`polygon` = custom-points shape (points arrive with the Phase 2 level schema / Phase 3 renderer).

### TASK-006 — `NormalizedPoint.swift`
```swift
nonisolated struct NormalizedPoint: Codable, Hashable, Sendable {
    let x: Double   // 0...1
    let y: Double   // 0...1
    static let center = NormalizedPoint(x: 0.5, y: 0.5)
}
```
Device-independent by construction (tech doc §5). Named `NormalizedPoint` per TASK-006 file name.

### TASK-007 — `PuzzleShape.swift` (+ minimal `ColorClue.swift`)
`PuzzleShape` requires a clue type to compile, so a **minimal** `ColorClue` ships now (full treatment is TASK-019, Phase 5):
```swift
nonisolated struct ColorClue: Codable, Hashable, Sendable {
    let neighborID: String   // JSON key "neighbor"
    let color: LumonColor    // expected color of that neighbor — never the shape's own color (PRS §5)
}

nonisolated struct PuzzleShape: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let type: ShapeType
    let position: NormalizedPoint
    let rotation: Double
    var color: LumonColor?        // nil = hidden (decodes as nil when absent from level JSON)
    let neighbors: [String]
    let clues: [ColorClue]
}
```
Custom `Codable` with **flat keys** matching tech doc §8 JSON: `{"id","type","x","y","rotation","color","neighbors","clues"}` — `x`/`y` map into `position`.

---

## Validation

1. **Build (TASK-001/002/003 acceptance):**
   `rtk xcodebuild -project Lumon.xcodeproj -scheme Lumon -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath $PI_SCRATCH_DIR/dd build` → BUILD SUCCEEDED.
2. **Model JSON round-trip (TASK-004…007 acceptance: "encoded and decoded" / "loaded from JSON"):**
   scratch script compiled with `xcrun swiftc Lumon/Domain/Models/*.swift model_check.swift` — decode the tech-doc example JSON (`{"id":"shape_01","type":"triangle","x":0.5,"y":0.3,"rotation":0,"neighbors":["shape_02"],"clues":[{"neighbor":"shape_02","color":"red"}]}`), assert fields, re-encode, re-decode, assert equality; also round-trip `LumonColor`/`ShapeType`/`NormalizedPoint`. Prints PASS/FAIL.
3. **Launch check (TASK-003 acceptance "application launches"):** boot iPhone 17 Pro sim → `simctl install` the built app → `simctl launch com.hendrairawan.dev.cloudkit.Lumon` → screenshot to scratch → confirm home screen renders.
4. **Bundle hygiene:** confirm built `.app` contains no `.md`/`.gitkeep` strays.

## Out of Scope (later phases)

JSON level schema/loader/repository (Phase 2), renderers (3), board (4), validator/hints (5–7), ViewModel (8), solver (9), audio (10), generator (11), polish (12), formal test target (13 — Phase 13 TASK-039 will move the scratch round-trip checks into real unit tests).

## Notes

- No external dependencies (tech doc §16) — only SwiftUI/Foundation/Observation.
- No git commit unless you ask for one.
- Fallbacks: if `nonisolated struct` hits a toolchain quirk → plain `struct … Sendable` (build-verified); scheme already confirmed to exist.