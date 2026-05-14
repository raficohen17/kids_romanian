# Change: refresh-visual-system

## Why

The current visual system reads as "kids' app circa 2014":

- The body has a three-color rainbow gradient (`#fce4ec → #e3f2fd → #fff9c4`).
- Almost every button uses its own `linear-gradient(135deg, ...)` — a different gradient per mode.
- Cards stack on gradients which stack on gradients; the eye has no anchor.
- Five-plus saturated colors compete in every screen.

The goal is something that reads as **slick + modern but still feels playful for a 9-year-old**: one calm canvas, one strong accent, deliberate use of color for rewards/state, and chrome that doesn't shout. Reference points are current Duolingo, Khan Academy Kids, and Toca/Sago kids' apps — playful but disciplined.

## What Changes

### Palette

Replace the current rainbow with a small palette:

- `--canvas: #fbf7f2`      — warm off-white background
- `--surface: #ffffff`     — card / popover surface
- `--accent: #2e7d32`      — primary action / active state (forest green)
- `--reward: #f9a825`      — earned points, confetti, "good job" moments (saffron)
- `--ink: #1f1f1f`         — body text
- `--muted: #6b6b6b`       — secondary text
- `--line:  #ececea`       — dividers, subtle borders
- `--danger: #c62828`      — reset / sign-out hints (rare)

The accent + reward colors are the only saturated tones in the system. Every other surface is canvas-tint or pure white.

### No gradients on UI elements

Remove `linear-gradient(...)` from every button, pill, chip, card, and the `body` background. Solid colors only.

The `body` is `var(--canvas)`. Active states use solid accent. Confetti and the kid's bubbles can use the reward color.

### Typography

- Hebrew: keep **Heebo** (already in stack).
- Latin (Romanian + English): adopt **Nunito** for friendly rounded sans-serif. Loaded from Google Fonts via CDN (no build step).
- Sizing scale: `0.9rem` (caption) → `1rem` (body) → `1.15rem` (default content) → `1.4rem` (titles) → `2rem` (card headlines).
- Weights: 400 and 700 only. No italics.
- Line-height: 1.5 for body, 1.3 for headlines.

### Button system

A single button shape:

- Solid background, 16px radius, 12px vertical padding, 18px horizontal.
- Primary = `--accent` fill, white text.
- Secondary = white fill, `--ink` text, 1.5px `--line` border.
- Destructive = white fill, `--danger` text, 1.5px `--danger` border.
- Pressed: `transform: scale(0.96)` for 150ms.
- Disabled: 40% opacity, no transform.

No more gradient buttons.

### Motion

- Standard transition: `150ms ease`. Apply to color, background, border, transform.
- Tap feedback: `scale(0.96)` for 100ms on `:active`.
- Confetti: keep the burst on correct answers, but soften — fewer particles, faster fade, palette limited to `--accent` and `--reward`.
- A small `pop` animation on "+10 ⭐" callouts using `--reward`.

### Icon system

- **Content stays emoji** (modes, vocab, words, cards). Kids recognize emoji, they're RTL-safe, and they require no extra dependency.
- **Chrome moves to Lucide** line icons inlined as SVG. Use cases:
  - Back / close (`x`, `arrow-left`)
  - Settings (`settings-2`)
  - Reset (`refresh-cw`)
  - Send (`send`)
  - Sign-out (`log-out`)
  - Switch (`users`)
  - Play / pause (where 🔊 emoji isn't ideal — TBD)
- Icons SHALL be inlined SVG (no external font, no build step). Stroke width 2, current color, 20×20 base.

### Mode color hint

When a practice mode is active, the **card** for that mode (not the tab) carries a 4px accent stripe at the top edge. The accent stripe SHALL use `--accent` for all modes — we are not assigning a unique brand color per mode in this pass.

## Out of Scope (future)

- **Layout / information architecture** (the modes bar collapse, profile chip) — covered by the separate `declutter-app-shell` proposal so the two can ship independently.
- **Dark mode**. The kid uses this on iPad in well-lit rooms; defer until requested.
- **Per-mode brand color** (e.g., Stories = cobalt, Chat = lemon). Tempting but adds complexity for little daily benefit.
- **Removing emoji from content**. Emoji is the visual language of the app's *content* and stays.
- **Sound effects / haptics**. Separate concern.
- **A full mascot / illustrations**. Out of scope; the rainbow favicon is enough personality for now.

## Impact

- **Modified**: `index.html` — `<style>` block rewritten around CSS custom properties; gradients removed from all selectors; button system collapsed into a small set of classes; new Google Fonts `<link>` in `<head>` for Nunito; Lucide icons inlined where chrome actions live.
- **No JS logic changes** beyond replacing `🔊` / `⚙️` / `🚪` glyphs with `<svg>` icons in chrome locations.
- **No data, auth, backend, or schema changes.**
- **One new external dependency**: a Google Fonts stylesheet link (Nunito). Heebo already loaded by the system font stack. No npm package, no bundler change.

## Risks

- **Font load shift**: Nunito loads after first paint. Mitigate with `font-display: swap` and a system fallback (`sans-serif`).
- **Inline SVGs grow the file**: ~6 icons × ~200 bytes each = ~1.2KB. Acceptable next to the existing ~6000-line file.
- **Accent green could read as "correct" everywhere**, which clashes with using it for primary actions. Mitigate by reserving the very saturated `--reward` saffron for actual success states (confetti, "+10 ⭐"), and using accent green only for active-tab and primary-CTA.
- **Tutor / parent muscle memory**: the rainbow is what the family has been looking at. Worth previewing once before merging.
