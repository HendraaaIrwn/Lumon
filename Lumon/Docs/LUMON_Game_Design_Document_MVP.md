# LUMON
## Game Design Document (GDD) - MVP 1.0

**Genre:** Color Logic Puzzle  
**Platform:** iOS  
**Technology:** SwiftUI + Swift 6 + iOS 26+

---

# 1. Game Overview

LUMON is a visual logic puzzle game combining the deduction mechanics of Sudoku and Minesweeper.

Players must reveal the hidden colors of geometric shapes by analyzing color hints contained inside neighboring shapes.

All shapes start black. The player must determine the correct color assignment using logical deduction.

Tagline:
> Reveal the hidden colors.

---

# 2. Core Gameplay Loop

```
Start Level
↓
Observe Shapes
↓
Analyze Color Hints
↓
Select Shape
↓
Choose Color
↓
Instant Validation
↓
Complete Puzzle
↓
Unlock Next Level
```

---

# 3. Core Rules

## Shapes

MVP shapes:

- Triangle ▲
- Square ■
- Diamond ◆
- Circle ●

Shapes may repeat.

Example:

```
▲ ▲ ■ ◆
```

---

## Colors

MVP colors:

- Red 🔴
- Yellow 🟡
- Blue 🔵

---

# 4. Hint System

Each shape contains colored circles as hints.

The circles indicate the colors of neighboring shapes that are touching it.

Important rule:

> Hints only describe neighboring shapes, not the shape itself.

Example:

```
       ▲
       🔴

   ■       ◆
```

The triangle has a red hint, meaning one touching neighbor is red.

Multiple hints:

```
       ▲

    🔴 🟡 🔴
```

Means neighboring shapes contain:

- 2 Red shapes
- 1 Yellow shape

---

# 5. Board System

LUMON uses a free-form board system.

The board size and arrangement can change between levels.

Example Level 1:

```
      ▲

 ▲    ■    ▲
```

Example Level 20:

```
        ▲

 ■      ◆      ■

 ▲      ■      ◆
```

Shapes are considered neighbors when they touch:

- edges
- corners

---

# 6. Player Interaction

## Selecting Shape

Player taps a black shape.

Color selector appears:

```
Choose Color

🔴
🟡
🔵
```

---

## Correct Answer

Feedback:

- Shape reveals color
- Success animation
- Haptic feedback
- Sound effect


## Wrong Answer

Feedback:

- Red flash
- Shape shake animation
- Warning haptic
- Error sound

---

# 7. Level System

Levels are sequential:

```
Level 1
Level 2
Level 3
...
```

No difficulty menu.

Difficulty increases naturally through level progression.

The initial MVP catalog contains 10 levels. PLAY resumes at the first
unfinished level. Completing Level 10 shows the all-levels-completed state.

---

# 8. Progress System

Simple local progress.

Only completed level IDs are saved. Puzzle answers, lives, and hints reset
whenever a new session starts.

Example:

```
Level 1 ✓
Level 2 ✓
Level 3 🔒
Level 4 🔒
```

---

# 9. MVP Features

Included:

- Puzzle gameplay
- Free-form board
- Four shapes
- Three colors
- Hint system
- Instant validation
- Hint button
- Reset puzzle
- Level reset
- Progress saving
- 10-level Level Select with sequential unlocking
- Haptic feedback
- Sound effects

Excluded:

- Daily Puzzle
- Monetization
- Login
- Cloud sync
- Multiplayer
- Leaderboard

---

# 10. Hint Feature

Hint button reveals one correct color.

Example:

Before:

```
⬛
```

After:

```
🔵
```

---

# 11. UI Style

Visual direction:

Apple Minimal Style

Characteristics:

- Clean white background
- Geometric shapes
- Strong whitespace
- Simple colors
- Smooth animations

References:

- Monument Valley
- Blackbox

---

# 12. Screen Flow

## Home

```
LUMON

PLAY

Level Select

Settings
```

---

## Gameplay

```
        Puzzle Board


       Hint   Reset
```

---

## Completion

```
✨

Level Completed

Next Level
```

---

# 13. Animation

Color Reveal:

```
Black Shape

↓

Scale Animation

↓

Color Appears
```

Correct:

- Bounce
- Glow
- Particle effect

Wrong:

- Shake
- Red flash

---

# 14. Sound & Haptic

Sound:

- Tap
- Correct answer
- Wrong answer
- Level completion

Haptic:

- Selection
- Correct
- Wrong
- Completion
- Next Level

---

# 15. SwiftUI Architecture

```
LUMON

├── App
│
├── Models
│
├── GameEngine
│
├── PuzzleGenerator
│
├── Views
│
├── ViewModels
│
├── Services
│
└── Resources
```

---

# 16. Data Model Concept

```swift
struct PuzzlePiece {
    let id: UUID
    let type: ShapeType
    let position: CGPoint
    var color: PuzzleColor?
    let hints: [ColorHint]
}
```

---

# 17. Validation Engine

Flow:

```
Player Input

↓

Check Neighbor Relation

↓

Compare Hint Rules

↓

Return Result
```

---

# 18. Future Expansion

Possible future features:

- More colors
- More shapes
- Special pieces
- Advanced hint rules
- Themes
- Daily Puzzle
- Monetization
