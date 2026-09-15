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

Acceptance:

Each shape knows connected shapes.

------------------------------------------------------------------------

## TASK-019 Create Clue Model

Create:

    ColorClue.swift

Contains:

-   neighbor reference
-   expected color

------------------------------------------------------------------------

## TASK-020 Create Puzzle Validator

Create:

    PuzzleValidator.swift

Check:

-   Neighbor colors
-   Clue matching

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

-   Maximum 6 hints
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

Solver finds solution.

------------------------------------------------------------------------

## TASK-030 Add Unique Solution Check

Implement:

-   Count possible solutions
-   Reject multiple solutions

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

------------------------------------------------------------------------

# Phase 11 --- Level Generator Support

## TASK-032 Create Generator Data Model

Implement:

Models for:

-   artwork
-   shapes
-   colors
-   clues

------------------------------------------------------------------------

## TASK-033 Generate Random Solution

Create:

    LevelGenerator.swift

Generate:

-   valid color assignment

------------------------------------------------------------------------

## TASK-034 Generate Clues

Generate:

-   neighbor clues
-   hidden information

------------------------------------------------------------------------

## TASK-035 Export JSON Level

Output:

    level_xxx.json

------------------------------------------------------------------------

# Phase 12 --- Polish

## TASK-036 Add Completion Animation

Implement:

-   board glow
-   success animation

------------------------------------------------------------------------

## TASK-037 Add Loading State

Implement:

-   level loading animation

------------------------------------------------------------------------

## TASK-038 Add Settings Screen

Optional:

-   sound toggle
-   reset progress

------------------------------------------------------------------------

# Phase 13 --- Testing

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

# MVP Completion Checklist

MVP is complete when:

-   [ ] Player can open level
-   [ ] Board renders correctly
-   [ ] Player selects colors
-   [ ] Rules validate correctly
-   [ ] Puzzle has unique solution
-   [ ] Hint works
-   [ ] Lives work
-   [ ] Level loads from JSON
-   [ ] Completion animation works

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
