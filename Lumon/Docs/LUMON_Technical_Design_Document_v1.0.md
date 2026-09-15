# LUMON Technical Design Document v1.0

## 1. Document Overview

**Project Name:** LUMON\
**Document Version:** 1.0\
**Platform:** iOS\
**Technology Stack:**

-   Swift 6
-   SwiftUI
-   iOS 26+
-   Xcode 26
-   Native Apple Framework only

LUMON is a color-shape puzzle game where players solve geometric boards
by assigning colors to fixed-position shapes. Each shape contains visual
clues represented by circles that indicate the colors of neighboring
shapes.

The MVP focuses on: - Fixed artwork layout - Player color selection -
Constraint-based puzzle solving - Procedural level generation support -
Smooth native SwiftUI animation

------------------------------------------------------------------------

# 2. System Architecture

## Architecture Pattern

LUMON uses:

**MVVM + Lightweight Clean Architecture**

Architecture goals:

-   Clear separation between UI and puzzle logic
-   Easy level expansion
-   Testable puzzle engine
-   Maintainable SwiftUI implementation

## High Level Structure

    LUMON
    │
    ├── App
    │
    ├── Features
    │   │
    │   ├── Game
    │   │   ├── Views
    │   │   ├── ViewModels
    │   │   └── Components
    │   │
    │   ├── Level
    │   │   ├── LevelLoader
    │   │   └── LevelModels
    │   │
    │   ├── Puzzle
    │   │   ├── Solver
    │   │   ├── Validator
    │   │   └── Rules
    │   │
    │   └── Settings
    │
    ├── Domain
    │   ├── Models
    │   ├── UseCases
    │   └── Algorithms
    │
    ├── Data
    │   └── JSON
    │
    └── Core
        ├── Animation
        ├── Audio
        └── Utilities

------------------------------------------------------------------------

# 3. Game Concept

## Core Rule

Each puzzle consists of:

-   Shapes with fixed positions
-   Shape colors hidden from player
-   Circle clues showing neighboring colors
-   Color selection buttons

Player action:

    Select shape
            ↓
    Choose color
            ↓
    Validate constraints
            ↓
    Complete puzzle

------------------------------------------------------------------------

# 4. Rendering System

## Rendering Technology

LUMON uses:

**SwiftUI Native Shape**

Reasons:

-   Native SwiftUI integration
-   Easy animation support
-   Good performance
-   Simple composition

Supported shapes:

``` swift
enum ShapeType {
    case triangle
    case square
    case diamond
    case polygon
}
```

------------------------------------------------------------------------

# 5. Coordinate System

LUMON uses:

## Normalized Coordinate System

All artwork positions use:

``` swift
struct NormalizedPosition {
    let x: Double
    let y: Double
}
```

Example:

``` json
{
 "x":0.5,
 "y":0.3
}
```

Advantages:

-   Device independent
-   Supports iPhone/iPad layouts
-   Easy scaling

------------------------------------------------------------------------

# 6. Shape Data Model

## Puzzle Shape

``` swift
struct PuzzleShape: Identifiable {

    let id: String

    let type: ShapeType

    let position: NormalizedPosition

    let rotation: Double

    var color: LumonColor?

    let neighbors: [String]

    let clues: [ColorClue]

}
```

MVP supports:

-   Standard shapes
-   Custom polygon
-   Rotation
-   Neighbor relationship

------------------------------------------------------------------------

# 7. Color System

``` swift
enum LumonColor {

case red
case yellow
case blue
case black

}
```

Future expansion:

-   Additional themes
-   More colors
-   Difficulty variation

------------------------------------------------------------------------

# 8. Level JSON Format

Each level uses:

    Levels/

    level_001.json
    level_002.json
    level_003.json

Example:

``` json
{
"id":"level_001",

"shapes":[

{
"id":"shape_01",
"type":"triangle",
"x":0.5,
"y":0.3,
"rotation":0,
"neighbors":[
"shape_02"
]
}

],

"availableColors":[
"red",
"yellow",
"blue"
],

"solution": {
"shape_01":"red"
}

}
```

`solution` is required and contains exactly one playable color for every
shape. It remains hidden from the board and is used for immediate answer
validation and hint reveals.

Each clue stores only a color. Repeated clue colors are counts: two red
dots require at least two distinct red neighbors. Clues can be partial, so
unlisted neighbor colors remain unconstrained. Neighbor relationships must
be explicit and two-way in JSON.

------------------------------------------------------------------------

# 9. Puzzle Validation Engine

Validation checks:

1.  Shape color assignment
2.  Neighbor constraints
3.  Circle clue matching
4.  Hidden solution consistency

Flow:

    Player Input

    ↓

    Update Color

    ↓

    Validator

    ↓

    Correct / Incorrect

An answer is correct only when it matches that shape's hidden solution.
A partially revealed board remains feasible when every missing clue count
can still be supplied by unresolved neighbors.

------------------------------------------------------------------------

# 10. Puzzle Solver

## Algorithm

LUMON uses:

**Backtracking Solver**

Purpose:

-   Verify puzzle uniqueness
-   Generate valid levels
-   Check difficulty

Algorithm:

    Choose empty shape

    ↓

    Try available color

    ↓

    Check constraints

    ↓

    Continue

    ↓

    Backtrack if invalid

The solver receives shapes and the playable palette. It derives answers
only from explicit neighbor relationships and color clues; it never reads
the hidden JSON solution while searching. Partial assignments are pruned
when unresolved neighbors can no longer supply the missing clue counts.

Search stops after two solutions because that is sufficient to reject
uniqueness. The default search budget is 100,000 attempted assignments.
Reaching the budget is reported as an unproven result, not as a unique
solution.

------------------------------------------------------------------------

# 11. Level Generator Design

Generation pipeline:

    Create Shape Layout

    ↓

    Assign Neighbor Graph

    ↓

    Generate Color Solution

    ↓

    Generate Circle Clues

    ↓

    Remove Hidden Colors

    ↓

    Run Solver

    ↓

    Save JSON

Requirements:

-   Exactly one solution
-   No overlap
-   Fixed artwork positions

The internal generator receives an artwork template containing fixed
geometry, a playable palette, and explicit two-way neighbor relationships.
It assigns a random hidden solution, creates up to six neighboring color
clues per shape, and tries to remove clues while solver-proven uniqueness
remains intact. Generation tries at most 100 candidates by default.

Generated levels can be encoded or written atomically as sorted,
pretty-printed JSON. Export uses the same validation service as level
loading and does not register the file as a bundled playable level.

------------------------------------------------------------------------

# 12. Hint System

MVP Hint:

## Reveal One Correct Shape

Flow:

    Player Request Hint

    ↓

    Select unresolved shape

    ↓

    Reveal correct color

    ↓

    Animate Light Reveal

The game starts with six hint reveals. A reveal prefers the selected
unresolved shape, otherwise it uses the first unresolved shape in level
order. Revealed shapes become locked and reset restores all six hints.

------------------------------------------------------------------------

# 13. Animation System

Technology:

**SwiftUI Native Animation**

Supported animations:

## Light Reveal

Purpose:

Reveal correct color elegantly.

Flow:

    Glow Effect

    ↓

    Color Transition

    ↓

    Shape Confirmation

Other animations:

-   Wrong answer shake
-   Color selection feedback
-   Completion animation

------------------------------------------------------------------------

# 14. Game State Management

Technology:

Swift Observation Framework

Example:

``` swift
@Observable
class GameViewModel {

var level: Level

var shapes:[PuzzleShape]

var hints:Int

var lives:Int

var status:GameStatus

var feedbackEvent:GameFeedbackEvent?

}
```

`GameViewModel` owns all mutable session state and exposes actions for
loading, selection, color assignment, hints, and reset. Views render state
and forward player actions; puzzle rules remain in domain services.

------------------------------------------------------------------------

# 15. Audio System

Framework:

AVAudioPlayer

Used for:

-   Button interaction
-   Correct answer
-   Wrong answer
-   Level completion

`AudioManager` retains one prepared player for each bundled WAV effect
and restarts it from the beginning for repeated interactions. The ambient
audio-session category respects the Ring/Silent switch and mixes with
audio from other apps. Missing resources and playback failures are logged
without interrupting game actions.

No external audio dependency.

------------------------------------------------------------------------

# 16. Dependency Policy

External libraries:

**Not allowed**

Only:

-   SwiftUI
-   Foundation
-   AVFoundation
-   Observation

------------------------------------------------------------------------

# 17. Performance Considerations

Targets:

-   60 FPS animation
-   Lightweight shape rendering
-   Minimal state updates

Optimization:

-   Avoid unnecessary redraw
-   Keep puzzle logic outside View layer
-   Use value types where possible

------------------------------------------------------------------------

# 18. Future Expansion

Possible future features:

-   Daily puzzle
-   More themes
-   Custom shape packs
-   Procedural difficulty scaling
-   Leaderboard
-   Achievement system

------------------------------------------------------------------------

# 19. MVP Application State and Navigation

`RootView` owns one `AppSettings` and one `ProgressStore` for the app
session. Both persist through UserDefaults. Settings stores the sound-effect
preference; progress stores only completed level IDs. Transient board colors,
lives, and hints are not persisted.

The ordered catalog contains `level_001` through `level_010`. Level 1 is
always unlocked, and each later level requires every previous level to be
complete. PLAY opens the first unfinished level. Level Select exposes
completed, available, and locked states. Next Level replaces the active game
destination instead of stacking another game screen.

------------------------------------------------------------------------

# 20. Asynchronous Level Loading

`BundleLevelRepository` is an actor. Bundle reads, JSON decoding, structural
validation, and solver-backed uniqueness validation run behind its async
interface. `GameViewModel` remains MainActor-isolated and applies only the
result of its current request. SwiftUI task cancellation prevents an obsolete
load from replacing a newer game state.

------------------------------------------------------------------------

# 21. Level Authoring

`Tools/LevelAuthoring/generate_levels.swift` contains deterministic recipes
for Level 2 through Level 10. It calls the production `LevelGenerator` and
`LevelExporter`; the resulting JSON is written atomically only after the
solver proves one solution matching the hidden answer. Generated files are
then bundled as static resources and are never generated during gameplay.

------------------------------------------------------------------------

# 22. Verification Boundary

Phase 13 tests were skipped by explicit project direction. Debug and Release
simulator builds are the implementation gate. Runtime gameplay, animation
quality, accessibility behavior on device, and difficulty balance remain
unverified through playtesting.

------------------------------------------------------------------------

# End of Document

Version: 1.0
