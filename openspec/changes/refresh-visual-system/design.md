# Design: refresh-visual-system

## Context

The app's visual system grew organically. Each feature added its own gradient, its own button color, its own card style. The result is high energy with no focal point. For a 9-year-old practicing daily, that means visual fatigue and difficulty locating the "important thing on screen right now".

Modern kids' apps (current Duolingo, Khan Academy Kids, Toca apps) handle this by isolating one focal color, leaving the rest of the canvas neutral, and using motion + emoji for personality instead of color saturation everywhere. The redesign adopts that pattern within the project's hard constraints:

- Single HTML file, no build step.
- Hebrew RTL.
- Emoji-heavy content already exists and is part of the personality.

## Goals / Non-Goals

**Goals**
- Replace the multi-gradient palette with a disciplined small palette (canvas + surface + accent + reward + ink).
- Remove every gradient from the UI.
- Establish a font pairing: Heebo for Hebrew, Nunito for Latin.
- Introduce a Lucide line-icon set for chrome (back, settings, reset, send, sign-out).
- Define motion defaults: 150ms ease for transitions, scale(0.96) on tap.
- Keep emoji as the content visual language.

**Non-Goals**
- Layout / IA changes (separate proposal).
- Dark mode.
- Per-mode brand colors.
- Sound, haptics, illustrations.
- Replacing emoji with icons in content.

## Decisions

### Decision 1: CSS custom properties as the single source of truth

All colors and spacing live as CSS variables on `:root`:

```css
:root {
  --canvas: #fbf7f2;
  --surface: #ffffff;
  --accent: #2e7d32;
  --reward: #f9a825;
  --ink:    #1f1f1f;
  --muted:  #6b6b6b;
  --line:   #ececea;
  --danger: #c62828;

  --radius-sm: 8px;
  --radius-md: 14px;
  --radius-lg: 22px;

  --shadow-sm: 0 1px 2px rgba(0,0,0,0.06);
  --shadow-md: 0 4px 14px rgba(0,0,0,0.08);

  --transition: 150ms ease;
}
```

Every existing color hex in the file gets remapped to one of these. No more inline color literals in selectors.

**Rationale.** A single change to `--accent` should reskin the app. Dark mode (if it ever lands) would only add a second `[data-theme="dark"]` block.

### Decision 2: Solid surfaces, no gradients

Search-and-destroy: every `linear-gradient(135deg, ...)` becomes a solid `--surface` or `--accent` fill. The body background `linear-gradient(135deg, #fce4ec 0%, #e3f2fd 50%, #fff9c4 100%)` becomes `var(--canvas)`.

**Rationale.** Gradients on chrome compete with content. The rainbow background was the worst offender — it made every other color feel "off" against it.

### Decision 3: One button shape, three intents

Buttons collapse to three classes:

- `.btn` (primary, accent fill, white text)
- `.btn-secondary` (white fill, ink text, border)
- `.btn-ghost` or `.btn-danger` (white fill, danger text + border) for destructive/escape actions

Every existing button class (`.btn.speak`, `.btn.shuffle`, `.btn.prev`, etc.) collapses into these. Mode-specific visual tags can come back later as small accent dots or stripes if we want them.

**Rationale.** The kid doesn't need a different button color per action. She needs to know what's clickable and what does the main thing.

### Decision 4: Lucide for chrome, emoji for content

The line between chrome and content is the rule:

- **Chrome** = system actions on the page shell that the kid uses to *operate* the app. Back, close, settings, sign-out, reset, send. These deserve a consistent line-icon set so they read as "controls".
- **Content** = anything the kid is *learning*. Vocab cards, mode tabs (the mode itself is content), story bubbles. Emoji wins here — universal, RTL-safe, no font.

Lucide icons are inlined as `<svg>` (MIT licensed). Stroke 2, 20×20, `currentColor`. ~6 icons * ~200 bytes ≈ 1.2KB.

**Alternative considered.** Phosphor icons. Equally fine; Lucide chosen for the slightly cleaner default style and simpler stroke.

### Decision 5: Reward color reserved for success moments

`--reward` (saffron `#f9a825`) appears only on:

- Confetti particles
- The `+10 ⭐` score pop
- Earned unit badges (when unlocking a new unit)

It does NOT appear on regular UI chrome. This keeps the "good job!" feeling rare and rewarding.

**Rationale.** If every button were saffron, success wouldn't *feel* like anything. Scarcity = emotion.

### Decision 6: Motion is restrained

- `transition: var(--transition);` on color, background, border, transform.
- `:active { transform: scale(0.96); }` for buttons/chips.
- Confetti: keep current effect but reduce particle count by ~50% and shorten duration to ~1.2s.
- Card mode-enter: gentle 200ms fade + 4px up-slide. No bounce.

**Rationale.** Bouncy springs read as toy-ish; subtle ease reads as well-made. A 9-year-old who plays Roblox and watches TikTok knows the difference.

### Decision 7: Mode-active stripe instead of mode-color

The active mode's card has a 4px `--accent` stripe at its top edge. All modes use the same stripe color. This visually signals "this is the active practice" without requiring per-mode brand colors.

**Future**: if per-mode colors are wanted later, this is the single hook to swap (`.card[data-mode] { --mode-color: ...; }`).

## Risks / Trade-offs

- **Heebo + Nunito blend**: tested informally, the two pair well at body sizes; titles in mixed-language headers may need careful kerning. Mitigated by using a Hebrew title rather than mixed text.
- **Loading external font**: blocks first paint slightly. Mitigated by `font-display: swap` and keeping system fallback.
- **Removing all gradients feels "flatter"**: by design. The reward color and motion are the personality replacements.
- **Inline SVG bloat**: minimal at 6 icons; if it grows past ~30 icons we'd reconsider a sprite sheet.
- **Single-accent risk**: green for "go" can read as "correct" universally. We keep `--reward` saffron for real success moments so "correct" stays distinct.

## Migration / Compatibility

- Pure CSS / asset change. No data, no auth, no backend.
- Existing CSS class names are preserved where reasonable so future feature work doesn't need re-wiring; their visual output changes.
- The change can ship before or after `declutter-app-shell` — independent. Shipping `declutter` first probably makes the visual refresh look cleaner because there's less to restyle.
- `package.json` unaffected (no npm install).
