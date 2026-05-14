# Design: refresh-visual-system

## Context

Pass 1 swapped the rainbow body gradient for a warm-cream canvas, defined a token system, and chose forest green + saffron yellow as the accent + reward. The user judged the result un-pleasing and only partially applied: many components in the file still use the original pink/purple palette. This revision picks a new palette and sweeps the file rather than touching only the loudest surfaces.

## Goals / Non-Goals

**Goals**
- Pick a palette that reads as **warm + playful + modern** without going back to rainbow.
- Apply tokens to every surface, not just gradients and the body.
- Separate three roles that shared "green" before: primary accent, reward, "correct answer". Distinct hues for each.

**Non-Goals**
- Layout / IA changes (those live in `declutter-app-shell`).
- Dark mode, per-mode colors, illustrations, sound.
- Replacing emoji with icons in content.

## Decisions

### Decision 1: Indigo-violet primary, coral reward, emerald correct

| Role     | Color hex  | Where it appears                                          |
|----------|------------|-----------------------------------------------------------|
| Accent   | `#6750a4`  | Active tab, primary button, popover-row hover, h1, card-stripe |
| Reward   | `#ff7a59`  | Streak badge, score-pop, confetti, unit-current outline   |
| Success  | `#2e9c63`  | "Correct!" toast accent, confetti accent                  |
| Canvas   | `#fbf6ee`  | `body`                                                    |
| Surface  | `#ffffff`  | `.panel`, `.card`, popovers                               |
| Ink      | `#1f1f1f`  | Body text                                                 |
| Muted    | `#6b6b6b`  | Secondary text                                            |
| Line     | `#e7e3dc`  | Warm-grey borders, dividers                               |
| Danger   | `#c62828`  | Sign-out / reset hints                                    |

**Rationale.**
- **Indigo-violet** keeps the visual lineage with the original purple muscle-memory of the app (favicon, old `.btn` purple), while reading as modern (Material You, Apple's purple accent). Reads as "this is the brand", not "you are correct".
- **Coral** for reward against warm cream is more emotive than saffron — warmer, less "fast-food orange", less prone to muddying when used at small sizes.
- **Emerald** for correctness is held back from chrome entirely; appears only on the "+10 ⭐" pop and confetti highlights. Scarcity preserves the reward feeling.

### Decision 2: Add `--accent-soft` and `--reward-soft` wash variables

Hover states and selected backgrounds need a *tint* of the primary, not its full saturation. Without a token for the tint, every selector invents its own `rgba(...)` which is how the file got stuck on purples like `#f3e5f5` and pinks like `#fde7f2`. Adding two soft variants gives every selector a named choice:

```css
--accent-soft: #ede7f6;   /* indigo wash */
--reward-soft: #ffe7df;   /* coral wash  */
```

`--line` (`#e7e3dc`) becomes the default border. It is a warm grey rather than the cold `#ececea` from pass 1 — pairs better with the cream canvas.

### Decision 3: Sweep, don't patch

Pass 1 patched the high-traffic surfaces (body, buttons, card, popover) and left the rest. That's what produced the half-redesigned look. This revision identifies every hard-coded purple / pink / cold-blue hex in the stylesheet and remaps it to a token. Specific targets are listed in `proposal.md` § Sweep. The cleanup criterion: `grep -nE '#(d81b60|c2185b|4527a0|4a148c|ba68c8|7e57c2|f3e5f5|fde7f2|3949ab|e1bee7|fff7e6|fbc02d|fff59d|e53935|43a047|1e88e5|e65100|fff9c4|fce4ec|e3f2fd|6a1b9a|c5cae9|9fa8da|7986cb|8e24aa|aa00ff)'` returns matches only inside the favicon SVG (intentionally rainbow) and within `<svg>` content.

### Decision 4: Confetti palette swap

Pass 1 set confetti to `--accent` (forest-green) + `--reward` (saffron). With the new roles, confetti uses `--reward` (coral) as the primary burst color and `--success` (emerald) as the accent, so a "correct!" burst feels distinctly green-tinged without bleeding green onto chrome.

### Decision 5: Stat cards drop the indigo `#3949ab`

Stat cards used three saturated colors (pink, saffron, indigo) for score / streak / total. With the new role-based palette:

- `.stat.score` → `--accent` background, white text — score is the primary metric of the session.
- `.stat.streak` → `--reward` background, white text — streak is the reward feeling.
- `.stat.total` → `--accent-soft` background, `--ink` text — total is neutral context, no need for a third saturated color.

This drops one saturated color from the always-visible chrome and makes the streak coral pop against the cream canvas.

### Decision 6: Flashcard text colors follow role

- `.he` (Hebrew translation) → `--ink`. The Hebrew is the kid's anchor; styling it with a brand color makes the foreign word fight for attention.
- `.ro` (Romanian / English target word) → `--accent`. This is the word being taught — it deserves the accent.
- `.pron` (pronunciation hint) → `--muted`.
- `.note` (cultural note) → `--muted`, italic preserved.

### Decision 7: No new external font

Stays on `Heebo` + `Nunito` from Google Fonts. The palette change does the heavy lifting; introducing a third font would be churn.

## Risks / Trade-offs

- **Indigo + coral could read as "candy" to some adults.** Mitigated by the disciplined application — only two saturated tones on chrome at any time, everything else neutral.
- **Sweeping every hex literal is mechanical work that can introduce subtle regressions** (wrong shade on an accent border, missed selector). Mitigated by an explicit grep at the end and a visual pass per mode.
- **The emerald success color is rare by design**, which means kids might not associate it with correctness without repeated exposure. Acceptable — the existing "מעולה! 🌟" string and confetti motion carry the meaning; color is reinforcement.
- **Mode-active indigo stripe could read as "selected" rather than "active"** on the card. Mitigated by the same indigo being used on the active mode tab — same color = same meaning.

## Migration / Compatibility

- Pure CSS / token change. No data, no auth, no backend.
- All existing class names preserved.
- Independent of `declutter-app-shell` revision but both ship together — they share a release.
- Favicon untouched (rainbow circle stays as the app's mascot).
