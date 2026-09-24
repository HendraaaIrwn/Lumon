# LUMON Design System
## Visual Language Inspired by the Reference Artwork
**Version:** 1.0<br>
**Platform:** iOS 26+<br>
**UI Framework:** SwiftUI<br>
**Game:** LUMON<br>

> Design goal: build LUMON with a bold, playful, geometric visual identity using a dark teal field, warm cream typography, saturated geometric accents, and simple high-contrast forms.

---

# 1. Design Direction

LUMON should feel:

- geometric
- playful
- clever
- modern
- tactile
- minimal
- slightly retro
- visually bold

The visual language should avoid glossy mobile-game styling, excessive gradients, realistic materials, or generic “game UI” chrome.

The core visual idea is:

> **Flat geometry + strong color blocks + dark teal space + cream typography.**

The reference artwork uses simple circles, squares, rotated squares, and thick geometric forms floating over a deep teal background. LUMON should inherit that same visual rhythm.

---

# 2. Core Visual Principles

## 2.1 Geometry First

UI decoration should come from the same visual vocabulary as the puzzle itself:

- circles
- squares
- diamonds
- triangles
- thick bars
- cut-out geometric symbols

Avoid ornamental illustrations that do not belong to the puzzle language.

---

## 2.2 Flat, Not Glossy

Use:

- solid fills
- hard edges
- little or no shadow
- no glassmorphism
- no strong blur
- no skeuomorphic texture

Depth should come primarily from:

- scale
- spacing
- overlap hierarchy
- color contrast
- motion

---

## 2.3 High Contrast

Primary contrast:

```text
Dark Teal Background
        +
Warm Cream Foreground
        +
Bright Accent Colors
```

Every important game state must remain immediately readable.

---

## 2.4 Controlled Playfulness

The interface may feel playful, but layout should remain disciplined.

Use asymmetry for decorative shapes, while core gameplay UI remains:

- aligned
- predictable
- readable
- touch-friendly

---

# 3. Color System

The palette below uses the supplied LUMON game colors as reusable design tokens.

## 3.1 Core Palette

| Token | Hex | Usage |
|---|---|---|
| `lumonBackground` | `#01405A` | Main app/game background |
| `lumonCream` | `#FAF5D9` | Primary text, icons, neutral light shapes |
| `lumonOrange` | `#FB5D26` | Primary warm accent |
| `lumonYellow` | `#FDA319` | Yellow accent and puzzle color |
| `lumonCoral` | `#EC5828` | Secondary warm accent / error emphasis |
| `lumonRed` | `#EA4C1E` | Red puzzle color |
| `lumonBlue` | `#029CDA` | Blue puzzle color and bright accent |
| `lumonMutedBlue` | `#168BBC` | Quieter cool accent |
| `lumonEarth` | `#B27459` | Muted edge decoration |
| `lumonInk` | `#111C1E` | Deep contrast, outlines, selected states |

---

## 3.2 Gameplay Colors

LUMON's puzzle colors should stay visually distinct from the UI background.

Recommended mapping:

| Gameplay Color | Token | Hex |
|---|---|---|
| Red | `puzzleRed` | `#EA4C1E` |
| Yellow | `puzzleYellow` | `#FDA319` |
| Blue | `puzzleBlue` | `#029CDA` |
| Hidden / Unsolved | `puzzleHidden` | `#FAF5D9` |
| Hint Ring | `hintRing` | `#FAF5D9` |

> If gameplay requires red, yellow, and blue to be more literal than the reference palette, keep these as LUMON-branded interpretations rather than pure RGB primaries.

---

## 3.3 Semantic Colors

| State | Color |
|---|---|
| Correct | `lumonCream` glow + solved shape color |
| Wrong | `lumonCoral` |
| Selected | `lumonCream` outline |
| Disabled | Cream at 30–40% opacity |
| Locked / Solved | Original solved color + subtle cream confirmation |
| Life Lost | `lumonCoral` |
| Hint Activated | `lumonOrange` or `lumonCream` pulse |

---

# 4. SwiftUI Color Tokens

Suggested implementation:

```swift
extension Color {
    static let lumonBackground = Color(hex: "#01405A")
    static let lumonCream = Color(hex: "#FAF5D9")
    static let lumonOrange = Color(hex: "#FB5D26")
    static let lumonYellow = Color(hex: "#FDA319")
    static let lumonCoral = Color(hex: "#EC5828")
    static let lumonRed = Color(hex: "#EA4C1E")
    static let lumonBlue = Color(hex: "#029CDA")
    static let lumonMutedBlue = Color(hex: "#168BBC")
    static let lumonEarth = Color(hex: "#B27459")
    static let lumonInk = Color(hex: "#111C1E")
}
```

Keep gameplay colors mapped through semantic names instead of hardcoding hex values directly in views.

---

# 5. Typography

The reference uses a bold geometric sans-serif with strong uppercase display text.

## 5.1 Typography Direction

Use a bold geometric sans style.

For a native-only implementation, recommended system typography:

```swift
.font(.system(size: ..., weight: .black, design: .rounded))
```

or:

```swift
.font(.system(size: ..., weight: .heavy, design: .default))
```

Do not mix many font families.

---

## 5.2 Type Scale

| Style | Size | Weight | Usage |
|---|---:|---|---|
| Display XL | 52 | Black | LUMON logo / hero title |
| Display | 40 | Heavy | Level complete / major title |
| Title 1 | 32 | Bold | Screen title |
| Title 2 | 24 | Bold | Level title |
| Body | 17 | Medium | Explanations |
| Label | 15 | Semibold | Buttons |
| Caption | 12–13 | Medium | Secondary metadata |

---

## 5.3 Typography Rules

- Prefer uppercase for major branding and short labels.
- Avoid uppercase for long explanatory text.
- Use cream text on teal background.
- Keep line height compact for titles.
- Avoid ultra-thin type.
- Maximum two font weights per screen where possible.

---

# 6. Shape Language

## 6.1 Primary Shape Family

LUMON uses:

- Triangle
- Square
- Diamond
- Circle
- Custom Polygon

All shapes should be rendered with:

- flat fill
- clean edges
- no texture
- no bevel
- no glossy highlight

---

## 6.2 Shape Corner Rules

Squares and UI containers should generally use:

- square corners, or
- very small radius

Recommended:

```text
Gameplay shape: 0 pt radius
Small UI container: 4–8 pt radius
Large panel: 8–12 pt radius maximum
```

Avoid highly rounded cards.

---

## 6.3 Decorative Geometry

Background decoration may use:

- floating circles
- tilted squares
- small diamonds
- short bars
- fragmented rings

These must remain secondary to gameplay.

Recommended opacity:

```text
15%–45%
```

unless used as a strong intentional accent.

---

# 7. Stroke & Outline System

Use strong, graphic outlines.

Recommended tokens:

| Token | Width |
|---|---:|
| `strokeThin` | 2 pt |
| `strokeMedium` | 4 pt |
| `strokeBold` | 6 pt |
| `strokeHero` | 8 pt |

Use cream or ink depending on contrast.

Puzzle outlines should remain consistent across the board.

---

# 8. Spacing System

Use a 4-point base grid.

```text
4
8
12
16
20
24
32
40
48
64
```

Recommended tokens:

```text
spaceXS   = 4
spaceS    = 8
spaceM    = 16
spaceL    = 24
spaceXL   = 32
space2XL  = 48
space3XL  = 64
```

---

# 9. Layout Principles

## 9.1 Gameplay Screen

Preferred hierarchy:

```text
Top Area
- Level
- Lives

Center
- Puzzle artwork / board

Bottom
- Red / Yellow / Blue controls
- Hint
- Reset
```

The puzzle board should always remain the dominant object.

---

## 9.2 Safe Area

Never place important geometric decorations where they compete with:

- Dynamic Island
- navigation controls
- color buttons
- hint control
- home indicator

Decorative objects may partially exit the screen edge if intentional.

---

## 9.3 Board Scaling

Board uses normalized coordinates.

Artwork should:

- fit within the available viewport
- preserve aspect ratio
- never distort shape geometry
- leave enough breathing space around the artwork

Recommended minimum outer margin:

```text
24–32 pt
```

---

# 10. Puzzle Shape States

## 10.1 Hidden

```text
Fill: lumonCream
Hints: visible only if the puzzle definition allows them
Outline: none or subtle cream
```

---

## 10.2 Selected

```text
Fill: lumonCream
Outline: lumonInk
Scale: 1.02–1.04
```

Use a small visual lift, not a large zoom.

---

## 10.3 Correct / Locked

```text
Fill: solution color
Outline: optional cream confirmation
Interaction: disabled
```

---

## 10.4 Wrong

Feedback sequence:

```text
Color attempt
→ coral/red flash
→ horizontal shake
→ revert to hidden state
→ lose one life
```

Do not permanently color the piece incorrectly.

---

## 10.5 Hint Revealed

```text
Hidden
→ warm cream pulse
→ solution color reveal
→ locked
```

---

# 11. Hint Circle Design

## 11.1 Meaning

Hint circles indicate the colors of neighboring shapes according to the LUMON puzzle rules.

---

## 11.2 Placement

Every hint circle must:

- remain fully inside its parent shape
- never cross the shape boundary
- never overlap another hint circle
- remain readable at gameplay scale

Their order and internal arrangement may vary.

---

## 11.3 Size

Hint circles should adapt to:

- shape size
- shape geometry
- available internal area
- number of hints

Recommended relative diameter:

```text
12%–20% of the shortest dimension of the parent shape
```

For 4–6 hints, shrink proportionally while maintaining legibility.

---

## 11.4 Hint Ring Variant

When a hint requires ring treatment:

```text
Outer ring: lumonCream
Inner fill: hint color
```

The ring thickness should remain clearly visible but not dominate the shape.

---

# 12. Buttons

## 12.1 Primary Button

Style:

```text
Background: lumonCream
Foreground: lumonBackground
Text: Bold uppercase
Height: 52–56 pt
```

Optional geometric icon on the left.

---

## 12.2 Secondary Button

```text
Background: transparent
Stroke: lumonCream
Foreground: lumonCream
```

---

## 12.3 Color Buttons

The three gameplay color buttons should be pure geometric circles.

```text
Diameter: 52–64 pt
Spacing: 20–28 pt
```

Selected state:

- cream or ink ring
- small scale increase

Do not add text labels unless accessibility requires visible text.

---

# 13. Icons

Icon style:

- geometric
- thick
- simple
- monochrome where possible

Recommended:

- SF Symbols when visually compatible
- custom SwiftUI geometry for brand-specific icons

Avoid thin-line icons next to bold geometric artwork.

---

# 14. Navigation

Navigation should feel minimal.

Use:

- simple back arrow or geometric back icon
- no large navigation bars during gameplay
- no translucent glass bars

Gameplay should feel like a single visual canvas.

---

# 15. Lives UI

Three lives use the same six-armed geometric symbol inspired by the supplied reference artwork. Keep the three silhouettes visible as lives are lost.

State:

```text
Active: lumonRed
Lost: lumonRed at 30% opacity
```

---

# 16. Motion System

Motion should feel:

- quick
- elastic
- clean
- geometric

No excessive particles.

## 16.1 Tap

```text
Duration: 0.10–0.16 s
Scale: 0.96 → 1.00
```

---

## 16.2 Shape Select

```text
Duration: 0.16–0.22 s
Scale: 1.00 → 1.03
Outline appears
```

---

## 16.3 Correct Reveal

```text
Duration: 0.24–0.32 s
Hidden fill → solution color
Subtle glow/pulse
```

---

## 16.4 Wrong

```text
Duration: ~0.30 s
3–4 short horizontal shakes
Coral flash
```

---

## 16.5 Level Completion — Light Reveal

Signature LUMON animation:

```text
Final correct move
↓
Short pause
↓
Cream light pulse originates from solved area
↓
Light travels through connected shapes
↓
Artwork reaches full color
↓
Small scale settle
```

Target duration:

```text
0.8–1.4 s
```

This should be the strongest animation in the MVP.

---

# 17. Haptic System

Recommended:

| Action | Haptic |
|---|---|
| Shape select | Light selection |
| Color tap | Light impact |
| Correct | Success |
| Wrong | Error |
| Hint | Medium impact |
| Level complete | Success + subtle follow-up |

Keep haptics short and intentional.

---

# 18. Sound Direction

Audio should match the graphic visual identity:

- short
- percussive
- clean
- synthetic
- slightly retro

Suggested sound character:

```text
Tap      → soft click
Correct  → bright short tone
Wrong    → muted low pulse
Hint     → warm chime
Complete → short rising geometric motif
```

Avoid orchestral or overly cinematic sound.

---

# 19. Home Screen

Recommended structure:

```text
Decorative floating geometry

        LUMON

        PLAY

     LEVEL SELECT

       SETTINGS
```

Background:

```text
lumonBackground
```

Use decorative shapes to establish identity immediately.

---

# 20. Level Select

Use geometric tiles rather than conventional rounded cards.

Example:

```text
◆ 01   ■ 02   ● 03
▲ 04   ◆ 05   ■ 06
```

Completed level:

- cream or colored fill

Locked level:

- low-opacity outline

Current level:

- orange accent or cream outline

---

# 21. Settings Screen

Settings should remain extremely simple.

MVP:

- Sound
- Haptic
- Reset Progress

Use geometric toggles or native controls styled minimally.

---

# 22. Accessibility

LUMON must not communicate puzzle state by color alone.

Required:

- clear selected outline
- accessibility labels for color buttons
- VoiceOver shape identifiers
- sufficient contrast
- reduced motion support
- optional haptic differentiation

Example accessibility label:

```text
"Triangle, unsolved, three neighboring color hints: red, blue, blue."
```

---

# 23. Do / Don't

## Do

- use bold geometric shapes
- use dark teal generously
- use cream for strong contrast
- keep decoration playful but controlled
- preserve large negative space
- make puzzle artwork the hero

## Don't

- use glassmorphism
- use gradients everywhere
- use photorealistic textures
- use rounded-card-heavy layouts
- use thin typography
- add unnecessary UI chrome
- overcrowd the board

---

# 24. Design Tokens Summary

```text
BACKGROUND
#01405A

CREAM
#FAF5D9

ORANGE
#FB5D26

YELLOW
#FDA319

CORAL
#EC5828

RED
#EA4C1E

BLUE
#029CDA

MUTED BLUE
#168BBC

EARTH
#B27459

INK
#111C1E
```

Spacing:

```text
4 / 8 / 12 / 16 / 24 / 32 / 48 / 64
```

Corner Radius:

```text
0 / 4 / 8 / 12
```

Stroke:

```text
2 / 4 / 6 / 8
```

---

# 25. SwiftUI Token Example

```swift
enum LumonSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum LumonRadius {
    static let none: CGFloat = 0
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
}
```

---

# 26. Brand Principle

> **LUMON should look like a logic game made from a graphic-design poster.**

Every screen should feel like it belongs to the same world as the puzzle itself: bold geometry, strong color, negative space, and minimal but deliberate motion.
