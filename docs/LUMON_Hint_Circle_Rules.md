# LUMON — Hint Circle Rules

## 1. Logic and Deduction Rule

Hint circles do **not** have to appear on every shape.

However, whenever hint circles are provided, the overall set of hints in the level must be sufficient for the player to solve the puzzle through **logic, calculation, and deduction only**.

A valid LUMON level must not require the player to guess a color.

### Requirements

- Not every shape needs to contain a hint circle.
- The number of hints may vary between shapes.
- Some shapes may contain no hints at all.
- The combined information from all available hints must be sufficient to determine the correct color of every shape.
- The puzzle must have exactly **one valid solution**.
- A player who follows the available constraints correctly must be able to reach that solution without trial-and-error guessing.
- The level generator or validator must reject any puzzle that:
  - has more than one valid solution;
  - cannot be solved from the provided hints;
  - requires an arbitrary color guess to continue.

### Design Principle

> Every answer must be logically deducible from the information available in the puzzle.

---

## 2. Hint Circle Placement and Sizing Rule

Every hint circle must be placed **fully inside the boundaries of its parent shape**.

A hint circle must never cross, touch beyond, or visually overflow outside the shape's outline.

### Placement Requirements

- All hint circles must remain completely inside the shape.
- The hint-circle group must be centered on the parent shape's area centroid (its visual center).
- Multiple hint circles must form a visually symmetric arrangement around that center, with balanced spacing on each side.
- A single hint circle must sit at the center whenever the shape has enough space for it.
- For an asymmetric or narrow shape where exact centering or symmetry would break the boundary or spacing rules, use the closest valid, visually balanced arrangement.
- The order of hint circles is not fixed.
- Their exact positions inside the shape are flexible only while the centering, symmetry, readability, and containment rules remain satisfied.
- Hint circles must not overlap each other.
- Hint circles must not overlap the shape boundary.

### Size Requirements

Hint circles must:

- not be too small to recognize clearly;
- not be so large that they dominate the shape;
- remain visually consistent with the size of the parent shape;
- leave enough internal spacing between:
  - other hint circles;
  - the edge of the shape.

### Adaptive Sizing

Hint size should adapt to:

- the size of the parent shape;
- the number of hints inside the shape;
- the available internal area.

For example:

- a shape with one hint may use a slightly larger circle;
- a shape with four to six hints should automatically use smaller circles;
- all circles must still remain comfortably visible and fully contained.

### Visual Principle

> Hint circles should feel like information contained by the shape, not decoration placed on top of it.

---

## 3. Acceptance Criteria

A level passes these rules only if:

- [ ] Not all shapes are required to contain hints.
- [ ] The puzzle can be solved without guessing.
- [ ] The puzzle has exactly one valid solution.
- [ ] Every hint circle is completely inside its parent shape.
- [ ] No hint circle crosses the shape boundary.
- [ ] Hint circles are neither too small nor too large.
- [ ] Multiple hint circles fit without overlap.
- [ ] The hint-circle group is centered on the shape's area centroid, or as close to it as the shape's boundaries allow.
- [ ] Multiple hint circles form a visually symmetric arrangement around the center, or the closest balanced arrangement the shape can contain.
- [ ] Hint placement remains readable at the target device size.
- [ ] Hint order may vary as long as all constraints above are satisfied.
