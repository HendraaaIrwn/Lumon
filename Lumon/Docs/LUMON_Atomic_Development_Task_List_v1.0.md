# LUMON Atomic Development Task List v1.0

## Project Goal

Build LUMON, a native iOS puzzle game using:

-   SwiftUI
-   MVVM + Lightweight Clean Architecture
-   Swift Observation Framework
-   Native Apple Framework only
-   JSON-based level system
-   Backtracking puzzle validation

This document breaks development into small atomic tasks that can be
completed independently.

------------------------------------------------------------------------

# Phase 0 --- Project Initialization

## TASK-001 Create Xcode Project

Goal: Create the base iOS application.

Steps:

-   Create new SwiftUI App project
-   Configure bundle identifier
-   Set deployment target
-   Enable Swift 6
-   Enable Observation framework support

Output:

    LUMON/

------------------------------------------------------------------------

## TASK-002 Setup Folder Structure

Create:

    LUMON

    App/

    Features/

    Domain/

    Data/

    Core/

    Resources/

Acceptance:

-   Folder structure exists
-   Build succeeds

------------------------------------------------------------------------

## TASK-003 Configure App Entry Point

Implement:

-   LUMONApp.swift
-   RootView.swift

Acceptance:

-   Application launches
-   Empty home screen displayed

------------------------------------------------------------------------

# Phase 1 --- Core Domain Model

## TASK-004 Create Color Model

Create:

    LumonColor.swift

Implement:

-   red
-   yellow
-   blue
-   black

Acceptance:

Colors can be encoded and decoded.

------------------------------------------------------------------------

## TASK-005 Create Shape Type Model

Create:

    ShapeType.swift

Support:

-   triangle
-   square
-   polygon

Acceptance:

Shape type can be loaded from JSON.

------------------------------------------------------------------------

## TASK-006 Create Normalized Coordinate Model

Create:

    NormalizedPoint.swift

Properties:

``` swift
x: Double
y: Double
```

Acceptance:

Coordinates independent from device size.

------------------------------------------------------------------------

## TASK-007 Create Puzzle Shape Entity

Create:

    PuzzleShape.swift

Properties:

-   id
-   shape type
-   position
-   rotation
-   current color
-   neighbors
-   clues

Acceptance:

One shape can represent one puzzle piece.

------------------------------------------------------------------------

# Phase 2 --- JSON Level System

## TASK-008 Create Level JSON Schema

Create:

    level_001.json

Include:

-   shapes
-   colors
-   clues
-   metadata

Acceptance:

JSON matches model.

------------------------------------------------------------------------

## TASK-009 Implement Level Decoder

Create:

    LevelLoader.swift

Responsibilities:

-   Read JSON
-   Decode level
-   Return Level object

Acceptance:

Level loads successfully.

------------------------------------------------------------------------

## TASK-010 Create Level Repository

Create:

    LevelRepository.swift

Responsibilities:

-   Provide levels
-   Manage level selection

Acceptance:

Game can request level data.

------------------------------------------------------------------------

# Phase 3 --- Rendering Engine

## TASK-011 Create Shape Renderer Protocol

Create:

    ShapeRenderer.swift

Purpose:

Define rendering contract.

------------------------------------------------------------------------

## TASK-012 Implement Triangle Shape

Create:

    TriangleShape.swift

Using:

SwiftUI Shape

Acceptance:

Triangle renders correctly.

------------------------------------------------------------------------

## TASK-013 Implement Square Shape

Create:

    SquareShape.swift

Acceptance:

Square renders correctly.

------------------------------------------------------------------------

## TASK-014 Implement Custom Polygon Renderer

Create:

    PolygonShape.swift

Support:

-   custom points
-   rotation

Acceptance:

Complex artwork can render.

------------------------------------------------------------------------

## TASK-015 Implement Normalized Scaling

Create:

    CoordinateMapper.swift

Convert:

Normalized coordinate → Screen coordinate

Acceptance:

Same level works on iPhone and iPad.

------------------------------------------------------------------------

# Phase 4 --- Game Board

## TASK-016 Create Game Board View

Create:

    GameBoardView.swift

Responsibilities:

-   Draw all shapes
-   Position shapes
-   Handle selection

Acceptance:

Complete artwork appears.

------------------------------------------------------------------------

## TASK-017 Add Shape Selection

Implement:

-   tap gesture
-   selected state
-   highlight animation

Acceptance:

Player can select a shape.

------------------------------------------------------------------------

# Phase 5 --- Puzzle Logic

## TASK-018 Create Neighbor Graph

Implement:

    NeighborGraph.swift

Responsibilities:

-   Store relationships
-   Query neighbors
-   Reject unknown, duplicate, self, and one-way relationships

Acceptance:

Each shape knows connected shapes.

------------------------------------------------------------------------

## TASK-019 Create Clue Model

Create:

    ColorClue.swift

Contains:

-   expected neighboring color

Repeated clues represent the minimum number of distinct neighbors with
that color. A clue never identifies a specific neighbor.

------------------------------------------------------------------------

## TASK-020 Create Puzzle Validator

Create:

    PuzzleValidator.swift

Check:

-   Neighbor colors
-   Partial and complete clue matching
-   Player answers against the hidden JSON solution

Acceptance:

Correct and wrong states detected.

------------------------------------------------------------------------

## TASK-021 Create Win Condition

Implement:

    GameCompletionChecker.swift

Rule:

All shapes correctly colored.

Acceptance:

Puzzle completes only with valid solution.

------------------------------------------------------------------------

# Phase 6 --- Player Interaction

## TASK-022 Create Color Picker Component

Create:

    ColorPickerView.swift

UI:

3 color buttons below board.

Acceptance:

Player can choose colors.

------------------------------------------------------------------------

## TASK-023 Connect Color Assignment

Flow:

Tap shape

↓

Choose color

↓

Update state

Acceptance:

Shape changes color.

------------------------------------------------------------------------

## TASK-024 Implement Mistake System

Rules:

-   3 lives
-   Wrong answer reduces life

Acceptance:

Game over after 3 mistakes.

------------------------------------------------------------------------

# Phase 7 --- Hint System

## TASK-025 Create Hint Manager

Create:

    HintManager.swift

Rules:

-   Maximum 6 reveals per game
-   Reveal one correct shape

------------------------------------------------------------------------

## TASK-026 Implement Hint Animation

Create:

    LightRevealAnimation.swift

Animation:

-   Glow
-   Color reveal
-   Confirmation

Acceptance:

Hint feels like light activation.

------------------------------------------------------------------------

# Phase 8 --- Game State Architecture

## TASK-027 Create Game ViewModel

Create:

    GameViewModel.swift

Using:

``` swift
@Observable
```

Manage:

-   level
-   shapes
-   selected shape
-   lives
-   hints
-   completion
-   game over
-   feedback events

Actions:

-   load
-   select shape
-   assign color
-   use hint
-   reset

------------------------------------------------------------------------

## TASK-028 Connect Views With ViewModel

Implement:

View

↓

ViewModel

↓

Domain Logic

Acceptance:

No game logic inside View.

------------------------------------------------------------------------

# Phase 9 --- Solver Engine

## TASK-029 Implement Backtracking Solver

Create:

    PuzzleSolver.swift

Algorithm:

1.  Select empty shape
2.  Try colors
3.  Validate
4.  Backtrack

Acceptance:

-   Solver searches from clues without reading the hidden solution
-   Search stops after the second solution
-   Search-limit exhaustion remains distinct from a proven result

------------------------------------------------------------------------

## TASK-030 Add Unique Solution Check

Implement:

-   Count possible solutions
-   Reject multiple solutions
-   Reject levels whose unique result differs from the hidden solution
-   Share structural and uniqueness validation between loading and export

Acceptance:

Every level has exactly one solution.

------------------------------------------------------------------------

# Phase 10 --- Audio

## TASK-031 Create Audio Manager

Create:

    AudioManager.swift

Using:

AVAudioPlayer

Sounds:

-   tap
-   correct
-   wrong
-   complete

Behavior:

-   Uses the ambient audio session category
-   Respects the Ring/Silent switch
-   Restarts short effects from the beginning
-   Audio failures do not interrupt gameplay

------------------------------------------------------------------------

# Phase 11 --- Level Generator Support

## TASK-032 Create Generator Data Model

Implement:

Models for:

-   artwork
-   shapes
-   colors
-   clues

The input artwork stores fixed geometry, playable colors, and explicit
two-way neighbor relationships. It does not contain player colors or
generated clues.

------------------------------------------------------------------------

## TASK-033 Generate Random Solution

Create:

    LevelGenerator.swift

Generate:

-   valid color assignment
-   at most 100 candidates by default

------------------------------------------------------------------------

## TASK-034 Generate Clues

Generate:

-   neighbor clues
-   hidden information
-   partial clues with at most 6 clues per shape

Only candidates proven to have exactly one solver result are accepted.
Clues are removed one at a time while uniqueness remains proven.

------------------------------------------------------------------------

## TASK-035 Export JSON Level

Output:

    level_xxx.json

The exporter validates the level, hides player colors, writes sorted
pretty-printed JSON atomically, and does not add the result to the app
bundle automatically.

------------------------------------------------------------------------

# Phase 12 --- Polish

## TASK-036 Add Completion Animation

Implement:

-   board glow
-   success animation
-   reduced-motion fallback

Status: Implemented. Build verification is recorded separately.

------------------------------------------------------------------------

## TASK-037 Add Loading State

Implement:

-   level loading animation
-   cancellable asynchronous bundle loading
-   retryable error state

Status: Implemented. Loading and decoding run through the repository actor.

------------------------------------------------------------------------

## TASK-038 Add Settings Screen

-   sound toggle
-   reset progress

Status: Implemented with persistent local settings and reset confirmation.

------------------------------------------------------------------------

# Phase 13 --- Testing

Status: **Skipped by explicit project direction.** TASK-039 through TASK-041
remain reserved and were not implemented or run.

## TASK-039 Unit Test Models

Test:

-   JSON decoding
-   color models
-   shape models

------------------------------------------------------------------------

## TASK-040 Unit Test Validator

Test:

-   correct solution
-   invalid solution

------------------------------------------------------------------------

## TASK-041 Test Solver

Test:

-   unique solution
-   impossible puzzle

------------------------------------------------------------------------

# Phase 14 --- Progress and Navigation

## TASK-042 Persist Local Progress

Store completed level IDs in UserDefaults and unlock levels sequentially.

Status: Implemented.

## TASK-043 Record Completion

Record completion from normal answers and hint-based completion.

Status: Implemented.

## TASK-044 Add Home and Level Select Navigation

Show completed, available, and locked levels. PLAY opens the first
unfinished level.

Status: Implemented.

## TASK-045 Add Next Level and Final Completion Flow

Replace the active game destination for Next Level and show the final
catalog completion state after Level 10.

Status: Implemented.

------------------------------------------------------------------------

# Phase 15 --- Ten-Level MVP Catalog

## TASK-046 Add Deterministic Level Authoring Tool

Generate bundled JSON through the existing generator, solver, validator,
and atomic exporter.

Status: Implemented in `Tools/LevelAuthoring/generate_levels.swift`.

## TASK-047 through TASK-049 Add Level Batches

-   Level 2 through Level 4: 6--7 shapes
-   Level 5 through Level 7: 8--10 shapes
-   Level 8 through Level 10: 10--12 shapes

Status: Implemented. Export accepted all nine generated levels as unique.

------------------------------------------------------------------------

# Phase 16 --- Documentation and Build Closure

## TASK-050 Synchronize MVP Documentation

Document the asynchronous loading, persistent app state, navigation,
ten-level catalog, authoring command, and skipped test phase.

Status: Implemented. Debug and Release build results belong in the final
implementation report; gameplay and balance remain untested by request.

------------------------------------------------------------------------

# MVP Completion Checklist

MVP is complete when:

-   [x] Player can open sequential levels
-   [x] Board rendering is implemented
-   [x] Player color selection is implemented
-   [x] Rule validation is integrated
-   [x] Bundled puzzles pass export-time uniqueness validation
-   [x] Hint and lives systems are integrated
-   [x] Ten levels load through the JSON repository contract
-   [x] Completion animation is implemented
-   [x] Local progress, Level Select, Settings, and Next Level are implemented

These checks represent implementation state. Build status and runtime test
coverage are reported independently.

------------------------------------------------------------------------

# Recommended Development Order

1.  Project Setup
2.  Data Models
3.  JSON Loader
4.  Renderer
5.  Game Board
6.  Validator
7.  ViewModel
8.  Interaction
9.  Solver
10. Hint
11. Audio
12. Polish
13. Progress and Navigation
14. Level Catalog
15. Documentation and Build Closure
