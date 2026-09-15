# LUMON — Phase 0–1 Implementation Plan

**Sources (all read in full):** `Lumon/Docs/LUMON_Atomic_Development_Task_List_v1.0.md` (operative task breakdown), `LUMON_Technical_Design_Document_v1.0.md`, `LUMON_Puzzle_Rule_Specification_MVP.md`, `LUMON_Game_Design_Document_MVP.md`.
**Scope:** Phase 0 (TASK-001…003) + Phase 1 (TASK-004…007). **Tests skipped per your instruction** — no test target, no test files; Phase 13 excluded.

## Current state (verified in workspace)

- `Lumon.xcodeproj` (Xcode 26.6, objectVersion 77) uses a **filesystem-synchronized root group** — new files/folders under `Lumon/` auto-join the target; no per-file pbxproj registration needed.
- SpriteKit template leftovers (`AppDelegate.swift`, `SceneDelegate.swift`, `GameViewController.swift`, `GameScene.swift`, `Main.storyboard`, `Actions.sks`, `GameScene.sks`) are **already deleted** in the working tree (unstaged `D` on branch `init/projectStructure`).
- Folder scaffold exists (App, Features/Game|Level|Puzzle|Settings, Domain/Algorithms|UseCases, Data/JSON, Core/Animation|Audio|Utilities, Resources — each with `.gitkeep`). **`Lumon/Domain/Models/` is missing** (required by TDD §2, needed for Phase 1).
- Still blocking a working SwiftUI app:
  - `SWIFT_VERSION = 5.0` (docs require Swift 6)
  - `INFOPLIST_KEY_UIMainStoryboardFile = Main` + `INFOPLIST_KEY_UIStatusBarHidden = YES` (game-template leftovers; the storyboard no longer exists)
  - `Lumon/Info.plist` still declares a UIKit `SceneDelegate` + `Main` storyboard (would crash at launch) and a launch-screen color `Black` that doesn't exist in `Assets.xcassets`
- Already correct: iOS 26.5 deployment target (docs: iOS 26+ ✓), `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` + `SWIFT_APPROACHABLE_CONCURRENCY = YES` (this is TASK-001's "Observation framework support" — nothing more to configure), bundle ID configured, scheme `Lumon` exists, iPhone 17 Pro simulator and Swift 6.3.3 toolchain verified available.
- No `.swift` files exist anywhere yet.

---

## Phase 0 — Project Initialization

### TASK-001 — Finish the SwiftUI / Swift 6 conversion (project already exists, so "create" = convert)

**a) `Lumon.xcodeproj/project.pbxproj`** — deterministic string edits, each applied to **both Debug and Release** target configs:
1. `SWIFT_VERSION = 5.0;` → `SWIFT_VERSION = 6.0;`
2. Remove `INFOPLIST_KEY_UIMainStoryboardFile = Main;`
3. Remove `INFOPLIST_KEY_UIStatusBarHidden = YES;`
4. Extend the synchronized group's `membershipExceptions` (currently just `Info.plist`) with the 4 `Docs/*.md` paths and every remaining `.gitkeep`, so design docs and placeholders are **not** copied into the app bundle.

**b) Rewrite `Lumon/Info.plist`** for the pure SwiftUI lifecycle:
- `UIApplicationSceneManifest` → keep only `UIApplicationSupportsMultipleScenes = false` (no scene-delegate class, no storyboard)
- `UILaunchScreen` → empty `<dict/>` (drops the missing `Black` color reference)

**c)** Leave the SpriteKit deletions staged-ready in the working tree (commit only if you ask). Bundle ID stays `com.hendrairawan.dev.cloudkit.Lumon` (configured = TASK-001 acceptance met; the `cloudkit` segment is flagged as optional future cleanup, not in doc acceptance).

### TASK-002 — Complete folder structure

- Create `Lumon/Domain/Models/` (only TDD §2 folder still missing).
- Delete `Lumon/App/.gitkeep` (real files arrive in TASK-003). All other `.gitkeep`s remain until their phases and are bundle-excluded via TASK-001 a)4.
- Acceptance "build succeeds" is proven by the Phase-0 validation build below.

### TASK-003 — App entry point

**`Lumon/App/LumonApp.swift`** (task list writes `LUMONApp.swift`; `LumonApp` matches the target/module name — noted naming deviation, same role):
```swift
import SwiftUI

@main
struct LumonApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}
```

**`Lumon/App/RootView.swift`** — empty home screen per GDD §12 Home + §11 Apple-minimal style (white background, strong whitespace), stub only — no navigation logic yet (later phases):
- "LUMON" wordmark (`.rounded` design, heavy weight), tagline "Reveal the hidden colors."
- Placeholder `PLAY` button + `Level Select` / `Settings` rows (disabled-looking, non-functional)
- `#Preview` for dev iteration
- Acceptance: app launches and shows this screen.

---

## Phase 1 — Core Domain Model (`Lumon/Domain/Models/`, pure Foundation, no UI imports)

All types: `nonisolated` (opts out of default MainActor isolation so the Phase 9 solver can later use them anywhere) + `Sendable` + `Codable`, raw values matching the JSON strings in TDD §8.

### TASK-004 — `LumonColor.swift`
```swift
nonisolated enum LumonColor: String, Codable, CaseIterable, Sendable {
    case red, yellow, blue, black   // black = unrevealed state (TDD §7)
}
```

### TASK-005 — `ShapeType.swift`
Union across the 4 docs (task list: triangle/square/polygon; TDD: +diamond; GDD/PRS: +circle):
```swift
nonisolated enum ShapeType: String, Codable, CaseIterable, Sendable {
    case triangle, square, diamond, circle, polygon
}
```
`polygon` = custom-points shape; its points arrive with the Phase 2 level schema / Phase 3 renderer.

### TASK-006 — `NormalizedPoint.swift`
```swift
nonisolated struct NormalizedPoint: Codable, Hashable, Sendable {
    let x: Double   // 0...1
    let y: Double   // 0...1
    static let center = NormalizedPoint(x: 0.5, y: 0.5)
}
```
Device-independent by construction (TDD §5); named `NormalizedPoint` per TASK-006.

### TASK-007 — `PuzzleShape.swift` (+ minimal `ColorClue.swift`)
`PuzzleShape` needs a clue type to compile, so a **minimal** `ColorClue` ships now — full treatment stays with TASK-019 (Phase 5):
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
    var color: LumonColor?       // nil = hidden; decodes as nil when absent from level JSON
    let neighbors: [String]
    let clues: [ColorClue]
}
```
Custom `Codable` with **flat keys** matching TDD §8 exactly: `{"id","type","x","y","rotation","color","neighbors","clues"}` — `x`/`y` map into `position`; `rotation` defaults to `0`, `neighbors`/`clues` default to `[]` when absent (robust for the Phase 2 schema).

---

## Validation — no tests, per your instruction

1. **Build (TASK-001/002/003 acceptance, Swift 6 diagnostics surface here):**
   `rtk xcodebuild -project Lumon.xcodeproj -scheme Lumon -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath $PI_SCRATCH_DIR/dd build` → **BUILD SUCCEEDED**
2. **Launch smoke (TASK-003 "application launches"):** boot iPhone 17 Pro sim → `xcrun simctl install` the built `.app` → `xcrun simctl launch booted com.hendrairawan.dev.cloudkit.Lumon` → screenshot to scratch → confirm the LUMON home screen renders.
3. **Codable round-trip (TASK-004…007 acceptance: "encoded and decoded" / "loaded from JSON") — verification script, NOT a test:** throwaway CLI in `$PI_SCRATCH_DIR` compiled via `xcrun swiftc Lumon/Domain/Models/*.swift + main.swift`: decode the TDD §8 example JSON (`{"id":"shape_01","type":"triangle","x":0.5,"y":0.3,"rotation":0,"neighbors":["shape_02"],"clues":[{"neighbor":"shape_02","color":"red"}]}`), assert fields, re-encode, re-decode, assert equality; also round-trip `LumonColor`/`ShapeType`/`NormalizedPoint`. Prints PASS/FAIL, then deleted. **No test target, nothing test-like lands in the repo.**
4. **Bundle hygiene:** confirm the built `.app` contains no `.md`/`.gitkeep` strays.

## Out of scope (later phases)

JSON level schema/loader/repository (Phase 2), renderers (3), board (4), validator/hints/interaction (5–7), ViewModel (8), solver (9), audio (10), generator (11), polish (12), **all testing (Phase 13 — skipped)**, bundle-ID rename, git commit (only if you ask).

## Notes / fallbacks

- No external dependencies (TDD §16) — only SwiftUI/Foundation/Observation.
- `nonisolated` on type declarations: supported by the verified Swift 6.3.3 toolchain; fallback to plain `struct … Sendable` if any toolchain quirk appears (build-verified).
- pbxproj edits are small unique string replacements ×2 configs — verified against the file just read; on any mismatch I re-read and regenerate rather than retry blindly.