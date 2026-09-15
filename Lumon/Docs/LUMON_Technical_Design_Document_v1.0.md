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
]

}
```

------------------------------------------------------------------------

# 9. Puzzle Validation Engine

Validation checks:

1.  Shape color assignment
2.  Neighbor constraints
3.  Circle clue matching

Flow:

    Player Input

    ↓

    Update Color

    ↓

    Validator

    ↓

    Correct / Incorrect

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

-   Minimum one solution
-   Prefer unique solution
-   No overlap
-   Fixed artwork positions

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

var completed:Bool

}
```

------------------------------------------------------------------------

# 15. Audio System

Framework:

AVAudioPlayer

Used for:

-   Button interaction
-   Correct answer
-   Wrong answer
-   Level completion

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

# End of Document

Version: 1.0
