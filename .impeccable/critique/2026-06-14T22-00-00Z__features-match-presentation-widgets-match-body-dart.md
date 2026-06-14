---
target: match screen (full surface)
total_score: 34
p0_count: 0
p1_count: 0
p2_count: 2
p3_count: 3
timestamp: 2026-06-14T22-00-00Z
slug: features-match-presentation-widgets-match-body-dart
---
# Critique: Match screen (post-audit fixes)

**Target:** `match_body.dart` and match presentation widgets (header, timer, board, resources, actions, effects, target picker)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 4 | Timer, phase bar, turn strip, board summary, resources |
| 2 | Match System / Real World | 4 | Portuguese phase titles, reminders, resource labels |
| 3 | User Control and Freedom | 3 | Action undo strong; board edits still immediate |
| 4 | Consistency and Standards | 4 | Unified surface+border panels; 44pt controls |
| 5 | Error Prevention | 3 | Validations + target picker before evolve flows |
| 6 | Recognition Rather Than Recall | 4 | Collapsed board summary + phase focus mode |
| 7 | Flexibility and Efficiency | 3 | Progressive phase list; scroll offset still magic |
| 8 | Aesthetic and Minimalist Design | 4 | Slim pinned header; flat slot rows |
| 9 | Error Recovery | 3 | Actions undo; board lacks inline revert |
| 10 | Help and Documentation | 4 | Phase help, coach tips, tracker honesty notice |
| **Total** | | **34/40** | **Good — minor recovery and polish gaps** |

## Anti-Patterns Verdict

**Pass.** Tonal dark tool UI with Wise Violet accents. No nested card stacks, no AI scaffold eyebrows, no generic SaaS chrome. Surface vocabulary now consistent across board, resources, and target picker.

**Deterministic scan:** `detect.mjs` on Dart files — 0 findings (expected).

**Browser visualization:** Skipped — Flutter native.

## Overall Impression

The match screen crossed from "acceptable with header/visibility debt" to a coherent table-side assistant. The pinned header answers where you are in the turn; the scroll body carries phase focus, board/resources, and actions; the bottom CTA stays thumb-reachable. Touch-target and copy gaps from the match audit are largely closed.

## What's Working

1. **Header diet** — Timer → Fase X de N → turn strip only; board/resources scroll below phases.
2. **Touch targets** — Board chips, timer, resource +/- , turn context, target picker rows, effect chips at ≥44pt with regression tests.
3. **Portuguese throughout** — Phase JSON titles, reminders (`Fase de compra`, `Fase DON!!`), `Pontos de ação`.
4. **Flat panel vocabulary** — Board, resources, target picker share surface + outline border + dividers.

## Priority Issues

### [P2] Board edits lack undo affordance

- **Fix:** Snackbar undo or confirm on slot remove.
- **Command:** `/impeccable harden match board`

### [P2] Tracker notice dismiss still undersized

- **Location:** `match_tracker_notice.dart` — 28×28 constraints
- **Command:** `/impeccable adapt match tracker notice`

### [P3] Fragile phase scroll offset (`88.0` magic number)

- **Location:** `match_body.dart:81-83`
- **Command:** `/impeccable optimize match scroll`

### [P3] Nested semantics on board expand header

- **Command:** `/impeccable harden match board`

### [P3] Timer bar still uses `Card` widget

- **Command:** `/impeccable polish match timer`

## Persona Red Flags

**Jordan:** Much improved — board summary visible, Portuguese copy consistent.

**Casey:** Header lighter; actions still below fold on small phones but reachable via scroll.

**Sam:** Touch targets fixed on primary controls; tracker dismiss still small.

**Morgan:** Board flags visible in collapsed summary; evolve flow target picker flattened.
