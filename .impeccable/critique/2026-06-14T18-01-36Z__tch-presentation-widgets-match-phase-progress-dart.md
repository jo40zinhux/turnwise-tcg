---
target: match page - board and steps visualization
total_score: 26
p0_count: 0
p1_count: 2
p2_count: 3
timestamp: 2026-06-14T18-01-36Z
slug: tch-presentation-widgets-match-phase-progress-dart
---
# Critique: Match page — board & steps visualization

**Target:** `lib/features/match/presentation/widgets/match_board_panel.dart`, `match_phase_progress.dart`, `phase_tile.dart`, `match_body.dart` header + phase list

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Phase progress is clear; board state hidden when collapsed |
| 2 | Match System / Real World | 2 | Mixed EN/PT phase titles ("Draw Phase" vs Portuguese UI) |
| 3 | User Control and Freedom | 3 | Expand/collapse phases & board; undo elsewhere in flow |
| 4 | Consistency and Standards | 3 | On-brand dark surfaces; Material FilterChips diverge slightly |
| 5 | Error Prevention | 3 | Min slot count enforced; target picker for evolve flows |
| 6 | Recognition Rather Than Recall | 2 | Board defaults collapsed — flags/slots not visible |
| 7 | Flexibility and Efficiency | 2 | No collapsed-board summary; re-expand every session |
| 8 | Aesthetic and Minimalist Design | 2 | Fixed header stacks 5 status blocks before scroll content |
| 9 | Error Recovery | 3 | Action undo exists; board edits lack undo affordance |
| 10 | Help and Documentation | 3 | Phase help dialog + board empty hints when expanded |
| **Total** | | **26/40** | **Acceptable — significant header/visibility improvements needed** |

## Anti-Patterns Verdict

**LLM assessment:** Does not read as AI slop. No neon gaming chrome, cream SaaS cards, gradient heroes, or eyebrow scaffolding. The match UI feels like a deliberate tool — Wise Violet accents, tonal surfaces, progressive disclosure on phases. The weakness is **product-density**, not generic aesthetics: too many status widgets stacked before the player reaches actions.

**Deterministic scan:** `detect.mjs` on match widget Dart files returned **0 findings** (expected — detector targets HTML/CSS markup, not Flutter widgets).

**Browser visualization:** Skipped — TurnWise match UI is Flutter native; no localhost HTML surface represents board/phase widgets. Assessment based on source + widget tests.

## Overall Impression

Phase visualization is thoughtfully built: a progress bar, a focused current `PhaseTile`, and a toggle for the full turn sequence. The board tracker is functionally solid with game-native slot labels and flag chips. The biggest gap is **header real estate**: timer, phase progress, turn context, optional resources, and a collapsed board all sit in a fixed block above the scroll area — so "one task per glance" breaks down before the player even sees action chips. Board state being collapsed by default undermines the tracker promise for target-dependent games (Pokémon evolve, Lorcana challenge, etc.).

## What's Working

1. **Phase focus mode** — Defaulting to the current `PhaseTile` only, with "Ver todas as fases (N)" as progressive disclosure, matches the Focused Table north star. Current phase gets violet tint, border, description inline, and a help affordance.

2. **`MatchPhaseProgress` clarity** — "Fase X de N" plus a linear bar gives immediate turn-position feedback without opening the list. Widget tests cover label rendering and bar math.

3. **Game-native board vocabulary** — Slot labels and flags (`Ativo`, `Descansado`, `Enjoo de invocação`) come from per-game config, not generic "Slot 1". Empty hints (e.g. Flesh and Blood AP copy) show product honesty.

## Priority Issues

### [P1] Fixed header stacks too many status layers before gameplay

- **What:** `MatchBodyHeader` vertically stacks timer → phase progress → turn context → resource bar (conditional) → board panel before the scrollable phase list and actions.
- **Why it matters:** Violates PRODUCT.md "one task per glance." At the table, the player must parse 4–5 zones to reach action chips — cognitive load checklist fails on single focus and one-thing-at-a-time.
- **Fix:** Collapse secondary header blocks into one compact status row, or move board/resources into the scroll body below the current phase tile. Keep timer + phase progress pinned; defer board to contextual reveal (e.g. when `requiresTarget` action is active).
- **Suggested command:** `/impeccable layout match header`

### [P1] Board panel collapsed by default with no collapsed-state summary

- **What:** `MatchBoardPanel` initializes `_expanded = false`. Collapsed view shows only the label "Tabuleiro" and a chevron — no slot count, active flags, or "needs attention" signal.
- **Why it matters:** For target-dependent actions, board state is part of turn tracking. Hidden board = hidden system status; players may forget flags exist until an evolve/challenge fails validation.
- **Fix:** Default expanded on first use per game, or show a one-line summary when collapsed ("Ativo · Banco 1 — 1 flag"). Persist expand preference. Consider auto-expanding when a `requiresTarget` action is in the current phase.
- **Suggested command:** `/impeccable onboard match board`

### [P2] Duplicate phase information between progress bar and PhaseTile

- **What:** `MatchPhaseProgress` shows phase number + title; the `PhaseTile` immediately below repeats title (+ description when current).
- **Why it matters:** Redundant focal points dilute hierarchy; the progress bar title truncates with ellipsis while the tile shows full text — two competing answers to "what phase am I in?"
- **Fix:** Progress bar shows only "Fase X de N" + bar (drop title), or hide the phase tile header when progress already names the phase. Let the tile own the title/description.
- **Suggested command:** `/impeccable distill match phases`

### [P2] Board panel uses nested surface cards + compact touch targets

- **What:** Panel container → per-slot nested containers → `FilterChip` with `VisualDensity.compact` / `shrinkWrap`; remove `IconButton` at 28×28pt.
- **Why it matters:** Nests surfaces (DESIGN.md bans nested cards). Compact chips and remove button risk sub-44pt targets during hurried play — WCAG AA / thumb-zone concern.
- **Fix:** Flatten slot rows to a single surface with dividers; increase chip vertical padding to ≥44pt hit area; enlarge remove control or use swipe-to-remove.
- **Suggested command:** `/impeccable audit match board`

### [P2] English phase titles in a Portuguese UI

- **What:** Rule assets use titles like "Draw Phase" while surrounding UI is Portuguese ("Fase 2 de 5", "Ações do turno" elsewhere).
- **Why it matters:** Breaks heuristic #2; beginners at a PT table hit a language switch mid-glance.
- **Fix:** Localize phase titles in rule JSON or map at render time per `gameId`.
- **Suggested command:** `/impeccable clarify match phases`

## Persona Red Flags

**Jordan (First-Timer):** Won't discover the board without expanding "Tabuleiro" — no onboarding points here. "Draw Phase" in English next to Portuguese chrome causes hesitation. "Ver todas as fases" is discoverable but below the fold of a tall header.

**Casey (Distracted Mobile):** Fixed header consumes ~40%+ of a small phone before actions; interrupted return requires re-scanning timer + progress + turn + board. Phase advance CTA pinned at bottom is good; everything above it is heavy.

**Sam (Accessibility):** 4px-tall `LinearProgressIndicator` is hard to perceive; progress communicated mostly by hue. Remove-slot control is 28×28pt. Past phases use strikethrough — screen readers OK, low-vision users may find struck titles harder to scan. Animations lack `MediaQuery.disableAnimations` guard.

**Morgan (Table-side TCG player):** Mid-evolve, needs Ativo + flag visible while picking actions — collapsed board forces extra tap every turn. Header height pushes action chips down; one-thumb reach suffers on iPhone SE-class devices.

## Minor Observations

- `match_board_panel_test.dart` taps a flag chip without expanding the panel first — test may not reflect real collapsed UX (verify in CI).
- `_scrollToCurrentPhase` uses magic `88.0` px per phase — fragile if `PhaseTile` height changes.
- `PhaseTile` help opens a modal — acceptable, but inline expansion might be faster at the table.
- Past-phase strikethrough on titles is uncommon in task UIs; muted + check icon may suffice.

## Questions to Consider

- What if the board only appeared when the current phase has `requiresTarget` actions?
- Does the progress bar need the phase title, or just position in the sequence?
- What would a single "match status" strip look like — timer left, phase center, turn right?
