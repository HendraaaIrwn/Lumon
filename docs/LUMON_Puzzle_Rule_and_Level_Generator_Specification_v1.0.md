# LUMON Puzzle Rule Specification & Level Generator Design

## MVP Version 1.0

## 1. Game Overview

**LUMON** is a geometric logic puzzle where players illuminate hidden
artworks by discovering the correct colors of connected shapes.

Players do not move pieces. Each puzzle consists of fixed geometric
shapes: - Triangle - Square - Diamond - Circle

Each shape starts hidden/dark and contains colored circle clues.

------------------------------------------------------------------------

## 2. Core Rule

The objective is to color every shape correctly.

A puzzle is solved when all shapes have the correct colors and the
complete artwork is revealed.

------------------------------------------------------------------------

## 3. Board Rules

-   Shape position is fixed.
-   Shape rotation is fixed.
-   Player only selects colors.
-   Shapes may repeat.
-   Layouts can form abstract artworks.

------------------------------------------------------------------------

## 4. Color System

MVP Colors: - Red - Yellow - Blue

Rules: - Same colors are allowed. - Same shapes can repeat. - No
Sudoku-style uniqueness restriction.

------------------------------------------------------------------------

## 5. Neighbor System

A neighbor means a shape that directly touches another shape.

Only direct edge contact counts.

Not counted: - diagonal contact - corner contact - nearby distance

------------------------------------------------------------------------

## 6. Hint Circle Rules

Circle hints represent the colors of ALL neighboring shapes.

Example:

A shape touching: - Red neighbor - Yellow neighbor - Blue neighbor

will contain:

Red circle\
Yellow circle\
Blue circle

A shape may contain up to 6 hint circles.

------------------------------------------------------------------------

## 7. Hidden Clues

Not every clue must be visible.

Generator:

1.  Generate complete puzzle.
2.  Generate all clues.
3.  Hide selected clues.
4.  Validate unique solution.
5.  Accept puzzle.

------------------------------------------------------------------------

## 8. Interaction

Player flow:

Tap Shape\
↓\
Choose Color Button\
↓\
Instant Validation

Color buttons:

🔴 Red\
🟡 Yellow\
🔵 Blue

------------------------------------------------------------------------

## 9. Validation

Correct: - Shape changes color. - Shape locks. - Success haptic. -
Success sound. - Light reveal effect.

Wrong: - Shape flashes red. - Error haptic. - Lose one life.

------------------------------------------------------------------------

## 10. Life System

Player starts with:

❤️ ❤️ ❤️

Three mistakes are allowed.

Wrong answer: -1 life

------------------------------------------------------------------------

## 11. Hint System

Hint reveals:

**One correct shape color**

Hint does not reveal: - clue - neighbor - full solution

Recommended: 2 hints per level.

------------------------------------------------------------------------

# Level Generator Design

## Generation Pipeline

Create Artwork Template

↓

Place Shapes

↓

Build Neighbor Graph

↓

Assign Solution Colors

↓

Generate Clues

↓

Hide Some Clues

↓

Validate Unique Solution

↓

Export JSON

------------------------------------------------------------------------

## Artwork Template

MVP Theme:

Geometric Abstract Artwork

Generated layouts should form: - patterns - symbols - abstract objects -
geometric illustrations

------------------------------------------------------------------------

## Layout Rules

Each piece has:

-   id
-   shape
-   coordinate
-   rotation
-   solution color
-   neighbors
-   clues

Example JSON:

``` json
{
"id":"shape_01",
"shape":"triangle",
"x":2,
"y":1,
"rotation":0,
"solution":"red"
}
```

------------------------------------------------------------------------

## Difficulty System

Difficulty is based on:

-   number of shapes
-   neighbor density
-   hidden clue percentage
-   color ambiguity

30 MVP Levels:

  Level     Shapes   Visible Clues
  ------- -------- ---------------
  1-5          3-5             90%
  6-10         5-8             75%
  11-15       8-12             60%
  16-20      12-18             50%
  21-25      18-25             40%
  26-30      25-30             30%

------------------------------------------------------------------------

## Unique Solution

Every puzzle must have exactly one solution.

Validation:

Generate Puzzle

↓

Run Solver

↓

Count Solutions

↓

If solution != 1 reject

------------------------------------------------------------------------

## JSON Storage

Levels are stored locally using JSON.

------------------------------------------------------------------------

## Completion Animation

Light Reveal:

All shapes solved

↓

Glow animation

↓

Light spreads through artwork

↓

Artwork completed

------------------------------------------------------------------------

## MVP Scope

Included: - 30 levels - Fixed artwork - Four shapes - Three colors -
Neighbor clues - Hidden clues - Hint system - Three lives - Haptic
feedback - Sound effects - Light reveal animation - JSON storage

Excluded: - Daily puzzle - Monetization - Leaderboard - Online account

------------------------------------------------------------------------

## LUMON Identity

"LUMON combines Sudoku deduction, Minesweeper neighborhood logic, color
theory, and geometric artwork discovery into a minimalist puzzle
experience."
