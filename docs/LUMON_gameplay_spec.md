# LUMON — Gameplay Specification

> **Status:** draft implementable / original adaptation
>
> **Purpose:** define a small, turn-based, abstract strategy game for LUMON. It takes only high-level inspiration from a colour-and-geometry trailer, then makes its own rules, board, terminology, visual language, UX, and code contract.
>
> **Important provenance rule:** every statement in this document is marked as **Confirmed**, **Inferred**, or **Proposed**. Do not ship an inference as though it were a source fact.

## 1. Evidence and provenance

### 1.1 Source register

| ID | Source | What was inspected | Reliable finding | Confidence |
|---|---|---|---|---|
| S1 | [YouTube: RYB Trailer](https://youtu.be/EvWcLcBdfa4?si=GM-iI-W1j2nqbq7_) | The linked video and its public metadata | Title `RYB Trailer`; channel `FLEB`; runtime approximately 68 seconds; the description says “A Colorful Game of Logic!” | Confirmed |
| S2 | Visual frames from S1 | Frames sampled across the trailer | Abstract red, yellow, blue, black and white geometric compositions appear, including triangular, square, and octagonal forms. No match UI, player turn, tile hand, rule text, capture animation, score, or end-state is shown. | Confirmed |
| S3 | Earlier referenced-chat answer | A prior response in the linked ChatGPT conversation asserted 18 slots, 9 tiles per player, colour bonuses, timers, and multiplayer modes, but it did not preserve public URLs or a rules document. | These claims are **not independently verifiable from S1** and are not used as confirmed requirements below. | Confirmed limitation |

### 1.2 What this means

The trailer can support an aesthetic observation: it uses a constrained, high-contrast colour-and-geometry language. It **cannot** establish gameplay rules. In particular, the following are unknown from the reviewed evidence:

- number of players;
- board shape and cell count;
- whether pieces are tiles, cards, or tokens;
- turn order and placement restrictions;
- whether a colour cycle exists;
- whether pieces capture, flip, move, stack, score, or merely compose a pattern;
- win, draw, AI, timer, and network rules.

If an official RYB rulebook, store page, developer page, or playable build becomes available, add it to the source register and replace the relevant “unknown” items with cited facts. Until then, LUMON should be treated as an original game design, not a literal reverse-engineering.

### 1.3 Inferred observations from the trailer

The following are **inferences**, not rules facts:

| Observation | Reasonable design inference | Must not be claimed as |
|---|---|---|
| Repeated primary-colour and geometric compositions | A compact visual language built around three readable categories could suit LUMON. | Proof that RYB has a three-way combat system, colours-as-factions, or tiles. |
| Dense, symmetric abstract layouts | Spatial composition and adjacency can be a useful LUMON design direction. | Proof of a specific board topology, cell count, or legal-move rule. |
| Tagline “A Colorful Game of Logic!” | The source positions itself as an abstract/puzzle-like experience. | A complete rulebook or confirmation of player count and victory condition. |

The adaptation deliberately stops at these broad design cues. Every concrete game system below is marked **Proposed** for LUMON.

### 1.4 Design and IP boundary

LUMON may use the broad genre ingredients of abstract placement, numeric strength, and a cyclic counter system. It must not reuse another work’s name, logo, trailer footage, graphics, sound, written rules, board artwork, piece silhouettes, marketing copy, or exact branded presentation. The proposed mechanics below should be tuned and presented as LUMON’s own system.

---

## 2. Design target

### 2.1 One-sentence pitch — Proposed

**LUMON is a fast, two-player tactical placement duel: deploy limited Prism tiles onto a compact hex board, exploit a three-aspect counter cycle, and secure more illuminated territory than your rival.**

### 2.2 Gameplay pillars — Proposed

1. **Readable in one glance.** A player can see whose turn it is, which tiles remain, which cells are legal, and why every capture happened.
2. **Small but consequential.** One match has 18 turns maximum; every tile is unique and cannot be recovered once played.
3. **Counterplay beats raw power.** A lower printed value can prevail when its Aspect counters the defender’s Aspect.
4. **Position matters.** Central cells offer more adjacencies; edges offer safety; a placement can resolve several adjacent duels.
5. **Deterministic and inspectable.** No hidden rolls, random combat, or ambiguous tie resolution in the ranked/default ruleset.

### 2.3 Match envelope — Proposed

| Parameter | Default | Rationale |
|---|---:|---|
| Players | 2 | Tight tactical interaction and simple online synchronization. |
| Board cells | 18 | Nine placements each fill the board exactly. |
| Starting hand | 9 tiles each | Enough variety without hand-management overhead. |
| Turns | 18 maximum | A compact session, typically 3–8 minutes. |
| Turn timer | 20 seconds, optional | Good for casual quick play; untimed mode remains available. |
| Hidden information | None | Supports fair local play, spectator mode, and reproducible AI tests. |

---

## 3. LUMON components

All components in this section are **Proposed**.

### 3.1 Aspects (the counter cycle)

LUMON’s pieces have an **Aspect**. The names and presentation are original LUMON terminology:

| Aspect | Suggested icon | Counters | Is countered by |
|---|---|---|---|
| Ember | triangle | Tide | Gale |
| Tide | circle | Gale | Ember |
| Gale | diamond | Ember | Tide |

The clockwise relationship is:

```text
Ember → Tide → Gale → Ember
```

When an attacking tile counters a defending tile, it gets `+1` effective power for that duel only. A tile never gains both a bonus and a penalty; non-counter relationships get `+0`.

> **Alternative skin, not a rule change:** the UI may render the three Aspects in red/yellow/blue to echo the broad colour triad observed in S1. Avoid referring to this as an RYB rule.

### 3.2 Prism tiles

Each player owns the same nine-tile set. A tile is defined by `Aspect × Rank`, with rank 1–3.

| Tile IDs | Aspect | Printed rank | Quantity/player |
|---|---|---:|---:|
| E1, E2, E3 | Ember | 1, 2, 3 | 3 |
| T1, T2, T3 | Tide | 1, 2, 3 | 3 |
| G1, G2, G3 | Gale | 1, 2, 3 | 3 |

Tile attributes:

- `id`: stable unique identity, for replay/networking;
- `owner`: the player who currently controls it; capture changes this field;
- `originalOwner`: used for analytics and capture score;
- `aspect`: Ember, Tide, or Gale; immutable;
- `rank`: 1, 2, or 3; immutable;
- `cell`: board location once placed;
- `capturedOnTurn`: optional audit data, not a gameplay modifier.

There are no movement points, health bars, consumables, buffs, deck draws, or random effects in the MVP.

---

## 4. Board topology

### 4.1 Shape — Proposed

The board is a 3 × 6 **offset hex grid**: 18 cells, three rows, and six columns. It is deliberately not presented as a copy of any observed board because S1 does not show one.

```text
          00 — 01 — 02 — 03 — 04 — 05
        10 — 11 — 12 — 13 — 14 — 15
          20 — 21 — 22 — 23 — 24 — 25
```

Rows 0 and 2 are visually shifted right by half a cell. Each cell has up to six neighbors. A placement is legal on any empty cell, so the opening player has 18 choices; the second has 17.

### 4.2 Canonical adjacency — Proposed

Use this table as the authoritative source of truth in the first implementation. It avoids UI-coordinate ambiguity.

| Cell | Neighbors |
|---|---|
| 00 | 01, 10 |
| 01 | 00, 02, 10, 11 |
| 02 | 01, 03, 11, 12 |
| 03 | 02, 04, 12, 13 |
| 04 | 03, 05, 13, 14 |
| 05 | 04, 14, 15 |
| 10 | 00, 01, 11, 20, 21 |
| 11 | 01, 02, 10, 12, 21, 22 |
| 12 | 02, 03, 11, 13, 22, 23 |
| 13 | 03, 04, 12, 14, 23, 24 |
| 14 | 04, 05, 13, 15, 24, 25 |
| 15 | 05, 14, 25 |
| 20 | 10, 21 |
| 21 | 10, 11, 20, 22 |
| 22 | 11, 12, 21, 23 |
| 23 | 12, 13, 22, 24 |
| 24 | 13, 14, 23, 25 |
| 25 | 14, 15, 24 |

### 4.3 Topology validation — Proposed acceptance criteria

- Adjacency is symmetrical: if A lists B, B lists A.
- All cell IDs occur once and only once.
- The degree of each cell is 2–6.
- The board has 18 cells and 37 undirected edges.
- UI hit-testing resolves to this same cell ID map; the rules engine must not infer neighbors from pixels.

---

## 5. Match setup and turn structure

All rules in this section are **Proposed**.

### 5.1 Setup

1. Create an empty 18-cell board.
2. Create two identical nine-tile reserves, one per player.
3. Choose `Player A` as starter using an explicit pre-match choice, alternating starter in a best-of-three, or a server-supplied seed. Record the result in match metadata.
4. Set phase to `selectingTile` for the active player.

### 5.2 One turn

1. **Select:** active player taps one unused tile from their reserve.
2. **Preview:** highlight empty cells as legal. On hovering/tapping a cell, show predicted combat against every adjacent enemy tile.
3. **Place:** player confirms one empty cell.
4. **Resolve:** resolve a duel separately against every adjacent enemy tile, in stable ascending cell-ID order.
5. **Animate:** show each bonus, effective power, win/loss/tie, and ownership flip before the next phase.
6. **Check end:** if both reserves are empty, score and finish. Otherwise switch active player.

### 5.3 Legal move definition

```text
legalMove(state, player, tileID, targetCell) is true when:
  state.phase == selectingTile or state.phase == selectingCell
  state.activePlayer == player
  tileID is in player’s unused reserve
  targetCell exists
  targetCell is empty
  match has not ended
```

No adjacency requirement exists for MVP. This keeps turn one legal and allows strategic sacrifice, but it should be tested as a balance knob later.

### 5.4 Invalid-action behavior

Reject invalid moves atomically: no board mutation, no turn advance, no timer reset, no partial animation. Show a local, specific message such as “That Prism was already played” or “Choose an empty cell.” For online matches, the server’s rejection is authoritative.

---

## 6. Combat and capture resolution

All rules in this section are **Proposed**.

### 6.1 Effective power

For a single attacker/defender duel:

```text
effectivePower = printedRank + aspectBonus
aspectBonus = 1 when attacker counters defender; otherwise 0
```

Examples:

| Attacker | Defender | Calculation | Outcome |
|---|---|---|---|
| Ember 1 | Tide 1 | 1 + 1 vs 1 | attacker captures |
| Tide 2 | Gale 3 | 2 + 1 vs 3 | tie; no capture |
| Gale 3 | Ember 2 | 3 + 1 vs 2 | attacker captures |
| Tide 3 | Ember 3 | 3 vs 3 | tie; no capture |
| Ember 2 | Gale 2 | 2 vs 2 + 1 if defender were attacking; here it is not | attacker does not capture |

The bonus is directional. The placed tile is always the attacker for that turn’s resolution. Existing neighbors do not counterattack in the same turn.

### 6.2 Capture rule

- If attacker effective power is **greater** than defender effective power, defender’s `owner` changes to attacker’s owner and the capture count for that attacker increases by one.
- If equal or less, ownership stays unchanged.
- The new tile remains in its target cell regardless of all duel outcomes.
- One placement may capture zero, one, or multiple adjacent enemy tiles.
- A tile captured earlier in the same resolution becomes friendly and is not resolved a second time.

### 6.3 Resolution order

Combat outcomes are designed to be order-independent because the attacker’s rank/aspect never changes. Still, process enemy neighbors in ascending cell ID so event logs and animations are deterministic:

```text
place → enumerate adjacent enemy cells → sort IDs → resolve each duel → emit events
```

### 6.4 Why ties do not capture

Tie means the defending Prism holds. This gives the defender a slight positional stability and makes the colour counter matter without making every contact flip. Do not add a hidden “defender wins ties” stat: it is simply “no ownership change.”

---

## 7. Scoring, win, draw, and tiebreaks

All rules in this section are **Proposed**.

### 7.1 End condition

The match ends immediately after resolution of turn 18, because both players have placed all nine Prisms. An early end is not part of MVP.

### 7.2 Primary score

At match end, each player receives one point for each board tile they control. All 18 cells are occupied.

```text
territoryScore(player) = count(board tiles where owner == player)
```

Higher territory score wins.

### 7.3 Deterministic tiebreak chain

If primary score is equal:

1. Higher **captures made** wins.
2. If still equal, higher **sum of printed ranks of controlled tiles** wins.
3. If still equal, result is a **draw**.

This keeps the game reproducible and avoids a random coin flip deciding a tactical match. Present all three values in the results screen.

### 7.4 Match-series tiebreak — optional, proposed

For a ranked best-of-three series, a drawn round awards 0.5 round point to each player. Starter alternates every round. If the series itself is tied, the series is a draw; do not introduce a sudden-death rule until playtests prove a need.

---

## 8. UX flow

All UX is **Proposed** and uses LUMON terminology.

```text
Home
  → Play
    → Mode Select (local / AI / online)
      → Match Setup (timer, accessibility options, starter)
        → Board
          → Select Prism
            → Combat Preview
              → Confirm Placement
                → Resolution Timeline
                  → Opponent Turn or Results
                    → Rematch / Back to Home
```

### 8.1 Board screen requirements

- Top bar: active player identity, phase text, turn `n / 18`, timer if enabled, pause/settings.
- Board: 18 large tappable hex cells; selected cell and legal cells distinguishable without colour alone.
- Reserve: the active player’s remaining nine-to-zero Prism tiles, with aspect icon, numeral, and disabled state when spent.
- Opponent reserve: count plus optionally visible face-up tiles, since the MVP has no hidden information.
- Preview panel: “Ember 2 attacks Tide 2: 2 + 1 = 3 vs 2 → capture” for each neighboring enemy. Never rely only on glow or colour.
- Resolution timeline: compact event chips, e.g. `12 captured 11 (Gale 3 +1 > Ember 3)`.

### 8.2 Accessibility requirements

- Never encode Aspects by colour alone: use shape icon, label, and optional pattern.
- Dynamic Type must not obscure tile values; use a fixed minimum cell width and accessibility scaling alternatives.
- Provide VoiceOver labels such as “Cell 12, occupied by Player Two, Tide rank two, adjacent to four cells.”
- Respect Reduce Motion: replace flip animation with a crossfade and spoken/textual resolution event.
- Provide haptics only as an optional feedback channel.

### 8.3 Online UX and trust

The client may preview a move locally, but it must wait for server acceptance before committing a networked board state. Display a small “confirming move” state and provide a replayable event log after reconnection.

---

## 9. Game-state machine

All states are **Proposed**.

```text
setup
  → selectingTile
  → selectingCell
  → confirmingPlacement
  → resolving
  → checkingEnd
      ├─ → selectingTile (next player)
      └─ → results

results → setup (rematch) | abandoned (exit)
```

| State | Allowed input | Exit condition |
|---|---|---|
| `setup` | choose options / start | seed and starter assigned |
| `selectingTile` | select unused own Prism | valid tile selected |
| `selectingCell` | select empty board cell / cancel | valid cell selected or selection cancelled |
| `confirmingPlacement` | confirm / cancel | confirmed or cancelled |
| `resolving` | none except reduced-motion skip | all ordered duel events applied |
| `checkingEnd` | none | board full → results; else turn swap |
| `results` | rematch / exit / replay | user action |
| `abandoned` | none | terminal |

In the engine, UI phases are advisory. The authoritative state transition is a single `apply(move:)` transaction that either returns a complete new state plus events or an error.

---

## 10. Swift data-model example

The following is **Proposed** application-domain code. It is intentionally UI-independent so SwiftUI, SpriteKit, an AI process, and a backend adapter can share the same rules.

```swift
import Foundation

enum PlayerID: String, Codable, CaseIterable, Sendable {
    case one, two

    var opponent: PlayerID { self == .one ? .two : .one }
}

enum Aspect: String, Codable, CaseIterable, Sendable {
    case ember, tide, gale

    func counters(_ other: Aspect) -> Bool {
        switch (self, other) {
        case (.ember, .tide), (.tide, .gale), (.gale, .ember): true
        default: false
        }
    }
}

struct CellID: RawRepresentable, Hashable, Codable, Comparable, Sendable {
    let rawValue: String

    static func < (lhs: CellID, rhs: CellID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct PrismID: RawRepresentable, Hashable, Codable, Sendable {
    let rawValue: String
}

struct Prism: Identifiable, Equatable, Codable, Sendable {
    let id: PrismID
    let originalOwner: PlayerID
    var owner: PlayerID
    let aspect: Aspect
    let rank: Int // Validate 1...3 at construction.
}

struct Board: Equatable, Codable, Sendable {
    var cells: [CellID: Prism?]
    let adjacency: [CellID: Set<CellID>]

    func neighbors(of cell: CellID) -> [CellID] {
        Array(adjacency[cell, default: []]).sorted()
    }
}

struct Move: Equatable, Codable, Sendable {
    let player: PlayerID
    let prismID: PrismID
    let target: CellID
}

enum MatchPhase: String, Codable, Sendable {
    case setup, selectingTile, resolving, results, abandoned
}

struct MatchState: Equatable, Codable, Sendable {
    var phase: MatchPhase
    var activePlayer: PlayerID
    var turn: Int
    var board: Board
    var unusedPrisms: [PlayerID: [Prism]]
    var captures: [PlayerID: Int]
}

enum RuleEvent: Equatable, Codable, Sendable {
    case placed(prismID: PrismID, at: CellID)
    case duel(attacker: PrismID, defender: PrismID, attackerPower: Int, defenderPower: Int)
    case captured(prismID: PrismID, from: PlayerID, by: PlayerID)
    case held(prismID: PrismID)
    case turnChanged(to: PlayerID)
    case matchEnded
}
```

### 10.1 Invariants

- `turn` is `0...18` and is incremented only after a successful placement.
- A Prism exists in exactly one location: one reserve or one occupied board cell.
- An occupied cell has one Prism, never a stack.
- `owner` may differ from `originalOwner`; `aspect` and `rank` never do.
- `unusedPrisms[player]` contains only Prisms whose `originalOwner == player`.
- In a completed match, board occupancy equals 18 and both reserves are empty.
- Every board cell used by a move exists in both `cells` and `adjacency`.

---

## 11. Rules-engine pseudocode

```text
function applyMove(state, move):
    require state.phase == selectingTile
    require state.activePlayer == move.player
    require state.turn < 18
    require board contains move.target
    require board[move.target] is empty

    attacker = remove unused prism(move.prismID) from state.unusedPrisms[move.player]
    require attacker exists

    board[move.target] = attacker
    events = [placed(attacker.id, move.target)]

    enemyCells = neighbors(move.target)
        .filter(cell => board[cell] exists and board[cell].owner != move.player)
        .sortAscending()

    for cell in enemyCells:
        defender = board[cell]
        attackerPower = attacker.rank + (attacker.aspect counters defender.aspect ? 1 : 0)
        defenderPower = defender.rank
        events.append(duel(attacker.id, defender.id, attackerPower, defenderPower))

        if attackerPower > defenderPower:
            board[cell].owner = move.player
            state.captures[move.player] += 1
            events.append(captured(defender.id, defender.owner, move.player))
        else:
            events.append(held(defender.id))

    state.turn += 1
    if state.turn == 18:
        state.phase = results
        events.append(matchEnded)
    else:
        state.activePlayer = state.activePlayer.opponent
        state.phase = selectingTile
        events.append(turnChanged(state.activePlayer))

    return state, events
```

Implementation note: capture event construction must save `defender.owner` before changing it, otherwise the “from” owner will be logged incorrectly.

---

## 12. AI opponents

All tiers are **Proposed**. AI must only select moves generated by the same `legalMoves` function used by humans.

### 12.1 Difficulty tiers

| Tier | Method | Target behavior |
|---|---|---|
| Easy | Random legal move; optional avoid immediate multi-capture if a simple filter is desired | Friendly, unpredictable, clearly beatable. |
| Medium | Heuristic evaluation of every legal move, choosing the best with 15–25% weighted randomness | Teaches counter cycle and positioning without perfect play. |
| Hard | Depth-limited minimax with alpha-beta pruning and deterministic evaluation | Strong tactical opponent within mobile time budget. |

### 12.2 Heuristic evaluation

At a candidate state, use a weighted sum from the AI player’s view:

```text
score = 100 * territoryDifference
      + 20  * captureDifference
      + 5   * controlledRankSumDifference
      + 3   * centerControlDifference
      + 2   * safeAdjacencyDifference
      - 4   * exposedToCounterThreatDifference
```

Definitions to make this testable:

- `centerControl`: controlled cells with degree 6, then degree 5.
- `safeAdjacency`: friendly neighboring pairs not immediately capturable by any unused opponent Prism.
- `exposedToCounterThreat`: controlled tiles that at least one unused opponent Prism could capture if placed in an adjacent empty cell on its next turn.

Do not evaluate animations, UI state, or wall-clock time inside the engine score.

### 12.3 Minimax outline

```text
function minimax(state, depth, alpha, beta, maximizingPlayer):
    if depth == 0 or state.phase == results:
        return evaluate(state, maximizingPlayer)

    moves = orderedLegalMoves(state) // captures first, then central cells, stable ID order
    if state.activePlayer == maximizingPlayer:
        value = -infinity
        for move in moves:
            value = max(value, minimax(apply(move), depth - 1, alpha, beta, maximizingPlayer))
            alpha = max(alpha, value)
            if alpha >= beta: break
        return value
    else:
        value = +infinity
        for move in moves:
            value = min(value, minimax(apply(move), depth - 1, alpha, beta, maximizingPlayer))
            beta = min(beta, value)
            if alpha >= beta: break
        return value
```

Suggested mobile budget: iterative deepening with a 300–700 ms time limit, cancelling cleanly when the user leaves the match. Preserve the last fully evaluated depth. For deterministic tests, use fixed depth and no time limit.

---

## 13. Test plan

### 13.1 Unit tests for rules — Proposed

| ID | Given | Action | Expected result |
|---|---|---|---|
| R-01 | Empty initial board | list legal moves | 9 × 18 moves for starter. |
| R-02 | Tile E1 and enemy T1 adjacent | place E1 | `1 + 1 > 1`; T1 owner flips. |
| R-03 | Tile T2 and enemy G3 adjacent | place T2 | `2 + 1 == 3`; G3 holds. |
| R-04 | Tile G3 and enemy E2 adjacent | place G3 | `3 + 1 > 2`; E2 flips. |
| R-05 | Tile E2 adjacent to enemy G2 | place E2 | no Aspect bonus; equal ranks; G2 holds. |
| R-06 | Attacker adjacent to two enemies it can defeat | place attacker | both flip; two ordered capture events. |
| R-07 | Attacker adjacent to friendly, enemy, and empty cells | place attacker | only the enemy is evaluated. |
| R-08 | Selected Prism already used | submit move | error; state byte-for-byte unchanged. |
| R-09 | Occupied target cell | submit move | error; active player and timer state unchanged. |
| R-10 | Turn 17 valid final placement | apply move | phase becomes results; no turn-changed event. |
| R-11 | 9–9 territory; Player A made more captures | score | Player A wins by captures. |
| R-12 | all three score levels equal | score | explicit draw. |

### 13.2 Property tests — Proposed

- Generate many legal random matches. After each applied move, assert all invariants in section 10.1.
- Replaying the same initial state and sequence of moves must yield identical state and ordered events.
- For every legal placement, occupancy increases by exactly one; capture changes ownership but never occupancy.
- Swapping player labels and mirrored board coordinates should preserve outcome symmetry when the starter is swapped too.
- No generated legal move may target an occupied or unknown cell.

### 13.3 UI acceptance checks — Proposed

- A colour-blind test participant can identify all three Aspects without colour alone.
- The combat preview agrees with the engine event log for every previewed move.
- Tapping a tile then an invalid cell cannot consume the tile.
- Reduce Motion gives equivalent result and explanation.
- Offline local play, AI play, and online-replayed moves all use the same rules module.

---

## 14. Balance knobs and playtest questions

All of these are deliberate **Proposed** tuning controls. Change one at a time and record match telemetry.

| Knob | Current default | What it changes | Risk if raised |
|---|---:|---|---|
| Aspect bonus | +1 | Counter-cycle leverage | Too large makes rank 3 feel weak. |
| Rank range | 1–3 | Readability and tile differentiation | Wider range adds arithmetic burden. |
| Board cells | 18 | Match length and contact density | Larger boards can dilute interaction. |
| Reserve | 9 fixed tiles | Planning depth | More tiles make AI/search and UI heavier. |
| Capture comparison | strict greater-than | Defender stability | Greater-or-equal causes frequent flipping. |
| Resolution radius | adjacent only | Tactical locality | Distance effects reduce readability. |
| Placement rule | any empty cell | Openness | Adjacency-only may create forced openings. |
| First-player compensation | none | Fairness | A compensation rule can overcorrect. |
| Timer | 20 s optional | Pace | Short timers harm accessibility. |

### 14.1 Telemetry to collect in private playtests

- starter win rate over at least 100 balanced AI-vs-AI and 50 human matches;
- first placement’s eventual owner and survival rate;
- per-Aspect play rate, capture rate, and final control rate;
- average captures per move and zero-capture turns;
- match duration, timeout rate, and rematch rate;
- number of invalid taps per match and whether users opened combat preview.

Investigate before changing rules when: starter win rate exceeds 55%, one Aspect’s win-adjusted usage dominates, or players regularly fail to predict a capture.

---

## 15. Edge cases and decisions

| Case | MVP decision — Proposed |
|---|---|
| Simultaneous-looking multi-capture | Resolve in stable cell-ID order, but final result is designed to be order-independent. |
| Tie in a duel | Defender holds; no flip. |
| Tie in all final score levels | Match draw. |
| Timer expires | Server/local engine auto-chooses a legal move using a deterministic fallback: lowest unused Prism ID, then lowest empty Cell ID. In casual mode, offer pause instead. |
| Disconnect during online resolution | Resume from last acknowledged event index; never recompute from UI animation state. |
| Duplicate online move request | Give each move a monotonic `turn` and idempotency key; accept only once. |
| Client disagrees with server | Server state and event log win; client renders a correction/replay. |
| App backgrounded | Pause local/AI match. Online timer policy is explicitly shown before starting. |
| Player quits | Record resignation; do not mutate the final board as a pretend normal score. |
| Accessibility colour setting | Icons, labels, patterns, and VoiceOver remain active; palette is optional. |
| Future expansion tile | Disable from ranked/MVP ruleset unless both engine version and data schema support it. |

---

## 16. Implementation checklist

### Rules module

- [ ] Define `Aspect`, `PlayerID`, `Prism`, `CellID`, `Board`, `Move`, and `MatchState`.
- [ ] Encode the 18-cell canonical adjacency map and validate it at startup/tests.
- [ ] Implement `legalMoves`, `applyMove`, score calculation, and stable event emission as pure functions.
- [ ] Add all unit and property tests in section 13 before UI polish.
- [ ] Serialize initial state, moves, and events for replay/debugging.

### SwiftUI client

- [ ] Build board rendering from `CellID` and layout metadata, not rules logic in views.
- [ ] Add reserve, selection, legal-cell highlighting, preview, and resolution log.
- [ ] Bind views to a `MatchStore` that invokes the pure engine.
- [ ] Add VoiceOver labels, non-colour aspect identifiers, Dynamic Type, and Reduce Motion behavior.
- [ ] Test at compact and accessibility sizes on a real device/simulator.

### AI

- [ ] Use only engine-generated legal moves.
- [ ] Implement random and heuristic AI first.
- [ ] Add minimax only after profiling a real 18-turn match on target devices.
- [ ] Seed all non-ranked randomness for reproducible bug reports.

### Online (later)

- [ ] Make server validation authoritative.
- [ ] Store append-only move/event log plus game/rules version.
- [ ] Add turn idempotency, reconnect replay, timeout behavior, and abuse/rate limiting.
- [ ] Test stale-client and duplicate-submission paths.

### Product and art

- [ ] Create original LUMON marks, board geometry, Prism icons, sound, and copy.
- [ ] Keep a source register for all externally inspired materials.
- [ ] Run a terminology and visual review to ensure no RYB branding/assets were reused.

---

## 17. MVP roadmap

| Slice | Scope | Done when |
|---|---|---|
| 1. Deterministic core | Models, board, move validation, combat, scoring | Unit tests R-01 through R-12 pass. |
| 2. Local playable board | SwiftUI board, two-player pass-and-play, results | Two people can complete a full 18-turn match without manual state edits. |
| 3. Explainability/accessibility | Combat preview, event log, VoiceOver, Reduce Motion | Every capture is explained in text and not by colour alone. |
| 4. AI | Easy and Medium heuristic AI | AI makes only legal moves and responds within the interaction budget. |
| 5. Balance loop | Telemetry, playtest scripts, targeted knob changes | Starter advantage and aspect dominance have measured evidence. |
| 6. Hard AI / online | Minimax and authoritative match service | Only after the local ruleset is stable and replay tests are reliable. |

## 18. Open questions before production

1. Is LUMON intended to be a purely abstract game, or should the Aspects be tied to existing LUMON lore?
2. Should the visual board use flat hexes, a geometric “light prism” motif, or another original art direction?
3. Is 3–8 minutes the desired session length for LUMON’s target players?
4. Is online multiplayer in the initial release, or should it remain a later slice after pass-and-play and AI validation?
5. Does the product need a casual hidden-hand variant? If yes, it requires a separate UX and AI design, not a small toggle.

---

## Appendix A — terminology map

| Design term | Meaning |
|---|---|
| Aspect | One member of the Ember/Tide/Gale counter cycle. |
| Prism | A placed tile with an Aspect and printed rank. |
| Reserve | A player’s unplayed Prisms. |
| Rank | Printed strength, 1–3. |
| Effective power | Rank plus any directional Aspect bonus for one duel. |
| Capture | Changing a board Prism’s current owner. |
| Territory | Number of board Prisms currently controlled by a player. |

## Appendix B — evidence update template

When a new public source is found, add a row to section 1.1 with URL, access date, exact observation, and confidence. Then update only the directly affected rules sections. For example:

```text
Source: [official rulebook URL]
Accessed: YYYY-MM-DD
Exact claim: quote or precise visual observation
Classification: Confirmed
Affected sections: 3.2, 4.1, 6.1
Decision: retain / revise / remove the matching LUMON proposal
```
