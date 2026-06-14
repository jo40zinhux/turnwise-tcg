---
name: TurnWise TCG
description: Focused dark-mode turn assistant for physical TCG tables
colors:
  wise-violet: "#7C5CFF"
  wise-violet-muted: "#2E264D"
  table-ink: "#FFFFFF"
  table-ink-muted: "#B3FFFFFF"
  table-ink-subtle: "#73FFFFFF"
  table-bg: "#121212"
  table-surface: "#1E1E1E"
  table-surface-elevated: "#262626"
  table-border: "#1FFFFFFF"
  semantic-success: "#38C172"
  semantic-success-muted: "#1F3D2C"
  semantic-warning: "#E0A03B"
  semantic-warning-muted: "#3D2F18"
  semantic-danger: "#E5484D"
  semantic-danger-muted: "#3D1C1C"
  semantic-info: "#5BC0EB"
  semantic-info-muted: "#1B2E3A"
typography:
  display:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
    fontSize: "36px"
    fontWeight: 300
    lineHeight: 1.2
    letterSpacing: "normal"
  headline:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "normal"
  title:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
    fontSize: "20px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "normal"
  body:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
    letterSpacing: "normal"
  label:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "normal"
rounded:
  sm: "12px"
  md: "16px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "48px"
components:
  button-primary:
    backgroundColor: "{colors.wise-violet}"
    textColor: "{colors.table-ink}"
    rounded: "{rounded.md}"
    padding: "16px 24px"
  button-primary-pressed:
    backgroundColor: "{colors.wise-violet}"
    textColor: "{colors.table-ink}"
    rounded: "{rounded.md}"
    padding: "16px 24px"
  button-surface:
    backgroundColor: "{colors.table-surface}"
    textColor: "{colors.table-ink}"
    rounded: "{rounded.md}"
    padding: "16px 24px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.table-ink-muted}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
  card-surface:
    backgroundColor: "{colors.table-surface}"
    textColor: "{colors.table-ink}"
    rounded: "{rounded.md}"
    padding: "16px 24px"
  input-filled:
    backgroundColor: "{colors.table-surface}"
    textColor: "{colors.table-ink}"
    rounded: "{rounded.md}"
    padding: "18px 20px"
  chip-action-idle:
    backgroundColor: "{colors.table-surface}"
    textColor: "{colors.table-ink}"
    rounded: "{rounded.sm}"
    padding: "10px 14px"
  chip-action-used:
    backgroundColor: "{colors.wise-violet-muted}"
    textColor: "{colors.wise-violet}"
    rounded: "{rounded.sm}"
    padding: "10px 14px"
---

# Design System: TurnWise TCG

## Overview

**Creative North Star: "The Focused Table"**

TurnWise is a phone-side companion during physical TCG matches. The visual system is built for **mid-match glances**: one calm focal point, dark surfaces that recede in dim store lighting, and Wise Violet reserved for actions that move the game forward. It inherits Linear's tool clarity — focused hierarchy, minimal chrome, confident restraint — while allowing playful progress (achievements, game accents, haptics) without tipping into toy-like or aggressive gaming aesthetics.

The app rejects neon spectacle, childish mascots, cluttered judge consoles, and generic SaaS dashboard patterns. Depth comes from **tonal surface steps** with **subtle lift** only on floating feedback (snackbars, sheets, resume banner) — never decorative glass or gradient hero metrics.

**Key Characteristics:**

- Dark-first (`#121212` scaffold) with surface layering at `#1E1E1E` / `#262626`
- Wise Violet (`#7C5CFF`) as the sole brand accent — CTAs, active chips, focus rings
- Per-TCG accent colors on game cards only; never the global primary
- Flat cards at rest (`elevation: 0`); borders and tint carry structure
- System UI typography — no custom font pairing; weight and size do hierarchy
- Match action chips as the signature interaction pattern (2-column wrap grid)
- WCAG 2.1 AA contrast baseline; semantic colors never rely on hue alone for critical status

## Colors

A restrained dark palette: ink on charcoal, one violet accent, semantic feedback isolated from brand purple.

### Primary

- **Wise Violet** (`#7C5CFF`): Primary CTAs, used-action chip tint, input focus border, info badges. Appears on ≤15% of any match screen — its scarcity signals "do this next."
- **Wise Violet Muted** (`#7C5CFF` at 18% on surface / `#2E264D` approx.): Background tint for used action chips and selected states.

### Neutral

- **Table Background** (`#121212`): Scaffold, full-screen canvas behind all content.
- **Table Surface** (`#1E1E1E`): Cards, inputs, idle chips, secondary buttons.
- **Table Surface Elevated** (`#262626`): Sheets, modals, landing page elevated panels.
- **Table Ink** (`#FFFFFF`): Primary text, icons on dark surfaces.
- **Table Ink Muted** (`#B3FFFFFF` / 70% white): Secondary copy, ghost button labels, subtitles.
- **Table Ink Subtle** (`#73FFFFFF` / 45% white): Exhausted chip text, captions, disabled-adjacent states.
- **Table Border** (`#FFFFFF` at 8–12% opacity): Card outlines, login button stroke, dividers.

### Semantic (outcomes & feedback)

- **Success** (`#38C172`) / **Success Muted** (`#1F3D2C`): Win states, check icons on used chips.
- **Warning** (`#E0A03B`) / **Warning Muted** (`#3D2F18`): Timer approaching limit.
- **Danger** (`#E5484D`) / **Danger Muted** (`#3D1C1C`): Loss, destructive confirmations.
- **Info** (`#5BC0EB`) / **Info Muted** (`#1B2E3A`): Coach tips, tracker banners.

**The One Accent Rule.** `colorScheme.primary` (Wise Violet) is for brand and forward motion only. Win/loss/warning always use `AppSemanticTheme` tokens — never repurpose primary green/red.

**The Game Color Rule.** Each TCG has a catalog accent (Pokémon yellow, Lorcana teal, etc.) used only on `HomeGameCarouselCard` discovery tiles. Match UI stays neutral + violet so switching games does not reshuffle the whole chrome.

## Typography

**Display / Body / Label Font:** System UI stack (SF Pro on iOS, Roboto on Android, Segoe UI fallback on web landing)

**Character:** Lightweight display welcome, semibold titles for screen identity, regular body for instructions readable between turns. No decorative display faces — clarity over personality in type.

### Hierarchy

- **Display** (300, 36px, 1.2): Login welcome, large outcome screens. Max one per view.
- **Headline** (700, 24px, 1.25): Section headers inside dashboards.
- **Title** (600, 20px AppBar / 18px card): Screen titles, game card names, phase labels.
- **Body** (400, 16px, 1.45): Primary instructions, button labels, snackbar copy.
- **Body Muted** (400, 14px, 1.45, muted color): Subtitles, helper text under CTAs.
- **Label** (600, 14–16px, 1.2): Action chips, timer labels, stat metrics.
- **Caption** (400, 13px, 1.4, 65% opacity): Footnotes ("Funciona offline após a primeira entrada").

**The Glance Rule.** During an active match, the largest readable element should answer "what phase am I in?" or "what can I tap next?" — never marketing copy or decorative display type.

## Elevation

TurnWise is **tonal-first, subtly lifted**. Cards, chips, and dashboard tiles are flat (`elevation: 0`) — depth is conveyed by surface color steps and 1–1.5px borders, not drop shadows.

Floating elements earn a soft lift:

- **Snackbars** — `SnackBarBehavior.floating`, 16px radius, implicit Material shadow
- **Bottom sheets** — setup (timer, coin flip), target picker, game grid
- **Resume match banner** — `Card` on home with surface contrast
- **Landing header** (`web-page/`) — sticky bar with `backdrop-filter: blur(12px)` only; not used in the Flutter app shell

**The Flat-By-Default Rule.** If a surface is not modal, floating, or responding to direct touch feedback, it has no shadow. Nested cards are prohibited.

### Shadow Vocabulary

- **Floating feedback** (`0 8px 24px rgba(0,0,0,0.35)`): Snackbars, dialogs — rare, functional only.
- **Sticky web header** (`backdrop-filter: blur(12px)` + `rgba(18,18,18,0.85)`): Landing page only.

## Components

Tactile and confident at the table — large tap targets, immediate state change, haptic pairing on undo.

### Buttons

- **Shape:** Gently rounded (16px / `AppRadius.md`)
- **Primary:** Wise Violet fill, white label, 16×24px padding, zero elevation, white 10% pressed overlay
- **Surface (login OAuth):** `#1E1E1E` fill, white label, `Colors.white12` 1px border, left-aligned provider icon
- **Ghost:** Transparent, muted ink text — skip/dismiss actions
- **Disabled:** Reduced opacity via `onPressed: null`; loading uses full-screen scrim + `CircularProgressIndicator`

### Chips (signature)

- **Match Action Chip — idle:** Surface fill, subtle outline, 12px radius, 10×14px padding, 2-column wrap grid
- **Used:** Violet 18% tint, violet 60% border (1.5px), check icon, semibold label
- **Exhausted:** 60% surface opacity, 45% text, lock icon — still may allow undo on tap when max=1
- **Reminder badge:** `info_outline` icon in primary at 85% — long-press opens rule sheet
- **Filter / effect chips:** Material `FilterChip` / `InputChip` on surface, same radius family

### Cards / Containers

- **Corner Style:** 16px (`md`) for cards; 12px (`sm`) for compact tiles and chips
- **Background:** `#1E1E1E` default; game carousel catalog variant blends TCG accent at 14% over surface
- **Border:** 1–1.2px `outlineVariant` at 30% (recent) or TCG accent at 50% (catalog)
- **Internal Padding:** 16–24px horizontal (`AppSpacing.md`–`lg`), 12–16px vertical
- **Shadow Strategy:** None at rest (see Elevation)

### Inputs / Fields

- **Style:** Filled surface background, no border at rest, 16px radius
- **Focus:** 2px Wise Violet outline — no glow bloom
- **Content padding:** 20px horizontal, 18px vertical
- **Error / Disabled:** Use semantic danger for error text; filled surface dims for disabled

### Navigation

- **AppBar:** Transparent, centered title (Title 20px semibold), zero elevation, settings icon trailing
- **Routes:** `go_router` — no persistent tab bar; home is hub, match is full-screen focus
- **Back:** Platform-default or implicit via sheet dismiss — no custom chrome stack

### Match Phase & Timer Bar

- **Phase progress:** Current phase tile highlighted on surface; past phases visually complete
- **Timer bar:** Semantic warning/danger color shift near limit; haptic pulse on expiry (settings-gated)
- **Resume banner:** Full-width card on home — primary CTA + dismiss (X) with confirmation

## Do's and Don'ts

### Do:

- **Do** keep match screens visually quiet — one highlighted phase, one primary CTA (`Próxima fase` / `Terminar turno`).
- **Do** use `AppSemanticTheme` for win/loss/warning/timer urgency — never Wise Violet for outcomes.
- **Do** maintain 16px screen horizontal padding (`AppSpacing.screenHorizontal`) for thumb reach consistency.
- **Do** animate chip state changes over 200ms `easeOut` — respect `prefers-reduced-motion` with instant crossfade.
- **Do** pair destructive actions with confirmation dialogs and danger semantic color.
- **Do** let each TCG accent color live only on home discovery cards, not match chrome.

### Don't:

- **Don't** use aggressive neon gaming UI — no cyberpunk gradients, glowing borders, or RGB spectacle.
- **Don't** feel childish or toy-like — no cartoon mascots, bubbly excess, or infantilizing illustration style.
- **Don't** build cluttered rulebook trackers — avoid dense text walls, spreadsheet grids, or judge-console density on phone.
- **Don't** import generic SaaS dashboard patterns — no cream backgrounds, hero metrics, or identical icon+heading card grids.
- **Don't** use `border-left` or `border-right` greater than 1px as a colored accent stripe on cards or list items.
- **Don't** nest cards inside cards — use spacing and typography to separate content instead.
- **Don't** put gradient text or decorative glassmorphism on core app surfaces.
- **Don't** let muted gray body text fall below WCAG AA on `#1E1E1E` — bump toward Table Ink when in doubt.
