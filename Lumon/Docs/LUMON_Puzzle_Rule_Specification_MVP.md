# LUMON Puzzle Rule Specification (PRS)

## MVP v1.0

## 1. Puzzle Overview

LUMON is a color constraint puzzle where players reveal the hidden
colors of geometric shapes using logical deduction.

The game combines: - Sudoku-style constraint solving - Minesweeper-style
neighbor clues - Visual shape-based interaction

The objective is to assign the correct color to every shape while
maintaining a unique solution.

------------------------------------------------------------------------

# 2. Core Puzzle Elements

## Shapes

MVP supports:

-   Triangle ▲
-   Square ■
-   Diamond ◆
-   Circle ●

Rules: - Shapes can repeat. - Shape identity does not determine color. -
Every puzzle can contain different shape combinations.

Example:

    ▲ ▲ ■ ◆ ●

------------------------------------------------------------------------

## Colors

MVP colors:

-   Red 🔴
-   Yellow 🟡
-   Blue 🔵

Rules: - Multiple shapes may have the same color. - No color uniqueness
constraint exists.

Example:

    ▲ = Red
    ■ = Red
    ◆ = Blue

is valid.

------------------------------------------------------------------------

# 3. Board System

LUMON uses a free-form board.

Each level may have: - different number of shapes - different layout -
different shape combinations

Example:

Level 1:

        ▲

    ▲   ■   ▲

Level 20:

          ▲

    ■     ◆     ■

    ▲     ■     ◆

------------------------------------------------------------------------

# 4. Neighbor Rule

A neighbor is defined as a shape that has direct physical contact.

Valid contact:

    ▲ ■

Invalid:

    ▲     ■

Only directly touching shapes are considered neighbors.

The system does not use: - distance - grid coordinates - invisible
proximity

------------------------------------------------------------------------

# 5. Hint System

## Basic Rule

Each shape may contain hidden color hints.

Hints represent colors of neighboring shapes.

Important:

> A shape's hint never represents its own color.

Example:

          ▲

         🔴 🟡

Meaning:

Among Triangle's neighboring shapes: - one neighbor is Red - one
neighbor is Yellow

------------------------------------------------------------------------

# 6. Partial Hint Information

Hints are not always complete.

A shape may have fewer hints than its total neighbors.

Example:

    ▲

    Hint:
    🔴

The meaning:

Among all touching neighbors: - at least one is Red

Other neighbors are unknown.

This creates deduction gameplay.

------------------------------------------------------------------------

# 7. Hint Visibility

Hints are hidden at the start.

When the player selects a shape:

Before:

    ⬛

After selection:

    ▲

    🔴 🟡

The player can inspect the clue.

------------------------------------------------------------------------

# 8. Hint Limitation

Maximum hints per shape:

    6 hints

Difficulty can be adjusted by: - number of hints - hint density - number
of shapes

------------------------------------------------------------------------

# 9. Shapes Without Hints

Not every shape must contain hints.

Example:

    ▲  🔴

    ■

    ◆  🟡

Shapes without hints increase deduction difficulty.

------------------------------------------------------------------------

# 10. Player Interaction

## Selecting Color

Player selects a black shape.

Color choices:

    🔴
    🟡
    🔵

------------------------------------------------------------------------

# 11. Validation System

Validation occurs immediately.

When player chooses a color:

    Player Input

    ↓

    Check puzzle constraints

    ↓

    Correct / Wrong

------------------------------------------------------------------------

## Correct

Result:

-   Shape reveals color permanently
-   Shape becomes locked
-   Success haptic
-   Success sound

## Wrong

Result:

-   Shape flashes red
-   Shake animation
-   Error haptic
-   Error sound

The player keeps playing.

------------------------------------------------------------------------

# 12. Life System

MVP uses 3 lives.

Initial:

    ❤️ ❤️ ❤️

Wrong answer:

    ❤️ ❤️ 🖤

When lives reach zero:

Game over.

------------------------------------------------------------------------

# 13. Answer Locking

Correct answers cannot be changed.

Example:

    ▲ = 🔴 ✓

The player cannot modify it.

Wrong answers are not saved.

------------------------------------------------------------------------

# 14. Hint Button

Hint action:

> Reveal one correct color.

Example:

Before:

    ⬛

After:

    🔵

The revealed shape: - becomes correct - becomes locked - consumes hint
resource (resource system TBD)

------------------------------------------------------------------------

# 15. Win Condition

A level is completed when:

All shapes have correct colors.

Example:

    ▲ ✓
    ■ ✓
    ◆ ✓
    ● ✓

No additional requirement: - no timer - no move limit

------------------------------------------------------------------------

# 16. Difficulty Model

Difficulty is a combination of:

## 1. Shape Count

More shapes: - higher complexity

## 2. Hint Density

Less information: - harder

## 3. Deduction Complexity

Easy: - direct deduction

Hard: - multi-step deduction chain

------------------------------------------------------------------------

# 17. Unique Solution Requirement

Every generated puzzle must have exactly one valid solution.

Invalid:

    Solution A ✓
    Solution B ✓

Valid:

    Only Solution A ✓

------------------------------------------------------------------------

# 18. Puzzle Generation Strategy

LUMON uses:

## Solution First Generation

Process:

    Generate Board

    ↓

    Assign hidden colors

    ↓

    Generate hints

    ↓

    Remove colors

    ↓

    Run Solver

    ↓

    Check unique solution

    ↓

    Save Level

------------------------------------------------------------------------

# 19. Solver Requirement

The internal solver must be able to:

-   determine possible colors
-   evaluate constraints
-   detect contradictions
-   confirm unique solution

A level is accepted only if:

    Number of solutions = 1

------------------------------------------------------------------------

# 20. MVP Constraints Summary

Included: - Free-form board - 4 shapes - 3 colors - Partial hidden
hints - Maximum 6 hints - 3 lives - Instant validation - Hint reveal -
Locked correct answers - Unique solution puzzles

Excluded: - Timer - Move limit - Multiplayer - Daily puzzle -
Monetization

------------------------------------------------------------------------

# 21. MVP Session and Catalog Rules

- The MVP contains ten ordered levels.
- A new level session starts with three lives and six hint reveals.
- Completing a level through manual answers or hints unlocks the next level.
- Correctly completed level IDs persist locally; in-progress colors do not.
- Reset Progress clears completion records but does not change sound settings.
